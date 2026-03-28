# [Project Name]

> One-line description of what this system does.

Built by [Mit](mailto:souhardyabiswas02@gmail.com) for [Client Name].

## What It Does

[2-3 sentences explaining the system in plain English. Written for the client,
not for developers. Example: "This system automatically qualifies leads from
your Instagram DMs, scores them based on budget and timeline, and books
discovery calls on your calendar — all without manual intervention."]

## Architecture Overview

```
[Simple flow diagram — adjust to match the actual project]

Instagram DM → n8n Webhook → AI Qualification → GoHighLevel
                                                    ├── Hot Lead → Book Calendar
                                                    ├── Warm Lead → Nurture Sequence
                                                    └── Cold Lead → Tag & Close
```

## Prerequisites

Before setup, you'll need:

- [ ] [Service 1] account with API access (e.g., GoHighLevel)
- [ ] [Service 2] account (e.g., OpenAI)
- [ ] [Service 3] access (e.g., Instagram Business account)
- [ ] n8n instance (cloud or self-hosted)

## Setup Instructions

### Step 1: Environment Variables

Copy `.env.example` to `.env` and fill in your values:

```bash
cp .env.example .env
```

| Variable | Description | Where to Find |
|---|---|---|
| `GHL_API_KEY` | GoHighLevel API key | GHL → Settings → Business Profile → API Key |
| `OPENAI_API_KEY` | OpenAI API key | platform.openai.com → API Keys |
| `GHL_CALENDAR_ID` | Calendar for bookings | GHL → Calendars → Settings → Calendar ID |
| `GHL_PIPELINE_ID` | Sales pipeline ID | GHL → Opportunities → Pipeline Settings |
| `WEBHOOK_SECRET` | Webhook verification secret | Generate: `openssl rand -hex 32` |

### Step 2: Import n8n Workflows

1. Open your n8n instance
2. Go to Workflows → Import from File
3. Import each file from the `n8n-workflows/` directory:
   - `main-workflow.json` — The main automation flow
   - `error-handler.json` — Error notification workflow
4. In each workflow, update the environment variables via n8n Settings → Variables

### Step 3: Activate

1. Activate the **Error Handler** workflow first
2. Then activate the **Main Workflow**
3. The webhook URL will appear on the Webhook node — copy it

### Step 4: Connect the Trigger

[Platform-specific instructions, e.g.:]
- Go to [Platform] → Settings → Webhooks
- Add the webhook URL from Step 3
- Select the events: [list events]
- Save and test

## Testing

### Quick Test

```bash
curl -X POST https://your-n8n.com/webhook/[path] \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "I am interested in your service"
  }'
```

Expected: You should see a new contact in GHL tagged with "ai-qualified".

### Full Test Checklist

- [ ] Send a "hot lead" message → should book a call
- [ ] Send a "not interested" message → should tag as cold and close
- [ ] Send an empty message → should handle gracefully
- [ ] Disconnect the AI API temporarily → error alert should fire

## Monitoring

- **Error alerts**: Sent to [Slack channel / email] when any workflow fails
- **n8n dashboard**: Check execution history at [n8n URL] → Executions
- **Logs**: [Cloud Logging URL if applicable]

## Troubleshooting

| Problem | Likely Cause | Fix |
|---|---|---|
| Webhook not receiving events | Webhook URL changed after workflow restart | Re-copy URL from n8n and update in [Platform] |
| AI responses are slow/timing out | OpenAI/Gemini API latency | Check API status page; timeout is set to 120s |
| Contacts not appearing in GHL | Invalid API key or rate limit | Verify `GHL_API_KEY` in env vars; check n8n execution logs |
| Error alerts not sending | Error handler workflow not active | Activate the Error Handler workflow in n8n |

## Maintenance

- **Monthly**: Check that API keys haven't expired or been rotated
- **Quarterly**: Review AI prompt for accuracy — update if client's offers change
- **As needed**: If client adds new services/products, update the qualification criteria

## Support

For issues or changes, contact:
- **Mit**: [souhardyabiswas02@gmail.com]
- **Response time**: Within 24 hours on business days
- **Support period**: [X weeks] of bug fixes included with this delivery

---

*Last updated: [DATE]*
