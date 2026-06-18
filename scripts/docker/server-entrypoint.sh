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

sed -i "s|\"COOKIE_DOMAIN\": \"localhost\"|\"COOKIE_DOMAIN\": \"${COOKIE_DOMAIN:-mail-zero.recreabox.com}\"|g" "$WRANGLER_JSONC"

# Wrangler local dev reads secrets from .dev.vars (not docker env alone).
DEV_VARS=/app/apps/server/.dev.vars
: > "$DEV_VARS"
for key in \
  BETTER_AUTH_SECRET \
  BETTER_AUTH_URL \
  GOOGLE_CLIENT_ID \
  GOOGLE_CLIENT_SECRET \
  MICROSOFT_CLIENT_ID \
  MICROSOFT_CLIENT_SECRET \
  REDIS_URL \
  REDIS_TOKEN \
  RESEND_API_KEY \
  OPENAI_API_KEY \
  OPENAI_MODEL \
  OPENAI_MINI_MODEL \
  GROQ_API_KEY \
  PERPLEXITY_API_KEY \
  AUTUMN_SECRET_KEY \
  TWILIO_ACCOUNT_SID \
  TWILIO_AUTH_TOKEN \
  TWILIO_PHONE_NUMBER; do
  val=$(eval echo "\$$key")
  if [ -n "$val" ]; then
    printf '%s=%s\n' "$key" "$val" >> "$DEV_VARS"
  fi
done

if [ -z "$GOOGLE_CLIENT_ID" ] || [ -z "$GOOGLE_CLIENT_SECRET" ]; then
  echo "zero-server: WARNING — GOOGLE_CLIENT_ID / GOOGLE_CLIENT_SECRET missing; auth API will fail until configured"
fi

cd /app/apps/server
echo "zero-server: starting wrangler on :8787 (local-only)"
exec wrangler dev \
  --local \
  --env local \
  --port 8787 \
  --host 0.0.0.0 \
  --ip 0.0.0.0 \
  --show-interactive-dev-session=false \
  --persist-to /tmp/wrangler-state
