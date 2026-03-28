# {{CLIENT_NAME}} — {{PROJECT_DESCRIPTION}}

## Project Context

- Client: {{CLIENT_NAME}}
- Description: {{PROJECT_DESCRIPTION}}
- Services: {{SERVICES_LIST}}
- Contact: Mit (Souhardya Biswas) — souhardyabiswas02@gmail.com

## Freelancing Rules

- Use the `client-delivery` skill before packaging any deliverable
- Test every webhook/trigger with a sample payload before marking complete
- Track scope — if a task expands beyond the brief, pause and flag it
- Default to MVP first, then iterate
- Note any out-of-scope requests as follow-ups

## Tech Stack

- Orchestration: n8n (TypeScript Code nodes only)
- n8n node naming: descriptive names ("Validate Lead Data", not "Code1")
- AI models: Gemini 2.5 Pro (analysis), GPT-4o (conversational)
- Secrets: GCP Secret Manager or .env files (never committed)

## Project Structure

    {{PROJECT_NAME}}/
    ├── src/
    ├── n8n-workflows/
    ├── docs/
    ├── tests/
    ├── .env.example
    ├── .gitignore
    ├── README.md
    └── .claude/
        └── CLAUDE.md
