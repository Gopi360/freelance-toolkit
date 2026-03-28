# AI Setter Flow — Complete Implementation

## Overview

An AI setter qualifies inbound leads via messaging (Instagram DM, WhatsApp, SMS)
and books discovery calls for the client's sales team via GoHighLevel.

## n8n Workflow Architecture

```
Webhook: Receive Message
  → Respond to Webhook (200)
  → Code: Extract Message Details
  → HTTP Request: GET GHL Contact (lookup by phone/email)
  → IF: Contact Exists?
    → YES: HTTP Request: GET Conversation History (last 10)
    → NO: HTTP Request: POST Create Contact in GHL
  → Code: Build LLM Prompt
  → HTTP Request: POST to OpenAI/Gemini
  → Code: Parse LLM Response (reply + actions)
  → IF: Action = "book_call"?
    → YES: HTTP Request: GET Available Slots → HTTP Request: POST Book Appointment
    → NO: (continue)
  → IF: Action = "tag_lead"?
    → YES: HTTP Request: POST Add Tags to Contact
  → IF: Action = "update_score"?
    → YES: HTTP Request: PUT Update Contact Custom Field
  → HTTP Request: POST Send Reply via Platform API
```

## Step-by-Step Code Nodes

### 1. Extract Message Details
```typescript
const items = $input.all();

return items.map(item => {
  const body = item.json.body || item.json;

  return {
    json: {
      contact_id: body.contactId || body.from?.id || '',
      contact_phone: body.phone || body.from?.phone || '',
      contact_email: body.email || '',
      contact_name: body.name || body.from?.name || 'there',
      message_text: body.message || body.text || body.body || '',
      platform: body.platform || body.source || 'unknown',
      timestamp: new Date().toISOString(),
    }
  };
});
```

### 2. Build LLM Prompt
```typescript
const currentMessage = $input.first().json;
const contact = $('Get GHL Contact').first().json;
const historyRaw = $('Get Conversation History').first().json;

// Parse conversation history
const history = Array.isArray(historyRaw.conversations)
  ? historyRaw.conversations
    .slice(-10) // Last 10 messages
    .map((msg: any) => ({
      role: msg.direction === 'inbound' ? 'user' : 'assistant',
      content: msg.body || msg.message || '',
    }))
  : [];

// Add current message
history.push({
  role: 'user',
  content: currentMessage.message_text,
});

const systemPrompt = `You are a friendly, professional AI assistant for [CLIENT_BRAND].
Your goal is to qualify leads and book discovery calls.

PERSONALITY:
- Warm but professional. Use the lead's first name.
- Keep responses under 3 sentences unless explaining something complex.
- Mirror the lead's communication style (casual if they're casual, formal if formal).

QUALIFICATION CRITERIA:
- Budget: Can they afford the service? (minimum $X/month)
- Timeline: Are they looking to start within 30 days?
- Decision maker: Are they the one who decides?
- Pain point: Do they have a clear problem the service solves?

SCORING:
- HOT (80-100): Budget confirmed + timeline < 30 days + decision maker → BOOK CALL
- WARM (50-79): Interested but missing 1-2 criteria → NURTURE
- COLD (0-49): Not a fit or not interested → POLITE CLOSE

RESPONSE FORMAT:
Always respond with valid JSON:
{
  "reply": "Your message to the lead",
  "actions": [
    {"type": "update_score", "value": 75},
    {"type": "tag_lead", "tags": ["interested", "budget-confirmed"]},
    {"type": "book_call", "reason": "Lead is hot, ready to book"}
  ],
  "internal_notes": "Brief notes about why you scored/acted this way"
}

RULES:
- NEVER discuss pricing specifics — say "our team will walk you through options"
- NEVER make promises about results
- If asked something you can't answer, say "Great question! [name] on our team can answer that in detail on the call"
- If the lead is hostile or clearly not interested, be polite and close gracefully
- ALWAYS include the "reply" and "actions" fields in your response`;

return [{
  json: {
    messages: [
      { role: 'system', content: systemPrompt },
      ...history,
    ],
    contact_id: currentMessage.contact_id,
    contact_name: contact.firstName || currentMessage.contact_name,
  }
}];
```

### 3. Parse LLM Response
```typescript
const items = $input.all();

return items.map(item => {
  const response = item.json;
  let content = '';

  // Handle OpenAI format
  if (response.choices) {
    content = response.choices[0]?.message?.content || '';
  }
  // Handle Gemini format
  else if (response.candidates) {
    content = response.candidates[0]?.content?.parts?.[0]?.text || '';
  }

  // Clean and parse JSON
  const cleaned = content
    .replace(/```json\n?/g, '')
    .replace(/```\n?/g, '')
    .trim();

  try {
    const parsed = JSON.parse(cleaned);

    return {
      json: {
        reply: parsed.reply || 'Thanks for your message! Let me get back to you shortly.',
        actions: parsed.actions || [],
        internal_notes: parsed.internal_notes || '',
        has_book_action: (parsed.actions || []).some((a: any) => a.type === 'book_call'),
        has_tag_action: (parsed.actions || []).some((a: any) => a.type === 'tag_lead'),
        has_score_action: (parsed.actions || []).some((a: any) => a.type === 'update_score'),
        tags: (parsed.actions || [])
          .filter((a: any) => a.type === 'tag_lead')
          .flatMap((a: any) => a.tags || []),
        score: (parsed.actions || [])
          .find((a: any) => a.type === 'update_score')?.value || null,
        parse_success: true,
      }
    };
  } catch (e) {
    // Fallback: treat entire response as a reply, no actions
    console.log('Failed to parse LLM response as JSON:', e);
    return {
      json: {
        reply: content || 'Thanks for reaching out! Someone from our team will be in touch shortly.',
        actions: [],
        internal_notes: 'PARSE_FAILED: LLM did not return valid JSON',
        has_book_action: false,
        has_tag_action: false,
        has_score_action: false,
        tags: [],
        score: null,
        parse_success: false,
      }
    };
  }
});
```

## Environment Variables Required

```
GHL_API_KEY=           # GoHighLevel API key
GHL_PIPELINE_ID=       # Pipeline for qualified leads
GHL_STAGE_NEW=         # "New Lead" stage ID
GHL_STAGE_QUALIFIED=   # "Qualified" stage ID
GHL_STAGE_BOOKED=      # "Call Booked" stage ID
GHL_CALENDAR_ID=       # Calendar for discovery calls
OPENAI_API_KEY=        # or GEMINI_API_KEY
CLIENT_BRAND_NAME=     # Used in system prompt
SLACK_WEBHOOK_URL=     # For error/activity notifications
```

## Deployment Checklist

1. ✅ System prompt customised with client's brand, pricing tier, and services
2. ✅ GHL pipeline stages mapped and IDs configured
3. ✅ Calendar connected and free slots returning correctly
4. ✅ Message send/reply API tested on the target platform
5. ✅ Error handler workflow created and linked
6. ✅ Rate limits tested (won't spam GHL or AI API)
7. ✅ Edge cases tested (see chatbot testing checklist in SKILL.md)
8. ✅ Conversation state storage verified (history persists correctly)
9. ✅ Loom walkthrough recorded for client
