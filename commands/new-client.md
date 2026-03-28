---
description: "Scaffold a new client project with CLAUDE.md, folder structure, .env.example, and git init"
---

# /new-client — Client Project Scaffolding

You are scaffolding a new freelance client project. Follow these steps exactly.

## Step 1: Gather Info

Use AskUserQuestion to ask these 3 questions, one at a time:

1. "What is the client's name?" (e.g., "Acme Marketing")
2. "One-line project description?" (e.g., "AI setter bot for Instagram DM lead qualification")
3. "Which services will this project use? (comma-separated)"
   Options: n8n, GHL, Shopify, AI chatbot, GCP deploy

## Step 2: Create Folder Structure

Create these directories:
- `src/`
- `docs/`
- `tests/`
- `.claude/`

If "n8n" is in the selected services, also create:
- `n8n-workflows/`

## Step 3: Generate .claude/CLAUDE.md

Read the template from this plugin at `templates/client-claude.md`.

Replace the placeholders:
- `{{CLIENT_NAME}}` — the client name from Step 1
- `{{PROJECT_DESCRIPTION}}` — the description from Step 1
- `{{SERVICES_LIST}}` — comma-separated services from Step 1
- `{{PROJECT_NAME}}` — slugified client name (lowercase, hyphens)

Write the result to `.claude/CLAUDE.md`.

## Step 4: Generate .env.example

Read `templates/env-example.md` from this plugin.

Build the `.env.example` file by including ONLY the sections matching the selected services:
- "n8n" selected → include the n8n section
- "GHL" selected → include the GoHighLevel section
- "AI chatbot" selected → include the OpenAI and Gemini sections
- "Shopify" selected → include the Shopify section
- "GCP deploy" selected → include the GCP section
- Always include the General section

Write the result to `.env.example`.

## Step 5: Generate .gitignore

Read `templates/gitignore.md` from this plugin. Extract the gitignore content block and write it to `.gitignore`.

## Step 6: Create README.md Skeleton

Write a minimal `README.md`:

```
# [Client Name] — [Project Description]

> Built by the freelancing team (Mit + Supriya)

## Status

In development

## Setup

1. Copy `.env.example` to `.env` and fill in your credentials
2. See `.env.example` for required environment variables

## Services

[List selected services here]
```

Replace `[Client Name]`, `[Project Description]`, and the services list with actual values.

## Step 7: Initialize Git

Run:
```bash
git init
git add -A
git commit -m "init: scaffold [Client Name] project"
```

## Step 8: Confirm

Tell the user:
> "Project scaffolded! Here's what was created:"
> - List all created files and directories
> - Remind them to fill in `.env` values
> - Suggest: "Run `/brainstorm` to start designing the solution"
