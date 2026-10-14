---
title: Build, load-test and delete a serverless app on AWS in 30 minutes
published: false
description: One CloudFormation file, 80 lines of Python, 200 requests in 5 seconds, and a bill that stops the moment you say so. A hands-on walkthrough with the two gotchas that cost me an hour.
tags: aws, serverless, tutorial, beginners
cover_image: https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/architecture-diagram.png
canonical_url:
---

I wanted a demo that makes cloud computing *felt* rather than explained. Not a slide about elasticity, but a page on your phone that gets hit by 200 requests while you watch the number of servers climb, with nobody adding a server.

This is that demo. It is small enough to read in full, costs nothing on the AWS Free plan, and deletes itself with one command. The repo is at [github.com/sathpal/aws-cloud-101-demo](https://github.com/sathpal/aws-cloud-101-demo) and the README takes you from "I have no AWS account" to cleanup.

Here is what we are building, and what I learned building it.

## What you get

A **Cloud Guestbook**. Anyone opens a page, types their name, where they are joining from and one word, and taps Send. Their entry appears for everyone within two seconds, along with a counter of how many separate copies of the backend AWS has started so far.

![The guestbook page](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/guestbook-desktop.png)

Four services, each doing one job:

| Service | Job |
|---|---|
| **S3** | Hosts the page. It is one HTML file in a bucket configured as a static website. |
| **Lambda** | Runs the backend, an 80-line Python handler, only when a request arrives. |
| **DynamoDB** | Stores one row per entry. On-demand billing, no capacity to plan. |
| **CloudWatch** | A dashboard with five graphs: requests, concurrent executions, latency, writes, errors. |

All of it is declared in one CloudFormation template and created in about 80 seconds.

There is also a side demo that rents a plain Linux server on EC2, because "a computer you never see" is still the best first mental model for the cloud.

## Prerequisites

- An AWS account. New accounts get USD 100 in credits on the Free plan, which cannot be charged. This whole tutorial uses a few cents of that.
- An IAM user with an access key, and `aws configure` done.
- `aws`, `jq`, `curl`, `zip` and `uv` installed. On macOS that is `brew install awscli jq uv`. On Windows use WSL.

The README covers each of these step by step, including creating the account and turning on MFA.

```bash
git clone https://github.com/sathpal/aws-cloud-101-demo.git
cd aws-cloud-101-demo
scripts/preflight.sh
```

Preflight checks your tools, credentials, region, whether your account blocks public S3 websites, and whether you have a default VPC for EC2.

## Step 1: rent a computer

```bash
scripts/ec2-demo.sh
```

The script is 25 lines and worth reading. It asks Systems Manager for the ID of the latest Amazon Linux 2023 image, finds your default VPC, creates a security group that opens only port 80, and calls `run-instances` for one `t3.micro` with a first-boot script attached as user-data.

That first-boot script installs Apache, asks the instance metadata service who it is, and writes a page about itself:

![The EC2 page](https://raw.githubusercontent.com/sathpal/aws-cloud-101-demo/main/docs/screenshots/ec2-server-page.png)

About 90 seconds from command to page. The availability zone on that page is a physical data centre. Nobody bought that machine.

## Step 2: the whole backend as one file

Open `infra/guestbook.yaml`. Every block under `Resources:` becomes a real thing. The interesting parts:

```yaml
Table:
  Type: AWS::DynamoDB::Table
  Properties:
    BillingMode: PAY_PER_REQUEST
    AttributeDefinitions: [{ AttributeName: id, AttributeType: S }]
    KeySchema: [{ AttributeName: id, KeyType: HASH }]

Fn:
  Type: AWS::Lambda::Function
  Properties:
    Runtime: python3.12
    Handler: handler.handler
    MemorySize: 256
    Timeout: 10
    Environment:
      Variables: { TABLE: !Ref Table }

FnUrl:
  Type: AWS::Lambda::Url
  Properties:
    TargetFunctionArn: !Ref Fn
    AuthType: NONE
    Cors: { AllowOrigins: ['*'], AllowMethods: ['*'], AllowHeaders: ['*'] }
```

A Function URL gives the Lambda a public HTTPS address with no API Gateway in between. The IAM role grants the function exactly three DynamoDB actions on exactly one table. Then:

```bash
scripts/deploy.sh
```

This runs `aws cloudformation deploy`, zips the handler with a copy of the page and uploads it, writes the Function URL into the page, copies the page to S3, and prints your URLs:

```
✔ Done in 79 s
  Open in browser: http://cloud101-guestbook-webbucket-xxxx.s3-website-ap-south-1.amazonaws.com
  API           : https://xxxx.lambda-url.ap-south-1.on.aws/api
  Dashboard     : https://ap-south-1.console.aws.amazon.com/cloudwatch/home?...
```

Open the CloudFormation console and look at the Events tab. Nine resources, created in dependency order, with timestamps. On-premises this is a purchase order and a rack.

## Step 3: the backend, in full

The handler is the entire server side. Trimmed:

```python
INSTANCE = uuid.uuid4().hex[:6]   # new value each time AWS starts a fresh copy
ddb = boto3.resource("dynamodb").Table(os.environ["TABLE"])

def handler(event, context):
    method = event["requestContext"]["http"]["method"]
    if event.get("rawPath", "/").rstrip("/") == "/api":
        if method == "GET":
            items = all_items()            # paginated scan
            return resp(200, {
                "count": len(items),
                "entries": items[:60],
                "instances": sorted({i["instance"] for i in items}),
                "instance": INSTANCE,
            })
        if method == "POST":
            data = json.loads(event["body"])
            ddb.put_item(Item={
                "id": uuid.uuid4().hex, "ts": int(time.time() * 1000),
                "name": data["name"][:40], "place": data.get("place", "")[:30],
                "word": data.get("word", "")[:30].lower(), "instance": INSTANCE,
            })
            return resp(201, {"ok": True, "instance": INSTANCE})
    return resp(200, open("index.html").read(), "text/html")
```

The `INSTANCE` trick is the heart of the demo. That value is computed once per Lambda execution environment, so every row records which copy of the code wrote it. The page counts distinct values and labels it "servers AWS created for us".

## Step 4: 200 requests in 5 seconds

Open the CloudWatch dashboard, set auto-refresh to 10 seconds, and:

```bash
scripts/blast.sh 200
```

That is `seq 1 200 | xargs -P 50 curl ...`, nothing fancier. My result:

```
Sending 200 requests, 50 at a time
 200 201
  elapsed: 5.0 s
✔ Handled by 41 distinct Lambda instances so far.
```

Every request returned 201. Lambda saw 50 arriving together, started around 40 copies of the function, and the Errors graph stayed flat at zero. Average response time was 33 ms. Reload the guestbook and the servers counter has jumped from 1 to about 40.

Then `scripts/reset.sh` deletes the 200 load-test rows and keeps the real ones.

## The two gotchas

I lost about an hour to these. You do not have to.

**1. The public Function URL returned 403 even with the permission in place.**

The template originally had the one permission every tutorial shows:

```yaml
FnUrlPermission:
  Type: AWS::Lambda::Permission
  Properties:
    FunctionName: !Ref Fn
    Action: lambda:InvokeFunctionUrl
    Principal: '*'
    FunctionUrlAuthType: NONE
```

Direct `aws lambda invoke` worked. The URL did not. Newer accounts also require a plain `lambda:InvokeFunction` grant for anonymous URL calls, and you cannot put `FunctionUrlAuthType` on that action, so it needs a second resource:

```yaml
FnUrlInvokePermission:
  Type: AWS::Lambda::Permission
  Properties:
    FunctionName: !Ref Fn
    Action: lambda:InvokeFunction
    Principal: '*'
```

My first attempt at this included the auth-type condition and CloudFormation rolled back with "FunctionUrlAuthType is only supported for lambda:InvokeFunctionUrl action". Drop the condition and it goes through.

**2. curl worked, the browser said "Cannot reach the API".**

The handler was returning its own `Access-Control-Allow-Origin: *` header, and the Function URL's CORS config was adding another one. The response carried two of them. Browsers reject that outright. curl does not care, which is why every terminal check passed.

Fix: let exactly one layer own CORS. I removed the header from the handler and left the Function URL config in charge.

## What it costs

On the Free plan, nothing. Outside it, this is pennies: Lambda is billed per request and per millisecond of execution, DynamoDB on-demand per read and write, S3 per gigabyte stored and served. A few hundred entries and a dashboard do not register on a bill.

The exception is EC2. A `t3.micro` is billed per second while it runs, whether or not anyone is looking at it. Which brings us to the last step.

## Step 5: the bill stops now

```bash
scripts/ec2-cleanup.sh     # terminates the server, deletes the security group
scripts/destroy.sh         # empties the bucket, deletes the stack, waits for confirmation
```

Both wait until AWS confirms. Try returning a physical server to a vendor after 25 minutes.

## Where to go from here

- Rebuild it by clicking through the console instead of running the scripts, then read the YAML again and notice how much it saved you.
- Fork the repo and add something: photo upload to S3, a leaderboard, a delete-my-entry button, a custom domain through CloudFront.
- The AWS Cloud Practitioner exam covers exactly the concepts in this demo, and the course on AWS Skill Builder is free.

The full guide, from creating the account to cleanup, is in the README: [github.com/sathpal/aws-cloud-101-demo](https://github.com/sathpal/aws-cloud-101-demo). If you build it, I would like to see what you add.
