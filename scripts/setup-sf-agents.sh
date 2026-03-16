#!/bin/bash
# ============================================================
# setup-sf-agents.sh
# Run once in the root of any new Salesforce project.
# Installs agents, templates, and output folder structure.
# ============================================================

set -e

REPO="https://github.com/UserBasheer/sf-agents"
TMP=".sf-agents-tmp"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo ""
echo "======================================"
echo "  Salesforce Agent Setup"
echo "======================================"
echo ""

# ── Confirm we're in a Salesforce project ──────────────────
if [ ! -f "sfdx-project.json" ]; then
  echo -e "${RED}ERROR: sfdx-project.json not found.${NC}"
  echo "Run this script from the root of a Salesforce DX project."
  exit 1
fi

# ── Confirm with user ──────────────────────────────────────
echo "This will install 7 Salesforce subagents into this project."
echo "Project: $(pwd)"
echo ""
read -p "Proceed? (y/n): " confirm
if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
  echo "Cancelled."
  exit 0
fi

# ── Clone agent repo ───────────────────────────────────────
echo ""
echo "Fetching latest agents from GitHub..."
rm -rf "$TMP"
git clone --depth 1 "$REPO" "$TMP" 2>/dev/null
echo -e "${GREEN}Done.${NC}"

# ── Create folder structure ────────────────────────────────
echo "Creating folder structure..."
mkdir -p .claude/agents
mkdir -p .claude/templates
mkdir -p .claude/agent-memory-local/salesforce-design
mkdir -p .claude/agent-memory-local/salesforce-admin
mkdir -p .claude/agent-memory-local/salesforce-developer
mkdir -p .claude/agent-memory-local/salesforce-unit-testing
mkdir -p .claude/agent-memory-local/salesforce-code-review
mkdir -p .claude/agent-memory-local/salesforce-devops
mkdir -p .claude/agent-memory-local/salesforce-documentation
mkdir -p agent-output
mkdir -p docs

# ── Copy agents and templates ──────────────────────────────
cp "$TMP/agents/"*.md .claude/agents/
cp "$TMP/templates/"*.md .claude/templates/

# ── Initialize empty MEMORY.md files ──────────────────────
for agent in salesforce-design salesforce-admin salesforce-developer \
             salesforce-unit-testing salesforce-code-review \
             salesforce-devops salesforce-documentation; do
  echo "# MEMORY.md — $agent" > ".claude/agent-memory-local/$agent/MEMORY.md"
  echo "# Add project-specific patterns here as you work." >> ".claude/agent-memory-local/$agent/MEMORY.md"
done

# ── Initialize empty agent-output files ───────────────────
touch agent-output/design-requirements.md
touch agent-output/components-created.md
touch agent-output/review-verdict.md
touch agent-output/deployment-log.md

# ── Update .gitignore ─────────────────────────────────────
GITIGNORE_ENTRIES=(
  ".claude/agent-memory-local/"
  "agent-output/"
  ".sf-agents-tmp/"
)

if [ -f ".gitignore" ]; then
  echo "Updating .gitignore..."
  for entry in "${GITIGNORE_ENTRIES[@]}"; do
    if ! grep -qF "$entry" .gitignore; then
      echo "$entry" >> .gitignore
      echo -e "  ${GREEN}Added:${NC} $entry"
    else
      echo "  Already present: $entry"
    fi
  done
else
  echo "Creating .gitignore..."
  printf ".claude/agent-memory-local/\nagent-output/\n.sf-agents-tmp/\n" > .gitignore
  echo -e "${GREEN}.gitignore created.${NC}"
fi

# ── Copy scripts into project for future use ──────────────
cp "$TMP/scripts/setup-sf-agents.sh" setup-sf-agents.sh
cp "$TMP/scripts/update-sf-agents.sh" update-sf-agents.sh
chmod +x setup-sf-agents.sh update-sf-agents.sh

# ── Copy CLAUDE.md if not already present ─────────────────
if [ -f "CLAUDE.md" ]; then
  echo -e "${YELLOW}CLAUDE.md already exists — skipping. Manually merge if needed.${NC}"
else
  cp "$TMP/agents/CLAUDE.md" CLAUDE.md
  echo -e "${GREEN}CLAUDE.md created.${NC}"
fi

# ── Clean up ───────────────────────────────────────────────
rm -rf "$TMP"

# ── Read API version from sfdx-project.json ───────────────
API_VERSION=$(python3 -c "import json; d=json.load(open('sfdx-project.json')); print(d.get('sourceApiVersion',''))" 2>/dev/null || echo "")

echo ""
echo "======================================"
echo -e "${GREEN}  Setup complete!${NC}"
echo "======================================"
echo ""
echo "Agents installed:  .claude/agents/ (7 files)"
echo "Templates:         .claude/templates/ (4 files)"
echo "Memory dirs:       .claude/agent-memory-local/ (isolated to this project)"
echo "Output dir:        agent-output/"
echo "Docs dir:          docs/"
echo ""
echo -e "${YELLOW}ACTION REQUIRED — open CLAUDE.md and fill in:${NC}"
if [ -n "$API_VERSION" ]; then
  echo "  API Version:  $API_VERSION  (detected from sfdx-project.json)"
else
  echo "  API Version:  [check sfdx-project.json]"
fi
echo "  Field prefix: [your org-specific prefix e.g. WORK_ or leave blank]"
echo ""
