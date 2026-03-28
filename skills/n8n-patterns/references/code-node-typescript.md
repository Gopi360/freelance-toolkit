# Code Node TypeScript Patterns

## Configuration

- Always set Language to "TypeScript" in the Code node settings
- Mode: "Run Once for All Items" (default) for batch processing
- Mode: "Run Once for Each Item" for independent item processing

## Input/Output Contract

```typescript
// ALWAYS validate input existence
const items = $input.all();
if (!items.length) {
  throw new Error('No input items received');
}

// ALWAYS return an array of objects with { json: {...} } shape
return items.map(item => ({
  json: {
    ...item.json,
    processed: true,
  }
}));
```

## Common Patterns

### Field Validation & Sanitisation
```typescript
interface LeadData {
  email?: string;
  phone?: string;
  name?: string;
  source?: string;
}

const items = $input.all();
const valid: any[] = [];
const invalid: any[] = [];

for (const item of items) {
  const data = item.json as LeadData;

  // Require email or phone
  if (!data.email && !data.phone) {
    invalid.push({ json: { error: 'Missing email and phone', original: data } });
    continue;
  }

  valid.push({
    json: {
      email: data.email?.toLowerCase().trim() || null,
      phone: data.phone?.replace(/[^+\d]/g, '') || null,
      name: data.name?.trim() || 'Unknown',
      source: data.source || 'direct',
      validated_at: new Date().toISOString(),
    }
  });
}

// Output 0: valid items, Output 1: invalid items
// (Configure Code node with 2 outputs)
return [valid, invalid];
```

### API Response Parsing
```typescript
const items = $input.all();

return items.map(item => {
  const response = item.json;

  // Handle different API response shapes
  if (response.error) {
    return {
      json: {
        success: false,
        error_message: response.error.message || response.error,
        error_code: response.error.code || 'UNKNOWN',
      }
    };
  }

  // Extract data from nested response
  const data = response.data || response.result || response;

  return {
    json: {
      success: true,
      id: data.id,
      status: data.status,
      raw_response: data,
    }
  };
});
```

### LLM Response Parsing (OpenAI/Gemini)
```typescript
const items = $input.all();

return items.map(item => {
  const response = item.json;

  // OpenAI format
  if (response.choices) {
    const content = response.choices[0]?.message?.content || '';

    // Try to parse as JSON if expected
    try {
      const parsed = JSON.parse(content);
      return { json: { success: true, parsed, raw: content } };
    } catch {
      return { json: { success: true, text: content, is_json: false } };
    }
  }

  // Gemini format
  if (response.candidates) {
    const content = response.candidates[0]?.content?.parts?.[0]?.text || '';

    try {
      // Gemini sometimes wraps JSON in markdown code blocks
      const cleaned = content.replace(/```json\n?/g, '').replace(/```\n?/g, '').trim();
      const parsed = JSON.parse(cleaned);
      return { json: { success: true, parsed, raw: content } };
    } catch {
      return { json: { success: true, text: content, is_json: false } };
    }
  }

  return { json: { success: false, error: 'Unknown AI response format', raw: response } };
});
```

### Date/Time Handling
```typescript
// Always work with ISO strings and convert at the edges
const items = $input.all();

return items.map(item => {
  const data = item.json;

  // Parse various date formats
  const dateStr = data.date || data.created_at || data.timestamp;
  const date = new Date(dateStr);

  if (isNaN(date.getTime())) {
    return { json: { ...data, date_error: `Invalid date: ${dateStr}` } };
  }

  return {
    json: {
      ...data,
      date_iso: date.toISOString(),
      date_human: date.toLocaleDateString('en-GB', {
        day: '2-digit', month: 'short', year: 'numeric'
      }),
      days_ago: Math.floor((Date.now() - date.getTime()) / (1000 * 60 * 60 * 24)),
    }
  };
});
```

### Batching / Chunking for Rate-Limited APIs
```typescript
const items = $input.all();
const BATCH_SIZE = 10;
const batches: any[] = [];

for (let i = 0; i < items.length; i += BATCH_SIZE) {
  const batch = items.slice(i, i + BATCH_SIZE);
  batches.push({
    json: {
      batch_index: Math.floor(i / BATCH_SIZE),
      batch_size: batch.length,
      items: batch.map(b => b.json),
    }
  });
}

return batches;
```

### Deduplication
```typescript
const items = $input.all();
const seen = new Set<string>();
const unique: any[] = [];

for (const item of items) {
  const key = item.json.email || item.json.id; // Choose dedup key
  if (!key || seen.has(key)) continue;
  seen.add(key);
  unique.push(item);
}

return unique;
```

## Anti-Patterns to Avoid

1. **Don't use `any` everywhere** — Define interfaces for your data shapes
2. **Don't skip validation** — Always check for required fields before processing
3. **Don't swallow errors** — Let errors propagate so the Error Trigger catches them
4. **Don't use `setTimeout`/`setInterval`** — n8n Code nodes are synchronous executors
5. **Don't import external packages** — Code nodes don't support npm imports (use HTTP Request for APIs)
6. **Don't return non-array values** — Always return `[{ json: {...} }]` format

## Accessing n8n Built-ins

```typescript
// Environment variables
const apiKey = $env.GHL_API_KEY;

// Previous node data
const prevData = $('Previous Node Name').first().json;

// Workflow static data (persists across executions)
const staticData = $getWorkflowStaticData('global');
staticData.lastRun = new Date().toISOString();

// Execution metadata
const executionId = $execution.id;
const workflowId = $workflow.id;
const workflowName = $workflow.name;
```
