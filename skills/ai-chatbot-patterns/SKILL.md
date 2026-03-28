---
name: ai-chatbot-patterns
description: >
  AI chatbot, conversational agent, and AI setter design patterns. Use when
  building Instagram DM bots, lead qualification agents, AI setters,
  customer support chatbots, RAG systems, or any conversational AI system.
  Covers conversation flow design, prompt engineering, LLM integration,
  GoHighLevel/CRM booking flows, and multi-turn conversation management.
---

# AI Chatbot & Agent Patterns

## When This Skill Applies

Use this skill whenever the task involves:
- Building an AI setter or lead qualification bot
- Designing conversation flows for DMs (Instagram, WhatsApp, SMS)
- Building a customer support chatbot or FAQ bot
- Implementing RAG (Retrieval-Augmented Generation) systems
- Writing system prompts for conversational agents
- Integrating LLMs with CRM systems (GHL, HubSpot)

## Core Principles

1. **Design the flow first** — Map out the conversation before writing any code
2. **Never pretend to be human** — Disclose AI where required by platform ToS
3. **Fail gracefully** — Always have a "hand off to human" escape path
4. **Minimise context** — Keep conversation history to last 10 messages for cost control
5. **Structured outputs for actions** — Use JSON for CRM updates, natural language for user replies
6. **Test with edge cases** — Test with hostile, confused, off-topic, and multilingual inputs

## Architecture: AI Setter (Lead Qualification)

See `references/ai-setter-flow.md` for the complete flow with code.

High-level architecture:
```
Inbound Message (Instagram DM / GHL webhook / WhatsApp)
  → Retrieve conversation history (last 10 messages)
  → Build LLM prompt (system + history + new message)
  → LLM generates response + structured action
  → Parse: separate user reply from action commands
  → Execute actions (tag contact, update score, book call)
  → Send reply back via platform API
  → Store updated conversation history
```

## Conversation Design Rules

See `references/conversation-design.md` for detailed templates.

Key rules:
- **Max 3 questions before providing value** — Don't interrogate the lead
- **Mirror the lead's energy** — Short replies for short messages, detailed for detailed
- **Always have a next step** — Every response should move toward qualification or handoff
- **Graceful exits** — "Let me connect you with [name] who can help with that specifically"
- **Handle objections** — Price, timing, trust — have pre-built responses for each
- **Off-topic handling** — Acknowledge, redirect: "That's interesting! Coming back to..."

## Prompt Engineering

See `references/prompt-templates.md` for tested system prompts.

System prompt structure:
```
1. ROLE: Who the AI is (brand voice, personality)
2. CONTEXT: What business/product this is for
3. GOAL: What the AI is trying to achieve (qualify, book, support)
4. RULES: Hard constraints (what NOT to do)
5. QUALIFICATION CRITERIA: What makes a lead hot/warm/cold
6. OUTPUT FORMAT: How to structure responses + actions
7. EXAMPLES: 2-3 example conversations showing ideal behaviour
```

## RAG (Retrieval-Augmented Generation)

See `references/rag-architecture.md` for implementation details.

When to use RAG:
- Customer support bots that need to reference docs/FAQs
- Internal knowledge base assistants
- Product recommendation engines
- Any bot that needs to answer questions about specific, possibly changing content

## Conversation State Management

### Option 1: n8n Static Data (simple, small scale)
```typescript
const staticData = $getWorkflowStaticData('global');
const contactId = $input.first().json.contact_id;
const history = staticData[`conv_${contactId}`] || [];
```
Limitation: Cleared when workflow is deactivated. Good for prototypes only.

### Option 2: External Store (production)
- **SQLite/PostgreSQL**: Store conversation rows with `contact_id`, `role`, `content`, `timestamp`
- **Redis**: Fast, TTL-based — auto-expire old conversations
- **GHL Custom Fields**: Store conversation summary in the contact record

### Option 3: GHL Conversation API
Use GHL's built-in conversation thread — read last N messages via API, no separate storage needed.

## Model Selection Guide

| Use Case | Model | Why |
|---|---|---|
| Lead qualification chat | GPT-4o / GPT-4o-mini | Fast, good at conversation, affordable |
| Document analysis / RAG | Gemini 2.5 Pro | Large context window, good at structured extraction |
| Simple FAQ responses | GPT-4o-mini / Gemini Flash | Cheapest, fast enough for simple Q&A |
| Complex multi-step reasoning | Claude Sonnet / GPT-4o | Best at following complex instructions |

## Cost Control

- Use GPT-4o-mini or Gemini Flash for initial intent classification (~$0.001/call)
- Only escalate to expensive models for complex conversations
- Set `max_tokens` to 300 for lead qualification responses (prevents verbose replies)
- Cache system prompts where possible (OpenAI supports prompt caching)
- Monitor daily spend — set alerts at $5/day for early warning

## Testing Checklist

Before deploying any chatbot:
1. ✅ Happy path works (ideal lead, all questions answered)
2. ✅ Missing info handling (lead gives partial answers)
3. ✅ Off-topic handling (lead asks unrelated questions)
4. ✅ Hostile input (rude, spam, profanity)
5. ✅ Edge cases (empty messages, very long messages, non-English)
6. ✅ Handoff works (human escalation path tested)
7. ✅ CRM integration verified (contact created, tags applied, opportunity created)
8. ✅ Calendar booking flow tested with real time slots
9. ✅ Error path tested (what happens when AI API is down?)
10. ✅ Rate limiting verified (won't overwhelm GHL/platform APIs)
