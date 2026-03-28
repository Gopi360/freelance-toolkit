---
name: client-delivery
description: >
  Package freelancing deliverables for client handoff. Use when finishing
  a project, preparing documentation, creating setup guides, writing
  READMEs, or preparing for a client Loom walkthrough. Ensures every
  deliverable is professional, complete, and self-serve for the client.
---

# Client Delivery Packaging

## When This Skill Applies

Use this skill whenever:
- A project or milestone is ready for client handoff
- You need to write a README or setup guide
- You're preparing a Loom walkthrough
- A client asks "how do I set this up?" or "how does this work?"
- You're about to send a final invoice

## Delivery Checklist

**STOP. Before sending anything to the client, verify ALL of these:**

### Functionality
- [ ] System works end-to-end with real (or realistic test) data
- [ ] All happy paths tested and working
- [ ] Error paths tested — system fails gracefully, not silently
- [ ] Edge cases handled (empty inputs, duplicates, rate limits)

### Security
- [ ] No hardcoded API keys, tokens, or secrets anywhere in code
- [ ] All credentials in `.env` file (not committed) or Secret Manager
- [ ] `.env.example` file has all variable names with descriptions
- [ ] Webhook endpoints verified for signature validation (if applicable)

### Documentation
- [ ] README.md exists with complete setup instructions
- [ ] Architecture overview (1-2 paragraphs or simple diagram)
- [ ] Environment variables documented in table format
- [ ] Testing instructions included
- [ ] Troubleshooting section for common issues

### For n8n Workflows
- [ ] All workflows exported as JSON in `n8n-workflows/` directory
- [ ] Workflows use `$env` variables, not hardcoded values
- [ ] Error handler workflow exists and is linked
- [ ] Node names are descriptive
- [ ] Workflow is set to Active (or instructions for activation)

### Professional Touch
- [ ] Loom walkthrough recorded (or script prepared)
- [ ] Code is clean — no commented-out blocks, no debug logs
- [ ] File/folder naming is consistent and professional

## README Template

Use `templates/readme-template.md` as the starting point.

## Loom Script

Use `templates/loom-script-outline.md` for recording structure.

## Handoff Document

Use `templates/handoff-doc.md` for formal project handoffs.

## Pricing Delivery Cadence

### Fixed-Price Projects
1. Milestone 1 (prototype/MVP): Quick demo + "here's where we are"
2. Milestone 2 (integration): Working system + setup guide
3. Final delivery: Full README + Loom + handoff doc

### Retainer/Hourly
- Weekly: Brief Slack/email update with what was done
- Monthly: Summary report + Loom of new features
- On request: Specific documentation for what they need

## Post-Delivery

- [ ] Client confirms receipt and access
- [ ] Walk client through setup (live call or Loom)
- [ ] Agree on support period (e.g., "2 weeks of bug fixes included")
- [ ] Set expectations for future work (scope for follow-ups)
- [ ] Send invoice
