#!/bin/sh
set -e

BACKEND_URL="${NEXT_PUBLIC_BACKEND_URL:-http://localhost:8787}"
APP_URL="${NEXT_PUBLIC_APP_URL:-http://localhost:3000}"

/app/scripts/replace-placeholder.sh "http://REPLACE-BACKEND-URL.com" "$BACKEND_URL"
/app/scripts/replace-placeholder.sh "http://REPLACE-APP-URL.com" "$APP_URL"

WRANGLER_JSONC=/app/apps/mail/wrangler.jsonc
sed -i "s|http://localhost:8787|${BACKEND_URL}|g" "$WRANGLER_JSONC"
sed -i "s|https://localhost:8787|${BACKEND_URL}|g" "$WRANGLER_JSONC"
sed -i "s|http://localhost:3000|${APP_URL}|g" "$WRANGLER_JSONC"
sed -i "s|https://localhost:3000|${APP_URL}|g" "$WRANGLER_JSONC"

cd /app/apps/mail
exec wrangler dev \
  --env local \
  --port 3000 \
  --host 0.0.0.0 \
  --ip 0.0.0.0 \
  --show-interactive-dev-session=false
