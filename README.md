# Freelance Toolkit

Claude Code plugin for AI & Automation freelancing. Provides domain skills and project scaffolding for n8n, GoHighLevel, AI chatbots, GCP, and Shopify workflows.

Works alongside [Superpowers](https://github.com/obra/superpowers) — Superpowers handles the process (brainstorm, plan, TDD, review), this plugin handles the domain knowledge.

## Install

```bash
claude plugin install github:Gopi360/freelance-toolkit
```

## What You Get

### Skills (auto-activate when relevant)

| Skill | What It Covers |
|---|---|
| `n8n-patterns` | Workflow architecture, TypeScript code nodes, GHL integration, error handling |
| `ai-chatbot-patterns` | AI setter flows, conversation design, RAG, prompt engineering |
| `gcp-deploy` | Cloud Run, Secret Manager, Terraform, Docker |
| `shopify-automation` | API patterns, webhooks, order automation |
| `client-delivery` | README generation, handoff docs, Loom scripts |

### Commands

| Command | What It Does |
|---|---|
| `/new-client` | Scaffold a new client project (folders, CLAUDE.md, .env.example, git init) |

## Setup (One-Time)

After installing the plugin, create your personal `~/.claude/CLAUDE.md`.

See `global-claude-template.md` in this repo for a starting template. Customize it with your name, role, and preferences.

## Starting a Client Project

```bash
mkdir acme-marketing && cd acme-marketing
# Then in Claude Code:
/new-client
```

This creates:
```
acme-marketing/
├── .claude/CLAUDE.md     # Pre-filled with client context
├── src/
├── n8n-workflows/        # If n8n selected
├── docs/
├── tests/
├── .env.example          # Only the services you need
├── .gitignore
└── README.md
```

## Team

- **Mit (Souhardya Biswas)** — Client management
- **Supriya Gope** — Implementation

## License

MIT
