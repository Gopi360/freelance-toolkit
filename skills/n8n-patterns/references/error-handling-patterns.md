# Error Handling Patterns

## Mandatory Error Workflow

Every production workflow MUST have a paired Error Trigger workflow.

### Naming Convention
- Main workflow: `[Client] Lead Qualifier`
- Error workflow: `[Client] Lead Qualifier — Error Handler`

### Error Trigger Workflow Template

```
Error Trigger
  → Code: Format Error Details
  → IF: Severity = Critical?
    → YES: Slack Message (to #alerts channel) + Email to Mit
    → NO: Slack Message (to #monitoring channel)
```

### Error Formatting Code Node
```typescript
const error = $input.first().json;

// Extract useful error info
const errorDetails = {
  workflow_name: error.workflow?.name || 'Unknown',
  workflow_id: error.workflow?.id || 'Unknown',
  execution_id: error.execution?.id || 'Unknown',
  execution_url: error.execution?.url || '',
  node_name: error.execution?.lastNodeExecuted || 'Unknown',
  error_message: error.execution?.error?.message || 'No error message',
  error_stack: error.execution?.error?.stack || '',
  timestamp: new Date().toISOString(),
  severity: 'high', // Default — override based on workflow type
};

// Determine severity
const criticalWorkflows = ['payment', 'booking', 'order'];
const isCritical = criticalWorkflows.some(kw =>
  errorDetails.workflow_name.toLowerCase().includes(kw)
);
errorDetails.severity = isCritical ? 'critical' : 'high';

// Format Slack message
const slackMessage = [
  isCritical ? '🔴 *CRITICAL ERROR*' : '🟡 *Workflow Error*',
  `*Workflow:* ${errorDetails.workflow_name}`,
  `*Node:* ${errorDetails.node_name}`,
  `*Error:* ${errorDetails.error_message}`,
  `*Time:* ${errorDetails.timestamp}`,
  errorDetails.execution_url ? `<${errorDetails.execution_url}|View Execution>` : '',
].filter(Boolean).join('\n');

return [{
  json: {
    ...errorDetails,
    slack_message: slackMessage,
  }
}];
```

## Node-Level Error Handling

### Continue on Fail
- Set "Continue on Fail" on non-critical nodes (e.g., logging, notifications)
- NEVER set on data-critical nodes (API calls that must succeed)

### Retry on Fail
- Set "Retry on Fail" for API calls to external services
- Max retries: 3
- Wait between retries: 1000ms (1 second)
- Good for: transient network errors, rate limits

### IF Node for Error Checking
After any HTTP Request, always check the response:
```
HTTP Request: Call External API
  → IF: {{ $json.statusCode >= 400 || $json.error }}
    → YES (error path): Code: Log Error → Slack Notification
    → NO (success path): Continue processing
```

## Rate Limit Handling

### GHL Rate Limits (429 Responses)
```
HTTP Request: GHL API Call
  → IF: Status = 429?
    → YES: Wait Node (10 seconds) → HTTP Request: Retry GHL API Call
    → NO: Continue
```

### Bulk API Calls with Backoff
```
SplitInBatches (batch size: 5)
  → HTTP Request: API Call
  → Wait Node (1 second between batches)
  → SplitInBatches (loop back)
```

## Timeout Handling

### For AI/LLM Calls
- Set HTTP Request timeout to 120 seconds (Gemini can be slow)
- Add a fallback path: if timeout → queue for retry or flag for human

### For Webhook Responses
- Respond to webhook within 5 seconds to avoid client-side timeouts
- Use async pattern: respond immediately, process in background

## Monitoring & Alerting Checklist

For every client deployment:
1. ✅ Error Trigger workflow created and linked
2. ✅ Slack channel for alerts (or email notification)
3. ✅ Critical workflows flagged for immediate notification
4. ✅ Retry-on-fail enabled for external API calls (max 3)
5. ✅ Timeouts set appropriately (60s standard, 120s for AI)
6. ✅ Test the error path — intentionally trigger an error to verify alerts work
