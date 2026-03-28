#!/bin/bash
# install.sh — Manual fallback installer for freelance-toolkit
# Preferred method: claude plugin install github:Gopi360/freelance-toolkit
#
# This script copies skills and commands to ~/.claude/ for users who
# can't use the plugin system.

set -e

CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "═══════════════════════════════════════════════"
echo "  Freelance Toolkit — Manual Installer"
echo "  Preferred: claude plugin install github:Gopi360/freelance-toolkit"
echo "═══════════════════════════════════════════════"
echo ""

# Copy skills
echo "Installing skills..."
for skill in n8n-patterns ai-chatbot-patterns gcp-deploy shopify-automation client-delivery; do
    mkdir -p "$SKILLS_DIR/$skill"
    cp -r "$SCRIPT_DIR/skills/$skill/"* "$SKILLS_DIR/$skill/"
    echo "  + $skill"
done

echo ""
echo "Skills installed to: $SKILLS_DIR"
echo ""
echo "Next steps:"
echo "  1. Create your ~/.claude/CLAUDE.md using global-claude-template.md as reference"
echo "  2. Start Claude Code and run /new-client to scaffold a project"
echo ""
echo "Note: /new-client command requires plugin install to work as a slash command."
echo "With manual install, ask Claude to 'scaffold a new client project' instead."
echo "═══════════════════════════════════════════════"
