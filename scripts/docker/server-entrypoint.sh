#!/bin/sh
set -e

ulimit -n 65536 2>/dev/null || true

APP_URL="${NEXT_PUBLIC_APP_URL:-https://mail-zero.recreabox.com}"
API_URL="${NEXT_PUBLIC_BACKEND_URL:-https://api-mail-zero.recreabox.com}"
WRANGLER_JSONC=/app/apps/server/wrangler.jsonc

sed -i "s|@localhost:5432|@db:5432|g" "$WRANGLER_JSONC"
sed -i "s|http://localhost:3000|${APP_URL}|g" "$WRANGLER_JSONC"
sed -i "s|https://localhost:3000|${APP_URL}|g" "$WRANGLER_JSONC"
sed -i "s|http://localhost:8787|${API_URL}|g" "$WRANGLER_JSONC"
sed -i "s|https://localhost:8787|${API_URL}|g" "$WRANGLER_JSONC"

cd /app/apps/server
exec wrangler dev \
  --env local \
  --port 8787 \
  --host 0.0.0.0 \
  --ip 0.0.0.0 \
  --show-interactive-dev-session=false
