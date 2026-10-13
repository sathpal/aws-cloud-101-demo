# Presenter notes · Cloud 101 · SNIT Hyderabad — AWS live demo kit

A 30-minute live demo for a 2-hour "Introduction to Cloud Computing with AWS" session, plus the
session runbook. Everything is designed to be created live in front of students, hit from their
phones, and deleted live at the end ("the bill stops now").

| Piece | What students see | AWS services |
|---|---|---|
| **Cloud Guestbook** | Scan a QR, type name + branch + one word, watch the room's answers appear live, see how many "servers" AWS created | S3 static site, Lambda Function URL, DynamoDB, CloudWatch dashboard, CloudFormation |
| **EC2 in 60 seconds** | A brand-new Linux web server in Mumbai that reports its own instance ID, data centre and IP | EC2, security group, AMI, user-data |
| **Load blast** | 200 requests in a few seconds, dashboard spikes, no crash, no one did anything | Lambda auto-scaling |
| **Bonus: AI** | Ask a model on Bedrock a cricket-flavoured question from the terminal | Amazon Bedrock (optional, needs model access) |

Read [RUNBOOK.md](RUNBOOK.md) for the minute-by-minute plan, talking points and fallbacks, and [CONSOLE-TABS.md](CONSOLE-TABS.md) for the console links to show the audience. To run the demo yourself, start from [README.md](README.md).

## Setup (tonight, ~10 minutes)

1. **CLI credentials** (the browser login does not reach the CLI):
   AWS console → IAM → Users → *Create user* `cloud101` → attach **AdministratorAccess** →
   *Security credentials* → *Create access key* → "Command Line Interface" → copy both values, then:
   ```bash
   aws configure        # paste key + secret, region: ap-south-1, output: json
   ```
2. **Check everything**
   ```bash
   cd ~/aws-cloud-101-demo
   scripts/preflight.sh
   ```
3. **Rehearse the full demo once**
   ```bash
   scripts/deploy.sh          # ~90 s: creates S3 + Lambda + DynamoDB + dashboard
   scripts/qr.sh              # opens a full-screen QR page; scan it with your phone, post an entry
   scripts/blast.sh 200       # fire 200 requests; open the dashboard link it prints
   scripts/status.sh
   scripts/reset.sh           # remove the load-test rows (keeps real entries)
   scripts/ec2-demo.sh        # ~2 min: launches a web server, opens it in the browser
   scripts/ec2-cleanup.sh     # terminate it (do this tonight — EC2 is the only thing that costs while idle)
   ```
4. Leave the guestbook stack deployed overnight as a **backup** (idle cost ≈ ₹0). For the live show you
   will create a second, fresh stack in front of the students.

## Script reference

| Script | Purpose |
|---|---|
| `scripts/preflight.sh` | Tools, credentials, region, S3 public-access setting, default VPC, Bedrock visibility |
| `scripts/deploy.sh` | Create/update the guestbook stack, upload code + page, print URLs. `STACK=name` picks a stack name |
| `scripts/qr.sh [url]` | Full-screen QR page for students (defaults to the deployed guestbook) |
| `scripts/status.sh` | Entry count, requests / concurrency / latency in the last 10 min |
| `scripts/blast.sh [n] [parallel]` | Load test the API (default 200 requests, 50 parallel) |
| `scripts/reset.sh [--all]` | Delete load-test rows, or all rows |
| `scripts/destroy.sh` | Empty bucket + delete stack — the "bill stops now" moment |
| `scripts/ec2-demo.sh [count]` | Launch web server(s), wait until they answer, open in browser |
| `scripts/ec2-cleanup.sh` | Terminate them and delete the security group |
| `scripts/ai-demo.sh [question]` | Ask a Bedrock model (optional) |

All scripts honour `AWS_REGION` and `STACK` environment variables. Deployed stack details are cached in
`build/.demo-env.<stack>`.

## If the CLI is not an option tomorrow

Every step has a console path (described in the runbook): upload `infra/guestbook.yaml` in the
CloudFormation console, upload `build/index.s3.html` to the bucket, paste `scripts/ec2-userdata.sh`
into the EC2 launch wizard's *User data* box.

## Cost

DynamoDB on-demand, Lambda, S3 and one CloudWatch dashboard for one classroom sit inside the free
tier. `t3.micro` EC2 is free-tier eligible but is billed per second while running, so terminate it.
Run `scripts/destroy.sh` and `scripts/ec2-cleanup.sh` after the session.
