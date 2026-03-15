#!/bin/bash
# Run once in the root of any new Salesforce project.

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

if [ ! -f "sfdx-project.json" ]; then
  echo -e "${RED}ERROR: sfdx-project.json not found.${NC}"
  echo "Run this from the root of a Salesforce DX project."
  exit 1
fi

echo "Project: $(pwd)"
read -p "Proceed? (y/n): " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

echo "Fetching agents from GitHub..."
rm -rf "$TMP"
git clone --depth 1 "$REPO" "$TMP" 2>/dev/null

mkdir -p .claude/agents .claude/templates
mkdir -p .claude/agent-memory-local/{salesforce-design,salesforce-admin,salesforce-developer,salesforce-unit-testing,salesforce-code-review,salesforce-devops,salesforce-documentation}
mkdir -p agent-output docs

cp "$TMP/agents/"*.md .claude/agents/
cp "$TMP/templates/"*.md .claude/templates/

for agent in salesforce-design salesforce-admin salesforce-developer salesforce-unit-testing salesforce-code-review salesforce-devops salesforce-documentation; do
  echo "# MEMORY.md — $agent (project-specific)" > ".claude/agent-memory-local/$agent/MEMORY.md"
done

touch agent-output/design-requirements.md agent-output/components-created.md
touch agent-output/review-verdict.md agent-output/deployment-log.md

if [ ! -f "CLAUDE.md" ]; then
  cp "$TMP/agents/CLAUDE.md" CLAUDE.md
  echo -e "${GREEN}CLAUDE.md created.${NC}"
else
  echo -e "${YELLOW}CLAUDE.md already exists — skipping.${NC}"
fi

rm -rf "$TMP"

API_VERSION=$(python3 -c "import json; d=json.load(open('sfdx-project.json')); print(d.get('sourceApiVersion',''))" 2>/dev/null || echo "")

echo ""
echo "======================================"
echo -e "${GREEN}  Setup complete!${NC}"
echo "======================================"
echo ""
echo -e "${YELLOW}ACTION REQUIRED — open CLAUDE.md and fill in:${NC}"
[ -n "$API_VERSION" ] && echo "  API Version:  $API_VERSION (detected)" || echo "  API Version:  [check sfdx-project.json]"
echo "  Field prefix: [e.g. TAG_ for Aspen Group]"
echo ""
