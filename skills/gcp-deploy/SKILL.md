---
name: gcp-deploy
description: >
  GCP Cloud Run deployment patterns, Terraform templates, Secret Manager,
  Docker containerisation, and infrastructure setup. Use when deploying
  services, APIs, or automation backends to Google Cloud Platform. Covers
  Cloud Run, Cloud Build, Secret Manager, Cloud Scheduler, and IAM setup.
---

# GCP Deployment Patterns

## When This Skill Applies

Use this skill whenever the task involves:
- Deploying a service/API to GCP Cloud Run
- Managing secrets via Secret Manager
- Setting up Docker containers for deployment
- Configuring Cloud Scheduler for cron jobs
- Writing Terraform for GCP infrastructure
- Setting up CI/CD with Cloud Build

## Default Configuration

- **Region**: `europe-west2` (London) — closest to UK clients
- **Min instances**: 0 (scale to zero for cost savings)
- **Max instances**: 5 (prevents runaway costs)
- **Memory**: 512Mi default, 1Gi for AI/LLM workloads
- **CPU**: 1 default, 2 for AI workloads
- **Timeout**: 300s default, 900s for long-running AI tasks
- **Concurrency**: 80 (default)

## Deployment Checklist

See `references/cloud-run-checklist.md` for the full checklist.

Quick deploy:
```bash
# 1. Build and push image
gcloud builds submit --tag gcr.io/PROJECT_ID/SERVICE_NAME:$(git rev-parse --short HEAD)

# 2. Deploy to Cloud Run
gcloud run deploy SERVICE_NAME \
  --image gcr.io/PROJECT_ID/SERVICE_NAME:$(git rev-parse --short HEAD) \
  --region europe-west2 \
  --memory 512Mi \
  --min-instances 0 \
  --max-instances 5 \
  --timeout 300 \
  --set-secrets "API_KEY=api-key:latest,DB_URL=db-url:latest" \
  --allow-unauthenticated  # Only for public webhooks!

# 3. Verify
curl -s https://SERVICE_NAME-HASH-nw.a.run.app/health
```

## Dockerfile Template

```dockerfile
FROM node:20-slim AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

FROM node:20-slim
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package.json ./

# Cloud Run sets PORT env var
ENV PORT=8080
EXPOSE 8080

# Use non-root user
USER node

CMD ["node", "dist/index.js"]
```

For Python:
```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .

ENV PORT=8080
EXPOSE 8080

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8080"]
```

## Secret Manager

```bash
# Create a secret
echo -n "sk-abc123" | gcloud secrets create API_KEY --data-file=-

# Grant Cloud Run access
gcloud secrets add-iam-policy-binding API_KEY \
  --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Reference in Cloud Run deploy
gcloud run deploy SERVICE \
  --set-secrets "API_KEY=API_KEY:latest"
```

## Cloud Scheduler (Cron Jobs)

```bash
# Trigger a Cloud Run service every hour
gcloud scheduler jobs create http CRON_JOB_NAME \
  --schedule="0 * * * *" \
  --uri="https://SERVICE-URL/cron/sync" \
  --http-method=POST \
  --oidc-service-account-email=SCHEDULER_SA@PROJECT.iam.gserviceaccount.com \
  --location=europe-west2
```

## Terraform Templates

See `references/terraform-templates.md` for reusable Terraform modules.

## Cost Estimates

| Configuration | Approx Cost/Month |
|---|---|
| Scale-to-zero, low traffic (<1000 req/day) | $0-5 |
| Always-on (min 1 instance), moderate traffic | $15-30 |
| AI workload (1Gi RAM, 2 CPU, moderate traffic) | $25-50 |
| High traffic (5 instances, 1Gi each) | $50-100 |

Free tier: 2 million requests/month, 360,000 GB-seconds of memory.

## Non-Negotiable Rules

- NEVER expose service account keys in code or environment variables
- NEVER use `--allow-unauthenticated` for internal services
- ALWAYS tag images with git SHA, never `:latest` in production
- ALWAYS set `--max-instances` to prevent runaway costs
- ALWAYS use Secret Manager for API keys and tokens
- ALWAYS add a `/health` endpoint that returns 200
