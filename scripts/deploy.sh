#!/usr/bin/env bash
# Creates (or updates) the whole guestbook: S3 + Lambda + DynamoDB + dashboard. ~90 s from nothing.
. "$(dirname "$0")/_common.sh"
bold "Deploying stack '$STACK' in $AWS_REGION  (Infrastructure as Code: infra/guestbook.yaml)"
T0=$(date +%s)
aws cloudformation deploy --template-file "$ROOT/infra/guestbook.yaml" --stack-name "$STACK" \
  --capabilities CAPABILITY_IAM --no-fail-on-empty-changeset --tags project=cloud101
OUT=$(aws cloudformation describe-stacks --stack-name "$STACK" --query 'Stacks[0].Outputs' --output json)
get(){ echo "$OUT" | jq -r ".[] | select(.OutputKey==\"$1\") | .OutputValue"; }
WEBSITE_URL=$(get WebsiteURL); FN_URL=$(get FunctionUrl); BUCKET=$(get BucketName)
TABLE=$(get TableName); FN=$(get FunctionName); DASH=$(get DashboardURL)
API_BASE="${FN_URL%/}"

bold "Uploading code to Lambda ($FN)"
rm -rf "$ROOT/build/fn" && mkdir -p "$ROOT/build/fn"
cp "$ROOT/lambda/handler.py" "$ROOT/build/fn/"
sed "s|__API_BASE__||" "$ROOT/web/index.html" > "$ROOT/build/fn/index.html"
(cd "$ROOT/build/fn" && zip -qr ../fn.zip .)
aws lambda update-function-code --function-name "$FN" --zip-file "fileb://$ROOT/build/fn.zip" >/dev/null
aws lambda wait function-updated --function-name "$FN"

bold "Uploading website to S3 ($BUCKET)"
sed "s|__API_BASE__|$API_BASE|" "$ROOT/web/index.html" > "$ROOT/build/index.s3.html"
aws s3 cp "$ROOT/build/index.s3.html" "s3://$BUCKET/index.html" --content-type "text/html; charset=utf-8" --cache-control no-store >/dev/null

CODE=$(curl -s -o /dev/null -w '%{http_code}' --max-time 10 "$WEBSITE_URL" || echo 000)
if [ "$CODE" = "200" ]; then DEMO_URL="$WEBSITE_URL"; ok "S3 website is public (HTTP 200)"
else DEMO_URL="$FN_URL"; warn "S3 website returned $CODE - using the Lambda URL instead"; fi
curl -s --max-time 10 "$API_BASE/api" | jq -c '{count,region,instance}' || warn "API not answering yet (give it a few seconds)"

cat > "$ENVFILE" <<E
STACK=$STACK
WEBSITE_URL=$WEBSITE_URL
FN_URL=$FN_URL
API_BASE=$API_BASE
DEMO_URL=$DEMO_URL
BUCKET=$BUCKET
TABLE=$TABLE
FN=$FN
DASH=$DASH
E
echo
ok "Done in $(( $(date +%s) - T0 )) s"
echo "  Open in browser: $DEMO_URL"
echo "  API           : $API_BASE/api"
echo "  Dashboard     : $DASH"
echo "  Next          : scripts/qr.sh   (puts the QR on screen)"
