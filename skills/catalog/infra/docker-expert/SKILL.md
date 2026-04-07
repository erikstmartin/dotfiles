---
name: docker-expert
description: Use for Dockerfiles, multi-stage builds, image optimization, Compose, container security, and runtime debugging. Not for Kubernetes/Helm or cloud-specific container services.
---

# Docker Expert

## Scope

- **In scope**: Dockerfiles, multi-stage builds, image optimization, Docker Compose, container security, runtime debugging
- **Out of scope**: Kubernetes/Helm → kubernetes-expert | GitHub Actions CI/CD → github-actions-expert | AWS ECS/Fargate → devops-expert

---

## 1. Dockerfile Optimization Workflow

**Step 1: Order layers by change frequency (least → most)**

Dependencies change rarely; source code changes constantly. Put dependencies first so rebuilds reuse cache.

```dockerfile
# WRONG - source copy before deps invalidates cache on every code change
COPY . .
RUN npm ci

# RIGHT - deps layer cached until package.json changes
COPY package*.json ./
RUN npm ci
COPY . .
```

**Step 2: Mount package manager cache (BuildKit)**

```dockerfile
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```

**Step 3: Consolidate RUN commands that modify the same layer**

```dockerfile
# WRONG - 3 layers, apt cache left in one
RUN apt-get update
RUN apt-get install -y curl
RUN rm -rf /var/lib/apt/lists/*

# RIGHT - single layer, cache cleaned in same step
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl && \
    rm -rf /var/lib/apt/lists/*
```

**Step 4: Create a `.dockerignore`**

```
.git
node_modules
dist
*.log
.env*
coverage
```

**Step 5: Validate build + inspect layers**

```bash
docker build --no-cache -t myapp:test .
docker history myapp:test
docker images myapp:test  # check final size
```

---

## 2. Multi-Stage Build Workflow

Use stages to: (1) keep build tools out of production, (2) copy only final artifacts.

**Step 1: Name every stage**

```dockerfile
FROM node:20-alpine AS deps
FROM node:20-alpine AS build
FROM node:20-alpine AS production
```

**Step 2: Install deps in an isolated stage**

```dockerfile
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production
```

**Step 3: Build in a separate stage (includes devDependencies)**

```dockerfile
FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build
```

**Step 4: Assemble minimal production image**

```dockerfile
FROM node:20-alpine AS production
RUN addgroup -g 1001 -S app && adduser -S app -u 1001 -G app
WORKDIR /app
COPY --from=deps  --chown=app:app /app/node_modules ./node_modules
COPY --from=build --chown=app:app /app/dist         ./dist
USER 1001
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

**Step 5: Build targeting a specific stage**

```bash
# Production image
docker build --target production -t myapp:latest .

# Development image (includes build tools)
docker build --target build -t myapp:dev .
```

**Size check**: compare `docker images` before and after. A Node app should drop from ~1GB → ~150MB with distroless or alpine production stage.

---

## 3. Container Orchestration Workflow (Docker Compose)

**Step 1: Define services with explicit health checks**

Health checks are required for `depends_on: condition: service_healthy` to work.

**Step 2: Use internal networks to isolate backend services**

```yaml
networks:
  frontend:   # app → public
  backend:    # app ↔ db, internal only
    internal: true
```

**Step 3: Set resource limits to prevent noisy-neighbor issues**

**Step 4: Separate dev and prod configs**

- `compose.yml` — base config
- `compose.override.yml` — auto-merged for dev (volume mounts, debug ports)
- `compose.prod.yml` — prod overrides, applied with `-f`

```bash
# Dev (auto-merges compose.override.yml)
docker compose up

# Prod
docker compose -f compose.yml -f compose.prod.yml up -d
```

**Step 5: Validate before running**

```bash
docker compose config          # validates merged config
docker compose up --build -d   # build + start
docker compose ps              # verify all services healthy
docker compose logs -f app     # tail logs
```

---

## 4. Complete Examples

### Example A: Optimized Node.js API Dockerfile

```dockerfile
# syntax=docker/dockerfile:1
FROM node:20-alpine AS deps
WORKDIR /app
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --only=production

FROM node:20-alpine AS build
WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

FROM node:20-alpine AS production
RUN addgroup -g 1001 -S app && adduser -S app -u 1001 -G app
WORKDIR /app
COPY --from=deps  --chown=app:app /app/node_modules ./node_modules
COPY --from=build --chown=app:app /app/dist         ./dist
USER 1001
EXPOSE 3000
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost:3000/health || exit 1
CMD ["node", "dist/index.js"]
```

### Example B: Node API + Postgres Compose Setup

**`compose.yml`** (base — shared across environments):

```yaml
services:
  app:
    build:
      context: .
      target: production
    depends_on:
      db:
        condition: service_healthy
    networks:
      - frontend
      - backend
    environment:
      DATABASE_URL: postgres://app:${DB_PASSWORD}@db:5432/appdb
      NODE_ENV: production
    ports:
      - "3000:3000"
    healthcheck:
      test: ["CMD", "wget", "-qO-", "http://localhost:3000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 15s
    deploy:
      resources:
        limits:   { cpus: "0.5", memory: 512M }
        reservations: { cpus: "0.25", memory: 256M }
      restart_policy:
        condition: on-failure
        max_attempts: 3

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: appdb
      POSTGRES_USER: app
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - backend
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U app -d appdb"]
      interval: 10s
      timeout: 5s
      retries: 5

networks:
  frontend:
  backend:
    internal: true

volumes:
  postgres_data:
```

**`compose.override.yml`** (dev — auto-merged):

```yaml
services:
  app:
    build:
      target: build          # includes devDependencies
    volumes:
      - .:/app
      - /app/node_modules    # preserve container's node_modules
    environment:
      NODE_ENV: development
    ports:
      - "9229:9229"          # Node debugger
    command: npm run dev
```

---

## 5. Common Pitfalls

| Pitfall | Symptom | Fix |
|---|---|---|
| `COPY . .` before `RUN npm ci` | Cache busted on every code change | Copy `package*.json` first, then source |
| `apt-get update` in separate `RUN` | Stale package lists on rebuild | Combine update + install + cleanup in one `RUN` |
| Running as root | Security scan failures | `adduser` + `USER 1001` in Dockerfile |
| `ENV SECRET=...` for secrets | Secret baked into image layers | Use `--mount=type=secret` or runtime env injection |
| No `.dockerignore` | Huge build context, slow builds | Add `.dockerignore` before first `docker build` |
| `depends_on` without health check | Race condition: app starts before db ready | Add `healthcheck:` to db + `condition: service_healthy` |
| Package manager cache in image | 50-200MB of wasted cache in final layer | Use `--mount=type=cache` or clean cache in same `RUN` |
