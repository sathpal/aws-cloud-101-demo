#!/usr/bin/env bash
# Launches N web servers (default 1) in Mumbai with a page that shows where they are running.
# Usage: scripts/ec2-demo.sh [count]     Type override: TYPE=t2.micro scripts/ec2-demo.sh
. "$(dirname "$0")/_common.sh"
COUNT="${1:-1}"; TYPE="${TYPE:-t3.micro}"; NAME="cloud101-web"
bold "Launching $COUNT x $TYPE in $AWS_REGION"
AMI=$(aws ssm get-parameters --names /aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 --query 'Parameters[0].Value' --output text)
VPC=$(aws ec2 describe-vpcs --filters Name=is-default,Values=true --query 'Vpcs[0].VpcId' --output text)
[ "$VPC" = "None" ] && die "No default VPC. Run: aws ec2 create-default-vpc"
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=$NAME Name=vpc-id,Values=$VPC --query 'SecurityGroups[0].GroupId' --output text)
if [ "$SG" = "None" ]; then
  SG=$(aws ec2 create-security-group --group-name $NAME --description "Cloud 101 web demo" --vpc-id "$VPC" --query GroupId --output text)
  aws ec2 authorize-security-group-ingress --group-id "$SG" --protocol tcp --port 80 --cidr 0.0.0.0/0 >/dev/null
fi
echo "  AMI $AMI · VPC $VPC · SG $SG (port 80 open, no SSH needed)"
IDS=$(aws ec2 run-instances --image-id "$AMI" --instance-type "$TYPE" --count "$COUNT" --security-group-ids "$SG" \
  --user-data "file://$ROOT/scripts/ec2-userdata.sh" \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$NAME},{Key=project,Value=cloud101}]" \
  --query 'Instances[].InstanceId' --output text)
echo "  Instance IDs: $IDS"
# shellcheck disable=SC2086
aws ec2 wait instance-running --instance-ids $IDS
# shellcheck disable=SC2086
aws ec2 describe-instances --instance-ids $IDS --query 'Reservations[].Instances[].[InstanceId,Placement.AvailabilityZone,PublicIpAddress]' --output table
# shellcheck disable=SC2086
IPS=$(aws ec2 describe-instances --instance-ids $IDS --query 'Reservations[].Instances[].PublicIpAddress' --output text)
for IP in $IPS; do
  printf "  waiting for http://%s " "$IP"
  for _ in $(seq 1 40); do curl -s -o /dev/null --max-time 3 "http://$IP" && { echo " up"; open "http://$IP" 2>/dev/null || true; break; }; printf .; sleep 5; done
done
ok "Open: $(for IP in $IPS; do printf 'http://%s ' "$IP"; done)"
echo "  Clean up with scripts/ec2-cleanup.sh"
