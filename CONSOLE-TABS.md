# Console tabs for the audience

Open these in this order and pin them before the session. Every link is set to **Asia Pacific (Sydney) ap-southeast-2**,
the region this deployment runs in. Check the region switcher (top right of the console) says Sydney first,
otherwise the console shows empty lists.

If you redeploy, resource names change. Re-run `scripts/deploy.sh` and read the new names from
`build/.demo-env.cloud101-guestbook`, or just open the service and search for `cloud101`.

| # | Demo step | What to show | Link |
|---|---|---|---|
| 1 | 2.1 A computer in the cloud | Instance state, AZ `ap-southeast-2b`, public IP, Security tab (port 80 open) | [EC2 instance i-0bfb8bbecdb52acba](https://ap-southeast-2.console.aws.amazon.com/ec2/home?region=ap-southeast-2#InstanceDetails:instanceId=i-0bfb8bbecdb52acba) |
| 1b | 2.1 | The "Hello SNIT" page the server built for itself | http://3.25.118.252 |
| 2 | 2.2 Infrastructure as Code | **Resources** tab (nine things from one file), **Events** tab (created in order), **Template** tab | [CloudFormation stack cloud101-guestbook](https://ap-southeast-2.console.aws.amazon.com/cloudformation/home?region=ap-southeast-2#/stacks/stackinfo?stackId=cloud101-guestbook) |
| 3 | 2.3 QR on screen | The page students scan | `build/qr.html` (open locally) |
| 4 | 2.4 The page is a file | `index.html` in the bucket; **Properties → Static website hosting** at the bottom | [S3 bucket](https://ap-southeast-2.console.aws.amazon.com/s3/buckets/cloud101-guestbook-webbucket-emqz5nobqxmp?region=ap-southeast-2&tab=objects) |
| 5 | 2.4 Code with no server | **Code** tab shows `handler.py`; **Monitor** tab shows invocations climbing | [Lambda function](https://ap-southeast-2.console.aws.amazon.com/lambda/home?region=ap-southeast-2#/functions/cloud101-guestbook-Fn-FqqY4swqYMbP?tab=code) |
| 6 | 2.4 Find a student's row | Opens **Explore items**. Click *Scan* then *Run* | [DynamoDB table](https://ap-southeast-2.console.aws.amazon.com/dynamodbv2/home?region=ap-southeast-2#item-explorer?table=cloud101-guestbook-Table-1VLBX4GJ6CQRG) |
| 7 | 2.5 The load blast | Set range to **1h**, auto-refresh **10 s**. Run `scripts/blast.sh 200`, wait ~1 min | [CloudWatch dashboard](https://ap-southeast-2.console.aws.amazon.com/cloudwatch/home?region=ap-southeast-2#dashboards:name=cloud101-guestbook-live) |
| 8 | 2.6 What it costs | Billing is global (stays on us-east-1). May be denied on a sandbox account: skip and say the number | [Billing home](https://us-east-1.console.aws.amazon.com/costmanagement/home#/home) |
| 9 | 2.6 Who does what | The role the CLI runs as (this sandbox uses a role, not the `cloud101` user) | [IAM role AccountFullAccessRole](https://us-east-1.console.aws.amazon.com/iam/home#/roles/details/AccountFullAccessRole) |
| 10 | 2.6 Global infrastructure | Region switcher, top right of any page. Point at Mumbai and Hyderabad | any console page |

Keep the **guestbook page itself** open on the projector too. The "servers AWS created for us" counter on it is the
payoff of the blast.

Students open: http://cloud101-guestbook-webbucket-emqz5nobqxmp.s3-website-ap-southeast-2.amazonaws.com
