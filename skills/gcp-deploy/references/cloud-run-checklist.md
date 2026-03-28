# Cloud Run Deployment Checklist

## Pre-Deploy

- [ ] Dockerfile builds and runs locally: `docker build -t test . && docker run -p 8080:8080 test`
- [ ] Health endpoint exists and returns 200: `GET /health`
- [ ] No hardcoded secrets — all via environment variables
- [ ] `.dockerignore` excludes: `node_modules`, `.env`, `.git`, `*.log`
- [ ] `package.json` has `"start"` script (Node.js) or `CMD` in Dockerfile
- [ ] Application listens on `$PORT` (Cloud Run sets this, default 8080)

## Secrets

- [ ] All API keys/tokens created in Secret Manager
- [ ] Service account has `secretmanager.secretAccessor` role
- [ ] Secrets referenced via `--set-secrets` in deploy command
- [ ] `.env.example` file documents all required variables (no real values)

## Deploy

```bash
# Set project
gcloud config set project PROJECT_ID

# Build
gcloud builds submit --tag gcr.io/PROJECT_ID/SERVICE:$(git rev-parse --short HEAD)

# Deploy
gcloud run deploy SERVICE \
  --image gcr.io/PROJECT_ID/SERVICE:$(git rev-parse --short HEAD) \
  --region europe-west2 \
  --memory 512Mi \
  --cpu 1 \
  --min-instances 0 \
  --max-instances 5 \
  --timeout 300 \
  --concurrency 80 \
  --set-secrets "KEY1=secret1:latest,KEY2=secret2:latest" \
  --no-allow-unauthenticated  # Default: private. Add --allow-unauthenticated only for webhooks
```

## Post-Deploy

- [ ] Service URL is accessible: `curl https://SERVICE-HASH-nw.a.run.app/health`
- [ ] Test with real (or realistic) payload
- [ ] Cloud Logging shows expected log output: `gcloud logging read "resource.type=cloud_run_revision"`
- [ ] Error Reporting is clean (no unexpected errors)
- [ ] Set up uptime monitoring (Cloud Monitoring or UptimeRobot)
- [ ] Document the service URL in project README

## Rollback

```bash
# List revisions
gcloud run revisions list --service SERVICE --region europe-west2

# Route traffic to previous revision
gcloud run services update-traffic SERVICE \
  --to-revisions PREVIOUS_REVISION=100 \
  --region europe-west2
```

## Cleanup

```bash
# Delete old images (keep last 5)
gcloud container images list-tags gcr.io/PROJECT_ID/SERVICE \
  --sort-by=TIMESTAMP --limit=999 --format='get(digest)' \
  | tail -n +6 \
  | xargs -I{} gcloud container images delete gcr.io/PROJECT_ID/SERVICE@{} --quiet
```
