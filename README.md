# Freelance Toolkit

Claude Code plugin for AI & Automation freelancing. Provides domain skills and project scaffolding for n8n, GoHighLevel, AI chatbots, GCP, and Shopify workflows.

Works alongside [Superpowers](https://github.com/obra/superpowers) — Superpowers handles the process (brainstorm, plan, TDD, review), this plugin handles the domain knowledge.

## Install

### Method 1: Marketplace (recommended)

```bash
claude plugin marketplace add Gopi360/freelance-toolkit
claude plugin install freelance-toolkit@freelance-marketplace
```

### Method 2: Manual Install (if marketplace install fails)

On **Windows** and sometimes **macOS**, the plugin system can fail with `EPERM: operation not permitted` during file rename operations. This is an OS-level file locking issue, not a bug in your setup.

If you hit this error, install manually:

**Option A: Run the install script**

```bash
git clone https://github.com/Gopi360/freelance-toolkit.git
cd freelance-toolkit
chmod +x install.sh
./install.sh
```

This copies all 5 skills to `~/.claude/skills/`. The `/new-client` command won't be available as a slash command — instead, tell Claude "scaffold a new client project" and it will follow the same flow.

**Option B: Full manual plugin registration**

If you want the full plugin experience (skills + `/new-client` slash command), manually place the files where Claude Code expects them:

```bash
# 1. Clone the marketplace
git clone https://github.com/Gopi360/freelance-toolkit.git ~/.claude/plugins/marketplaces/freelance-marketplace

# 2. Clone the plugin cache
git clone https://github.com/Gopi360/freelance-toolkit.git ~/.claude/plugins/cache/freelance-marketplace/freelance-toolkit/1.0.0
```

Then add these entries to your Claude Code config files:

**`~/.claude/plugins/known_marketplaces.json`** — add inside the top-level object:
```json
"freelance-marketplace": {
  "source": {
    "source": "github",
    "repo": "Gopi360/freelance-toolkit"
  },
  "installLocation": "<YOUR_HOME>/.claude/plugins/marketplaces/freelance-marketplace",
  "lastUpdated": "2026-03-28T00:00:00.000Z"
}
```

**`~/.claude/plugins/installed_plugins.json`** — add inside `"plugins"`:
```json
"freelance-toolkit@freelance-marketplace": [
  {
    "scope": "user",
    "installPath": "<YOUR_HOME>/.claude/plugins/cache/freelance-marketplace/freelance-toolkit/1.0.0",
    "version": "1.0.0",
    "installedAt": "2026-03-28T00:00:00.000Z",
    "lastUpdated": "2026-03-28T00:00:00.000Z",
    "gitCommitSha": "<run git rev-parse HEAD in the cloned repo>"
  }
]
```

**`~/.claude/settings.json`** — add to `"enabledPlugins"`:
```json
"freelance-toolkit@freelance-marketplace": true
```

And add to `"extraKnownMarketplaces"`:
```json
"freelance-marketplace": {
  "source": {
    "source": "github",
    "repo": "Gopi360/freelance-toolkit"
  }
}
```

Replace `<YOUR_HOME>` with your actual home directory path (e.g., `C:\\Users\\YourName` on Windows, `/Users/yourname` on macOS).

Restart Claude Code after editing these files.

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
