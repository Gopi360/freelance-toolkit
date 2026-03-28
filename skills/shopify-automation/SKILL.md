---
name: shopify-automation
description: >
  Shopify API integration patterns, webhook handling, order automation,
  and e-commerce data pipelines. Use when building Shopify integrations,
  processing orders, syncing inventory, automating abandoned cart flows,
  or connecting Shopify to other services via n8n or custom code.
---

# Shopify Automation Patterns

## When This Skill Applies

Use this skill whenever the task involves:
- Shopify Admin API or Storefront API integrations
- Webhook handling for Shopify events
- Order processing, inventory sync, or fulfilment automation
- Abandoned cart recovery workflows
- Shopify + AI (product descriptions, analytics, customer insights)
- Connecting Shopify to GHL, n8n, or other services

## API Authentication

### Private App (Custom App)
```
Header: X-Shopify-Access-Token: {{$env.SHOPIFY_ACCESS_TOKEN}}
Base URL: https://{{store}}.myshopify.com/admin/api/2024-10/
```

### Required Scopes (request only what's needed)
- Orders: `read_orders`, `write_orders`
- Products: `read_products`, `write_products`
- Customers: `read_customers`, `write_customers`
- Inventory: `read_inventory`, `write_inventory`

## Common Patterns

### Order Processing Pipeline (n8n)
```
Webhook: orders/create
  → Respond to Webhook (200)
  → Code: Validate & Extract Order Data
  → IF: High Value Order (>$500)?
    → YES: Slack Notification + Tag in CRM
  → IF: Contains Subscription Product?
    → YES: HTTP Request: Create subscription in billing system
  → HTTP Request: Update order tags in Shopify
  → Code: Log order summary
```

### Abandoned Cart Recovery (n8n)
```
Webhook: carts/create or carts/update
  → Code: Extract cart details (email, items, value)
  → Wait: 1 hour
  → HTTP Request: Check if order was completed (search orders by email)
  → IF: Order exists?
    → YES: No action (cart converted)
    → NO:
      → IF: Cart value > $50?
        → YES: HTTP Request: Send recovery email/SMS via GHL
        → NO: Code: Log abandoned cart for analytics
```

### Product Data Enrichment with AI
```
Schedule: Daily
  → HTTP Request: GET products without descriptions (or with tag "needs-description")
  → Loop: For each product
    → HTTP Request: POST to Gemini API (generate SEO description)
    → HTTP Request: PUT update product description in Shopify
    → Wait: 500ms (rate limit)
```

## Webhook Verification

```typescript
import { createHmac } from 'crypto';

const items = $input.all();
return items.map(item => {
  const hmac = item.json.headers?.['x-shopify-hmac-sha256'] || '';
  const body = item.json.rawBody || JSON.stringify(item.json.body);
  const secret = $env.SHOPIFY_WEBHOOK_SECRET;

  const computed = createHmac('sha256', secret)
    .update(body, 'utf8')
    .digest('base64');

  return {
    json: {
      verified: hmac === computed,
      ...item.json.body,
    }
  };
});
```

## Rate Limits

- REST Admin API: 2 requests/second per app (bucket: 40, leak: 2/s)
- GraphQL Admin API: 1000 cost points/second
- Handle `429 Too Many Requests` with exponential backoff
- Use `Retry-After` header value when present

## Key API Endpoints

See `references/api-patterns.md` for detailed request/response examples.
See `references/webhook-events.md` for all webhook topics and payloads.

## Environment Variables

```
SHOPIFY_STORE=           # store-name (without .myshopify.com)
SHOPIFY_ACCESS_TOKEN=    # Admin API access token
SHOPIFY_WEBHOOK_SECRET=  # Webhook verification secret
```
