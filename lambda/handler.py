"""
Cloud Guestbook - the whole backend of the demo.
GET  /        -> serves index.html (fallback if the S3 website is blocked)
GET  /api     -> { count, entries[], region, instance, uptime_s }
POST /api     -> { name, branch, word } -> stored in DynamoDB
This file runs on AWS Lambda: no server to install, patch, or keep running.
"""
import base64
import json
import os
import time
import uuid

import boto3

TABLE = os.environ["TABLE"]
REGION = os.environ.get("AWS_REGION", "unknown")
INSTANCE = uuid.uuid4().hex[:6]      # new value each time AWS starts a fresh copy of this code
BOOTED = time.time()
ddb = boto3.resource("dynamodb").Table(TABLE)
HERE = os.path.dirname(os.path.abspath(__file__))


def resp(status, body, ctype="application/json; charset=utf-8"):
    return {
        "statusCode": status,
        "headers": {
            "Content-Type": ctype,
            # CORS headers come from the Function URL config; adding one here too
            # produces a duplicate Access-Control-Allow-Origin, which browsers reject.
            "Cache-Control": "no-store",
        },
        "body": body if isinstance(body, str) else json.dumps(body, default=str),
    }


def all_items():
    items, kwargs = [], {}
    while True:
        page = ddb.scan(**kwargs)
        items.extend(page.get("Items", []))
        if "LastEvaluatedKey" not in page:
            return items
        kwargs["ExclusiveStartKey"] = page["LastEvaluatedKey"]


def handler(event, context):
    http = event.get("requestContext", {}).get("http", {})
    method = http.get("method", "GET")
    path = event.get("rawPath", "/")

    if path.rstrip("/") == "/api":
        if method == "GET":
            items = all_items()
            items.sort(key=lambda i: int(i.get("ts", 0)), reverse=True)
            return resp(200, {
                "count": len(items),
                "entries": [
                    {"name": i.get("name"), "branch": i.get("branch"),
                     "word": i.get("word"), "ts": int(i.get("ts", 0)),
                     "instance": i.get("instance")}
                    for i in items[:60]
                ],
                "words": [i.get("word") for i in items if i.get("word")],
                "instances": sorted({i.get("instance") for i in items if i.get("instance")}),
                "region": REGION,
                "instance": INSTANCE,
                "uptime_s": int(time.time() - BOOTED),
                "request_id": context.aws_request_id,
            })
        if method == "POST":
            raw = event.get("body") or "{}"
            if event.get("isBase64Encoded"):
                raw = base64.b64decode(raw).decode("utf-8")
            try:
                data = json.loads(raw)
            except json.JSONDecodeError:
                return resp(400, {"error": "body must be JSON"})
            name = str(data.get("name", "")).strip()[:40]
            branch = str(data.get("branch", "")).strip()[:30]
            word = str(data.get("word", "")).strip()[:30].lower()
            if not name:
                return resp(400, {"error": "name is required"})
            item = {
                "id": uuid.uuid4().hex,
                "ts": int(time.time() * 1000),
                "name": name, "branch": branch, "word": word,
                "instance": INSTANCE, "region": REGION,
            }
            ddb.put_item(Item=item)
            return resp(201, {"ok": True, "instance": INSTANCE, "region": REGION})
        return resp(405, {"error": "method not allowed"})

    # Anything else: serve the page itself, with the API pointing at this same URL.
    with open(os.path.join(HERE, "index.html"), encoding="utf-8") as f:
        html = f.read()
    return resp(200, html, "text/html; charset=utf-8")
