# GoHighLevel (GHL) API Reference

## Authentication

### API v1 (Legacy — still widely used)
```
Base URL: https://rest.gohighlevel.com/v1/
Auth Header: Authorization: Bearer {{$env.GHL_API_KEY}}
```

### API v2 (LeadConnector — newer, OAuth-based)
```
Base URL: https://services.leadconnectorhq.com/
Auth Header: Authorization: Bearer {{$env.GHL_ACCESS_TOKEN}}
Additional Header: Version: 2021-07-28
```

For most freelance projects, v1 API keys are simpler. Use v2 when:
- Client uses GHL SaaS mode (white-label)
- Need OAuth for multi-location access
- v1 doesn't support the feature needed

## Rate Limits

- **100 requests per 10 seconds** per API key
- Handle 429 responses with exponential backoff
- n8n pattern: Wait 10s → Retry (max 3 attempts)

## Common Endpoints

### Contacts

**Create Contact:**
```
POST /contacts/
{
  "email": "lead@example.com",
  "phone": "+447123456789",
  "firstName": "John",
  "lastName": "Doe",
  "source": "Instagram DM Bot",
  "tags": ["ai-qualified", "hot-lead"],
  "customField": {
    "lead_score": "85",
    "qualification_notes": "Budget confirmed, ready to book"
  }
}
```

**Search Contact:**
```
GET /contacts/lookup?email=lead@example.com
GET /contacts/lookup?phone=+447123456789
```

**Update Contact:**
```
PUT /contacts/{contactId}
{
  "tags": ["booked-call"],
  "customField": { "lead_score": "95" }
}
```

**Add Tags:**
```
POST /contacts/{contactId}/tags/
{ "tags": ["qualified", "hot-lead"] }
```

### Opportunities (Pipeline)

**Create Opportunity:**
```
POST /opportunities/
{
  "pipelineId": "{{$env.GHL_PIPELINE_ID}}",
  "pipelineStageId": "{{$env.GHL_STAGE_NEW}}",
  "contactId": "abc123",
  "name": "John Doe - AI Qualified",
  "monetaryValue": 5000,
  "source": "ai-setter-bot"
}
```

**Update Opportunity Stage:**
```
PUT /opportunities/{opportunityId}
{
  "pipelineStageId": "{{$env.GHL_STAGE_BOOKED}}"
}
```

### Calendar / Appointments

**Get Available Slots:**
```
GET /calendars/{calendarId}/free-slots?startDate=2025-01-01&endDate=2025-01-07
```

**Book Appointment:**
```
POST /calendars/events/appointments
{
  "calendarId": "{{$env.GHL_CALENDAR_ID}}",
  "contactId": "abc123",
  "startTime": "2025-01-05T10:00:00Z",
  "endTime": "2025-01-05T10:30:00Z",
  "title": "Discovery Call — John Doe",
  "appointmentStatus": "confirmed"
}
```

### Conversations / Messages

**Send SMS:**
```
POST /conversations/messages
{
  "type": "SMS",
  "contactId": "abc123",
  "message": "Hey John! Your call is booked for tomorrow at 10am. See you then!"
}
```

**Send Email:**
```
POST /conversations/messages
{
  "type": "Email",
  "contactId": "abc123",
  "subject": "Your Discovery Call is Confirmed",
  "message": "<h1>Hi John</h1><p>Looking forward to our call!</p>",
  "emailFrom": "team@clientbrand.com"
}
```

### Workflows (Trigger)

**Add Contact to Workflow:**
```
POST /contacts/{contactId}/workflow/{workflowId}
```
This triggers the GHL workflow (e.g., nurture sequence) for the contact.

## n8n Integration Patterns

### Lead Qualification → GHL Pipeline
```
1. Webhook receives lead data
2. Code: Validate + score lead
3. HTTP Request: POST /contacts/ (create in GHL)
4. HTTP Request: POST /opportunities/ (add to pipeline)
5. IF: score > 80 → Book calendar slot
6. IF: score 50-80 → Add to nurture workflow
7. IF: score < 50 → Tag as "cold", no action
```

### Appointment Booking Flow
```
1. AI qualifies lead (chatbot/DM bot)
2. HTTP Request: GET free-slots for next 5 days
3. Code: Format available times for the user
4. [User selects time via bot]
5. HTTP Request: POST book appointment
6. HTTP Request: PUT update opportunity stage to "Booked"
7. HTTP Request: POST send confirmation SMS
```

## Environment Variables Needed

```
GHL_API_KEY=         # v1 API key from GHL Settings → Business Profile → API Key
GHL_ACCESS_TOKEN=    # v2 OAuth token (if using v2)
GHL_PIPELINE_ID=     # Pipeline ID from GHL → Opportunities → Settings
GHL_STAGE_NEW=       # Stage ID for "New Lead"
GHL_STAGE_QUALIFIED= # Stage ID for "Qualified"
GHL_STAGE_BOOKED=    # Stage ID for "Call Booked"
GHL_CALENDAR_ID=     # Calendar ID from GHL → Calendars → Settings
```

## Gotchas

- GHL custom field IDs are UUIDs, not the display names — fetch them via API first
- Phone numbers MUST include country code (+44, +1, etc.)
- GHL webhooks send ALL events — filter by event type in your n8n workflow
- Contact lookup can return multiple results — always handle arrays
- GHL's v2 API requires location-level access tokens, not account-level
