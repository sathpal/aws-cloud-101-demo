#!/usr/bin/env bash
# Run this tonight and again 30 min before the demo.
. "$(dirname "$0")/_common.sh"
bold "Cloud 101 preflight"
for t in aws jq curl zip uvx; do command -v $t >/dev/null && ok "$t found" || warn "$t missing"; done
aws --version
ID=$(aws sts get-caller-identity 2>&1) || die "AWS CLI has no working credentials.
   Fix: in the AWS console -> IAM -> Users -> Create user 'cloud101' -> attach AdministratorAccess
        -> Security credentials -> Create access key (CLI) -> then run:  aws configure
        (region: ap-south-1, output: json)"
echo "$ID" | jq .
ok "Region: $AWS_REGION"
[ "$AWS_REGION" = "ap-south-1" ] || warn "Region is not ap-south-1 (Mumbai). Demo works anywhere, but the story is 'Mumbai'."
ACCT=$(echo "$ID" | jq -r .Account)
BPA=$(aws s3control get-public-access-block --account-id "$ACCT" 2>/dev/null | jq -c .PublicAccessBlockConfiguration || echo "none")
if echo "$BPA" | grep -q true; then warn "Account-level S3 Block Public Access is ON ($BPA). The S3 website URL will 404; deploy.sh will fall back to the Lambda URL."
else ok "Account-level S3 Block Public Access: not blocking"; fi
aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text | grep -q vpc- && ok "Default VPC exists (EC2 demo ready)" || warn "No default VPC: run  aws ec2 create-default-vpc"
aws bedrock list-foundation-models --query 'length(modelSummaries)' --output text 2>/dev/null | xargs -I{} echo "Bedrock models visible in region: {} (optional AI demo)" || warn "Bedrock not reachable here (optional demo only)"
ok "Preflight done"
