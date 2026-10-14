# Screenshots

Captured with headless Chrome from the running demo and the public AWS pages.

| File | Shows |
|---|---|
| `architecture-diagram.png` | Rendered copy of `../architecture.svg` |
| `guestbook-desktop.png` | The deployed guestbook on a laptop |
| `guestbook-phone.png` | The same page at phone width |
| `ec2-server-page.png` | The page an EC2 instance builds about itself on first boot |
| `qr-code-page.png` | The full-screen QR page from `scripts/qr.sh` |
| `aws-signup-page.png` | AWS account sign-up form |
| `aws-signin-page.png` | AWS console sign-in |
| `aws-free-tier-page.png` | Free Tier page describing the credit-based Free plan |
| `aws-cli-install-page.png` | AWS CLI install documentation |
| `aws-regions-page.png` | AWS global infrastructure page |

## Still to capture (need a signed-in console)

These would strengthen sections 2, 3, 9, 11 and 12 of the README. Capture at 1280 px wide, PNG, with the
account ID blurred, and drop them in here with these names, then add the images to the README.

- `console-iam-create-user.png`: IAM → Users → Create user, with AdministratorAccess ticked
- `console-iam-access-key.png`: the Create access key screen (before the key is shown)
- `console-mfa.png`: Security credentials → Assign MFA device
- `console-ec2-instances.png`: EC2 → Instances with `cloud101-web` running
- `console-cfn-events.png`: CloudFormation → stack → Events tab during creation
- `console-cfn-resources.png`: CloudFormation → stack → Resources tab
- `console-s3-objects.png`: the bucket with `index.html`
- `console-lambda-code.png`: Lambda → function → Code tab
- `console-dynamodb-items.png`: DynamoDB → Explore items after a scan
- `console-cloudwatch-dashboard.png`: the dashboard right after `scripts/blast.sh 200`
