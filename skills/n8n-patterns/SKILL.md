---
name: n8n-patterns
description: >
  n8n workflow architecture patterns, TypeScript Code node standards, error
  handling, and API integration templates. Use when building, debugging,
  reviewing, or planning any n8n workflow, automation pipeline, or service
  integration. Covers GoHighLevel (GHL), Shopify, OpenAI, Gemini, Instagram,
  webhook patterns, scheduled jobs, and multi-step automations.
---

# n8n Workflow Patterns

## When This Skill Applies

Use this skill whenever the task involves:
- Building or modifying an n8n workflow
- Integrating APIs via n8n (GHL, Shopify, OpenAI, Gemini, Slack, etc.)
- Debugging a failing n8n workflow or node
- Designing an automation pipeline architecture
- Writing or reviewing n8n Code node logic

## Core Principles

1. **Async over sync for AI calls** — Never block a webhook response waiting for an LLM.
   Respond 200 immediately, process in background, callback when done.
2. **Validate early** — First node after any trigger should validate the incoming data shape.
3. **Error workflows are mandatory** — Every production workflow needs a paired Error Trigger workflow.
4. **TypeScript only** — All Code nodes use TypeScript mode. No JavaScript.
5. **`$env` for secrets** — Never hardcode API keys. Use n8n environment variables.
6. **Descriptive node names** — "Validate Lead Payload", not "Code1" or "IF".

## Architecture Patterns

### Pattern 1: Sync Webhook (fast, <5s response)

```
Webhook (POST)
  → Code: Validate Payload
  → IF: Valid?
    → YES: Code: Transform Data → HTTP Request: External API → Respond to Webhook (200 + result)
    → NO: Respond to Webhook (400 + error message)
```

Use when: Client expects an immediate response (form submission confirmations, simple lookups).

### Pattern 2: Async Webhook (AI/slow processing)

```
Webhook (POST)
  → Respond to Webhook (200, {"status": "processing"})
  → Code: Validate & Transform
  → HTTP Request: AI API (timeout: 120s)
  → IF: AI Success?
    → YES: HTTP Request: Callback/GHL Update
    → NO: Code: Format Error → Slack Notification
```

Use when: Processing involves LLM calls, heavy computation, or external APIs with >5s latency.
This is the default pattern for AI setter/chatbot workflows.

### Pattern 3: Scheduled ETL

```
Schedule Trigger (cron)
  → HTTP Request: Fetch Data from Source API
  → Code: Transform & Clean
  → IF: Data Changed?
    → YES: HTTP Request: Push to Destination (BigQuery/Sheets/GHL)
    → NO: No Operation
  → Code: Log Summary
```

Use when: Periodic data sync, report generation, monitoring dashboards.

### Pattern 4: Event-Driven Chain

```
Webhook: Receive Event (e.g., Shopify order)
  → Respond to Webhook (200)
  → Switch: Event Type
    → order.created: [sub-workflow for new orders]
    → order.updated: [sub-workflow for updates]
    → order.cancelled: [sub-workflow for cancellations]
    → default: Code: Log Unknown Event
```

Use when: Handling multiple event types from a single webhook source.

## Code Node Standards

For detailed TypeScript patterns and reusable snippets, see `references/code-node-typescript.md`.

Key rules:
- Always validate input existence before accessing properties
- Always return an array of items, even for single outputs
- Use try/catch for any operation that can fail
- Log meaningful messages with `console.log()` for debugging

Quick template:
```typescript
// Validate input
const items = $input.all();
if (!items.length) throw new Error('No input items received');

const results = [];

for (const item of items) {
  const data = item.json;

  // Validate required fields
  if (!data.email) {
    results.push({ json: { error: 'Missing email', original: data } });
    continue;
  }

  // Transform
  results.push({
    json: {
      email: data.email.toLowerCase().trim(),
      name: data.name || 'Unknown',
      processed_at: new Date().toISOString(),
    }
  });
}

return results;
```

## Error Handling

Every production workflow needs error handling. See `references/error-handling-patterns.md`
for the full error workflow template.

Minimum requirements:
1. Paired Error Trigger workflow named `[Client] Error Handler`
2. Error notification via Slack or email within 5 minutes
3. Include: workflow name, node that failed, error message, timestamp
4. For webhook workflows: always respond before processing to avoid client-side timeouts

## GoHighLevel (GHL) Integration

See `references/ghl-api-reference.md` for complete API patterns.

Quick reference:
- API base: `https://rest.gohighlevel.com/v1/` (v1) or `https://services.leadconnectorhq.com/` (v2)
- Auth: `Authorization: Bearer {{$env.GHL_API_KEY}}`
- Rate limits: 100 requests/10 seconds — handle 429 with Wait node + retry
- Common endpoints: `/contacts/`, `/opportunities/`, `/calendars/services/`

## AI Integration

- HTTP Request to OpenAI/Gemini with timeout ≥ 60 seconds (120s preferred)
- Parse AI responses in a Code node — never use raw LLM output directly
- Add confidence scoring: if AI can't confidently answer → flag for human review
- Keep conversation history to last 10 messages for cost control
- Model selection: Gemini 2.5 Pro for analysis/structured tasks, GPT-4o for conversation
