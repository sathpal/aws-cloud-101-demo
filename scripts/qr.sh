#!/usr/bin/env bash
# Generates a projector-friendly QR page for the guestbook (or any URL passed as $1).
. "$(dirname "$0")/_common.sh"
if [ -n "${1:-}" ]; then URL="$1"; else load_env; URL="$DEMO_URL"; fi
mkdir -p "$ROOT/build"
uvx --from 'qrcode[pil]' qr --error-correction=M --output="$ROOT/build/qr.png" "$URL"
B64=$(base64 < "$ROOT/build/qr.png" | tr -d '\n')
cat > "$ROOT/build/qr.html" <<E
<!doctype html><meta charset="utf-8"><title>Scan me</title>
<body style="margin:0;background:#0f1720;color:#eef3f8;font-family:-apple-system,Segoe UI,Roboto,sans-serif;display:flex;flex-direction:column;align-items:center;justify-content:center;min-height:100vh;gap:24px">
<div style="font-size:2.4rem;font-weight:800">Scan → Cloud Guestbook</div>
<img src="data:image/png;base64,$B64" style="width:min(70vh,90vw);background:#fff;padding:24px;border-radius:16px">
<div style="font-family:Menlo,monospace;font-size:1.3rem;word-break:break-all;max-width:90vw;text-align:center">$URL</div>
<div style="color:#8fa3b8">Your phone → Amazon S3 → AWS Lambda → DynamoDB</div>
</body>
E
uvx --from qrcode qr "$URL" 2>/dev/null || true
ok "QR page: $ROOT/build/qr.html"
open "$ROOT/build/qr.html" 2>/dev/null || true
