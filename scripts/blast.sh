#!/usr/bin/env bash
# "What if 200 people hit it at once?"  Fires N POSTs with 50 in parallel. Watch the dashboard.
. "$(dirname "$0")/_common.sh"; load_env
N="${1:-200}"; P="${2:-50}"
bold "Sending $N requests, $P at a time, to $API_BASE/api"
T0=$(date +%s.%N 2>/dev/null || date +%s)
seq 1 "$N" | xargs -P "$P" -I{} curl -s -o /dev/null -w '%{http_code}\n' -X POST "$API_BASE/api" \
  -H 'Content-Type: application/json' -d "{\"name\":\"load-test-{}\",\"place\":\"LOADTEST\",\"word\":\"scale\"}" | sort | uniq -c
python3 - "$T0" <<'P' 2>/dev/null || true
import sys,time; print(f"  elapsed: {time.time()-float(sys.argv[1]):.1f} s")
P
INST=$(curl -s "$API_BASE/api" | jq -r '.instances | length')
ok "Handled by $INST distinct Lambda instances so far. Now open the dashboard: $DASH"
