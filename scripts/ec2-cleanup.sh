#!/usr/bin/env bash
# Terminates every cloud101-web instance and removes the security group.
. "$(dirname "$0")/_common.sh"
IDS=$(aws ec2 describe-instances --filters Name=tag:project,Values=cloud101 Name=instance-state-name,Values=pending,running,stopping,stopped --query 'Reservations[].Instances[].InstanceId' --output text)
if [ -n "$IDS" ]; then
  # shellcheck disable=SC2086
  aws ec2 terminate-instances --instance-ids $IDS --query 'TerminatingInstances[].[InstanceId,CurrentState.Name]' --output table
  # shellcheck disable=SC2086
  aws ec2 wait instance-terminated --instance-ids $IDS
  ok "terminated: $IDS"
else ok "no instances running"; fi
SG=$(aws ec2 describe-security-groups --filters Name=group-name,Values=cloud101-web --query 'SecurityGroups[0].GroupId' --output text)
[ "$SG" != "None" ] && aws ec2 delete-security-group --group-id "$SG" && ok "security group removed" || true
