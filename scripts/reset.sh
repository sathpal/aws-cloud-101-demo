#!/usr/bin/env bash
# Deletes load-test entries (default) or everything (--all). Use between rehearsals.
. "$(dirname "$0")/_common.sh"; load_env
if [ "${1:-}" = "--all" ]; then FILTER=""; else FILTER="--filter-expression branch=:b --expression-attribute-values {\":b\":{\"S\":\"LOADTEST\"}}"; fi
# shellcheck disable=SC2086
IDS=$(aws dynamodb scan --table-name "$TABLE" --projection-expression id $FILTER --query 'Items[].id.S' --output text | tr '\t' '\n' | grep -v '^$' || true)
[ -z "$IDS" ] && { ok "nothing to delete"; exit 0; }
echo "$IDS" | xargs -n 25 | while read -r batch; do
  REQ=$(for i in $batch; do printf '{"DeleteRequest":{"Key":{"id":{"S":"%s"}}}},' "$i"; done)
  aws dynamodb batch-write-item --request-items "{\"$TABLE\":[${REQ%,}]}" >/dev/null
done
ok "deleted $(echo "$IDS" | wc -l | tr -d ' ') entries"
