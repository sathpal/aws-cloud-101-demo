#!/bin/bash
# Runs once, inside the new EC2 instance, on first boot.
dnf install -y httpd >/dev/null 2>&1
TOKEN=$(curl -sX PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 120")
md(){ curl -s -H "X-aws-ec2-metadata-token: $TOKEN" "http://169.254.169.254/latest/meta-data/$1"; }
cat > /var/www/html/index.html <<HTML
<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Hello from AWS</title>
<body style="margin:0;background:#0f1720;color:#eef3f8;font-family:-apple-system,Segoe UI,Roboto,sans-serif;display:flex;align-items:center;justify-content:center;min-height:100vh">
<div style="max-width:720px;padding:32px">
<div style="color:#ff9900;font-size:.9rem;letter-spacing:.1em;text-transform:uppercase">Amazon EC2 · virtual server</div>
<h1 style="font-size:2.4rem;margin:8px 0 20px">Hello SNIT Hyderabad 👋<br>I was born $(date -u +"%H:%M:%S UTC") today.</h1>
<table style="font-size:1.1rem;border-collapse:collapse">
<tr><td style="color:#8fa3b8;padding:6px 18px 6px 0">Instance ID</td><td><code>$(md instance-id)</code></td></tr>
<tr><td style="color:#8fa3b8;padding:6px 18px 6px 0">Data centre (AZ)</td><td><code>$(md placement/availability-zone)</code></td></tr>
<tr><td style="color:#8fa3b8;padding:6px 18px 6px 0">Size</td><td><code>$(md instance-type)</code> · $(nproc) vCPU · $(free -m | awk '/Mem/{print $2}') MB RAM</td></tr>
<tr><td style="color:#8fa3b8;padding:6px 18px 6px 0">Public IP</td><td><code>$(md public-ipv4)</code></td></tr>
<tr><td style="color:#8fa3b8;padding:6px 18px 6px 0">OS</td><td>$(. /etc/os-release; echo $PRETTY_NAME)</td></tr>
</table>
<p style="color:#8fa3b8;margin-top:24px">Nobody bought this computer. Nobody installed it. It exists because of one command, and it will vanish with one more.</p>
</div></body>
HTML
systemctl enable --now httpd
