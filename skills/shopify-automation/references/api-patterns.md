# Shopify API Patterns

## Orders

### Get Orders
```
GET /admin/api/2024-10/orders.json?status=any&limit=50
```

### Get Single Order
```
GET /admin/api/2024-10/orders/{order_id}.json
```

### Update Order Tags
```
PUT /admin/api/2024-10/orders/{order_id}.json
{ "order": { "tags": "vip, processed, ai-enriched" } }
```

### Search Orders by Email
```
GET /admin/api/2024-10/orders.json?email=customer@example.com&status=any
```

## Products

### Get Products
```
GET /admin/api/2024-10/products.json?limit=50&fields=id,title,body_html,tags
```

### Update Product
```
PUT /admin/api/2024-10/products/{product_id}.json
{
  "product": {
    "body_html": "<p>AI-generated description</p>",
    "tags": "ai-described, seo-optimised"
  }
}
```

## Customers

### Search Customer
```
GET /admin/api/2024-10/customers/search.json?query=email:customer@example.com
```

### Create Customer
```
POST /admin/api/2024-10/customers.json
{
  "customer": {
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "tags": "ai-lead, instagram"
  }
}
```

## Inventory

### Get Inventory Levels
```
GET /admin/api/2024-10/inventory_levels.json?location_ids=LOC_ID
```

### Adjust Inventory
```
POST /admin/api/2024-10/inventory_levels/adjust.json
{
  "location_id": LOC_ID,
  "inventory_item_id": ITEM_ID,
  "available_adjustment": -1
}
```

## GraphQL (preferred for complex queries)

```graphql
{
  orders(first: 10, query: "created_at:>2024-01-01") {
    edges {
      node {
        id
        name
        totalPriceSet { shopMoney { amount currencyCode } }
        customer { email firstName }
        lineItems(first: 5) {
          edges { node { title quantity } }
        }
      }
    }
  }
}
```

## Pagination

Shopify uses cursor-based pagination via `Link` header:
```typescript
// Code node: Follow pagination
let url = `https://${$env.SHOPIFY_STORE}.myshopify.com/admin/api/2024-10/orders.json?limit=250`;
const allOrders: any[] = [];

// In practice, use n8n's HTTP Request node in a loop
// Check for Link header with rel="next" to continue
```
