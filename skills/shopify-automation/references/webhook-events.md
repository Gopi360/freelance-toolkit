# Shopify Webhook Events

## Most Used Topics

| Topic | Fires When | Common Use |
|---|---|---|
| `orders/create` | New order placed | Order processing, CRM sync, notifications |
| `orders/updated` | Order modified | Status tracking, fulfilment updates |
| `orders/paid` | Payment confirmed | Trigger fulfilment, send confirmation |
| `orders/cancelled` | Order cancelled | Refund processing, inventory restore |
| `carts/create` | Cart created | Abandoned cart tracking |
| `carts/update` | Cart modified | Cart value monitoring |
| `customers/create` | New customer | CRM sync, welcome sequences |
| `products/update` | Product changed | Inventory sync, feed updates |
| `refunds/create` | Refund issued | Finance tracking, support alerts |
| `fulfillments/create` | Item shipped | Shipping notifications |

## Webhook Registration

```bash
# Via API
POST /admin/api/2024-10/webhooks.json
{
  "webhook": {
    "topic": "orders/create",
    "address": "https://your-n8n.com/webhook/shopify-orders",
    "format": "json"
  }
}
```

## Payload Structure (orders/create example)

```json
{
  "id": 123456789,
  "name": "#1001",
  "email": "customer@example.com",
  "created_at": "2024-01-15T10:30:00Z",
  "total_price": "99.99",
  "currency": "GBP",
  "financial_status": "paid",
  "fulfillment_status": null,
  "customer": {
    "id": 987654321,
    "email": "customer@example.com",
    "first_name": "John",
    "last_name": "Doe"
  },
  "line_items": [
    {
      "id": 111,
      "title": "Product Name",
      "quantity": 1,
      "price": "99.99",
      "sku": "SKU-001"
    }
  ],
  "shipping_address": {
    "city": "London",
    "country": "United Kingdom",
    "country_code": "GB"
  },
  "tags": ""
}
```

## Important Notes

- Webhooks have a 5-second timeout — respond quickly and process async
- Shopify retries failed webhooks (non-2xx) up to 19 times over 48 hours
- After 19 consecutive failures, the webhook is automatically deleted
- Always verify the HMAC signature before processing
- Webhook payloads can be large (especially orders with many line items)
