# ========================================
# Base Stage: Debian slim (glibc) for workerd/wrangler
# ========================================
FROM node:22-bookworm-slim AS base

RUN apt-get update \
  && apt-get install -y --no-install-recommends wget ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# ========================================
# Dependencies Stage: Install Dependencies
# ========================================
FROM base AS deps
WORKDIR /app

RUN npm install -g pnpm
RUN pnpm install -g turbo

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
RUN mkdir -p apps packages
COPY apps/*/package.json ./apps/
COPY packages/ ./packages/

RUN pnpm install --prod --ignore-scripts

# ========================================
# Builder Stage: Build the Application
# ========================================
FROM base AS builder
WORKDIR /app

RUN npm install -g pnpm wrangler @cloudflare/workerd-linux-64

COPY package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json ./
COPY . .

ENV CI=true

RUN pnpm install --frozen-lockfile

ENV NEXT_TELEMETRY_DISABLED=1 \
    NODE_ENV=production \
    DOCKER_BUILD=true

RUN cd apps/mail && pnpm run build

# ========================================
# Runner Stage: Production Environment
# ========================================
FROM base AS runner
WORKDIR /app

RUN npm install -g wrangler @cloudflare/workerd-linux-64

RUN groupadd -g 1001 pnpm \
  && useradd -u 1001 -g pnpm -m nextjs

ENV NODE_ENV=production \
    PORT=3000 \
    HOSTNAME="0.0.0.0" \
    NEXT_TELEMETRY_DISABLED=1 \
    WRANGLER_SEND_METRICS=false

COPY scripts/docker/ /app/scripts
RUN chmod -R +x /app/scripts/*

COPY --from=builder --chown=nextjs:pnpm /app ./

USER nextjs

EXPOSE 3000

CMD ["/app/scripts/entrypoint.sh"]
