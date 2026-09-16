#!/usr/bin/env bash
# The "bill stops now" moment: empties the bucket and deletes every resource the stack created.
. "$(dirname "$0")/_common.sh"; load_env
bold "Deleting stack $STACK (bucket $BUCKET, table $TABLE, function $FN, dashboard)"
aws s3 rm "s3://$BUCKET" --recursive >/dev/null || true
aws cloudformation delete-stack --stack-name "$STACK"
aws cloudformation wait stack-delete-complete --stack-name "$STACK" && ok "Everything is gone. Nothing left to pay for." && rm -f "$ENVFILE"
