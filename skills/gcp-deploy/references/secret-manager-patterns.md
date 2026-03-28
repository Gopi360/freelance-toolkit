# Secret Manager Patterns

## Quick Reference

```bash
# Create secret
echo -n "value" | gcloud secrets create SECRET_NAME --data-file=-

# Read secret
gcloud secrets versions access latest --secret=SECRET_NAME

# Update secret
echo -n "new-value" | gcloud secrets versions add SECRET_NAME --data-file=-

# List all secrets
gcloud secrets list

# Grant access to Cloud Run service account
gcloud secrets add-iam-policy-binding SECRET_NAME \
  --member="serviceAccount:PROJECT_NUM-compute@developer.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"
```

## Naming Convention

```
{client}-{service}-{key-type}
```
Examples:
- `acme-ai-setter-openai-key`
- `acme-ai-setter-ghl-api-key`
- `brandx-shopify-webhook-secret`

## Accessing in Code

### Node.js
```javascript
const { SecretManagerServiceClient } = require('@google-cloud/secret-manager');
const client = new SecretManagerServiceClient();

async function getSecret(name) {
  const [version] = await client.accessSecretVersion({
    name: `projects/PROJECT_ID/secrets/${name}/versions/latest`,
  });
  return version.payload.data.toString();
}
```

### Python
```python
from google.cloud import secretmanager

def get_secret(secret_id: str, project_id: str) -> str:
    client = secretmanager.SecretManagerServiceClient()
    name = f"projects/{project_id}/secrets/{secret_id}/versions/latest"
    response = client.access_secret_version(request={"name": name})
    return response.payload.data.decode("UTF-8")
```

### Cloud Run (preferred — mount as env var)
```bash
gcloud run deploy SERVICE \
  --set-secrets "OPENAI_API_KEY=openai-key:latest,GHL_API_KEY=ghl-key:latest"
```
Then access as normal env vars: `process.env.OPENAI_API_KEY`

## Security Rules

- NEVER commit `.env` files with real values to Git
- NEVER log secret values (even accidentally in error messages)
- ALWAYS use `.env.example` with placeholder values
- Rotate keys quarterly or immediately if compromised
- Use separate secrets per environment (dev/staging/prod)
