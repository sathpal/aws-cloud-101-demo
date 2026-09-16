# shared helpers (sourced by every script)
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export AWS_PAGER=""
export AWS_DEFAULT_REGION="${AWS_REGION:-${AWS_DEFAULT_REGION:-$(aws configure get region 2>/dev/null || echo ap-south-1)}}"
export AWS_REGION="$AWS_DEFAULT_REGION"
STACK="${STACK:-cloud101-guestbook}"
ENVFILE="$ROOT/build/.demo-env.$STACK"
bold(){ printf '\033[1m%s\033[0m\n' "$*"; }
ok(){ printf '\033[32m✔ %s\033[0m\n' "$*"; }
warn(){ printf '\033[33m! %s\033[0m\n' "$*"; }
die(){ printf '\033[31m✘ %s\033[0m\n' "$*" >&2; exit 1; }
load_env(){ [ -f "$ENVFILE" ] || die "No $ENVFILE - run scripts/deploy.sh first"; # shellcheck disable=SC1090
  . "$ENVFILE"; }
