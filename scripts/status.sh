#!/usr/bin/env bash
# One-screen summary: entries, Lambda traffic in the last 10 minutes, URLs.
. "$(dirname "$0")/_common.sh"; load_env
NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ); AGO=$(date -u -v-10M +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '10 min ago' +%Y-%m-%dT%H:%M:%SZ)
m(){ aws cloudwatch get-metric-statistics --namespace AWS/Lambda --metric-name "$1" --dimensions Name=FunctionName,Value="$FN" \
     --start-time "$AGO" --end-time "$NOW" --period 600 --statistics "$2" --query "Datapoints[0].$2" --output text | sed 's/None/0/'; }
bold "Stack $STACK ($AWS_REGION)"
echo "  Entries in DynamoDB      : $(aws dynamodb scan --table-name "$TABLE" --select COUNT --query Count --output text)"
echo "  Requests, last 10 min    : $(m Invocations Sum)"
echo "  Peak concurrent servers  : $(m ConcurrentExecutions Maximum)"
echo "  Avg response (ms)        : $(m Duration Average)"
echo "  Errors                   : $(m Errors Sum)"
echo "  Students open            : $DEMO_URL"
echo "  Dashboard                : $DASH"
