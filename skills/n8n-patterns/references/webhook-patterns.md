# Webhook Patterns Reference

## Webhook Security

### HMAC Signature Verification (Code Node)
```typescript
import { createHmac } from 'crypto';

const items = $input.all();
const result = [];

for (const item of items) {
  const signature = item.json.headers?.['x-signature'] ||
                    item.json.headers?.['x-hub-signature-256'] || '';
  const body = JSON.stringify(item.json.body);
  const secret = $env.WEBHOOK_SECRET;

  const expected = 'sha256=' + createHmac('sha256', secret)
    .update(body)
    .digest('hex');

  if (signature !== expected) {
    // Log but don't process — prevents replay attacks
    console.log('Invalid webhook signature, rejecting');
    result.push({ json: { valid: false, reason: 'invalid_signature' } });
    continue;
  }

  result.push({ json: { valid: true, ...item.json.body } });
}

return result;
```

### IP Whitelisting
For high-security webhooks, validate source IP in the first Code node:
```typescript
const ALLOWED_IPS = ['52.89.214.238', '34.228.4.208']; // Example: Shopify IPs
const sourceIp = $input.first().json.headers?.['x-forwarded-for']?.split(',')[0]?.trim();

if (!ALLOWED_IPS.includes(sourceIp || '')) {
  throw new Error(`Rejected request from unauthorized IP: ${sourceIp}`);
}
```

## Webhook Response Patterns

### Immediate Acknowledgment (async processing)
```
Webhook Node
  → Respond to Webhook Node
      HTTP Code: 200
      Body: { "status": "received", "id": "{{$json.id}}" }
  → [continue processing in background]
```

### Conditional Response
```
Webhook Node
  → Code: Validate
  → IF: Valid?
    → YES → Process → Respond to Webhook (200)
    → NO → Respond to Webhook (400, error details)
```

### Retry-Safe Webhooks (idempotency)
```typescript
// Code node: Check if we've already processed this event
const eventId = $input.first().json.headers?.['x-event-id'] ||
                $input.first().json.body?.event_id;

if (!eventId) {
  throw new Error('No event ID found — cannot guarantee idempotency');
}

// Use n8n's built-in static data for simple dedup
const processed = $getWorkflowStaticData('global');
if (processed[eventId]) {
  // Already processed — skip silently
  return [];
}

// Mark as processed (persist for 24h via cleanup job)
processed[eventId] = Date.now();

return $input.all();
```

## Webhook Testing

### Using curl for Testing
```bash
# Basic webhook test
curl -X POST https://your-n8n.com/webhook/path \
  -H "Content-Type: application/json" \
  -d '{"name": "Test User", "email": "test@example.com", "phone": "+447123456789"}'

# With HMAC signature
BODY='{"event": "test"}'
SIG=$(echo -n "$BODY" | openssl dgst -sha256 -hmac "your-secret" | awk '{print "sha256="$2}')
curl -X POST https://your-n8n.com/webhook/path \
  -H "Content-Type: application/json" \
  -H "x-signature: $SIG" \
  -d "$BODY"
```

### Using n8n Test Webhook
- Click "Listen for test event" on the Webhook node
- Send a test payload via curl or Postman
- n8n captures the payload and makes it available for downstream nodes
- Always test with realistic data shapes, including edge cases (missing fields, special characters)

## Common Webhook Sources

### Shopify Webhooks
- Verify via `X-Shopify-Hmac-SHA256` header
- Topics: `orders/create`, `orders/updated`, `products/update`, `carts/create`
- Body is JSON, nested under topic-specific keys

### GoHighLevel Webhooks
- Configure in GHL → Settings → Webhooks
- Events: `contact.created`, `opportunity.stageChanged`, `appointment.booked`
- Auth: validate via shared secret or API key in custom header

### Instagram / Meta Webhooks
- Verify via `X-Hub-Signature-256` header with app secret
- Requires verification challenge endpoint (GET with `hub.verify_token`)
- Events: `messages`, `messaging_postbacks`, `feed`
