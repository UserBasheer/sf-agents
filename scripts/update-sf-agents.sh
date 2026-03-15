#!/bin/bash
# Updates agent files in an existing project. Never touches memory or CLAUDE.md.

set -e
REPO="https://github.com/UserBasheer/sf-agents"
TMP=".sf-agents-tmp"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

if [ ! -d ".claude/agents" ]; then
  echo -e "${RED}ERROR: Run setup-sf-agents.sh first.${NC}"
  exit 1
fi

echo "Updates agent files only. Memory and CLAUDE.md untouched."
echo "Project: $(pwd)"
read -p "Proceed? (y/n): " confirm
[[ "$confirm" != "y" && "$confirm" != "Y" ]] && exit 0

git clone --depth 1 "$REPO" "$TMP" 2>/dev/null
cp "$TMP/agents/"*.md .claude/agents/
cp "$TMP/templates/"*.md .claude/templates/
rm -rf "$TMP"

echo -e "${GREEN}Update complete!${NC}"
echo -e "${YELLOW}Not touched: .claude/agent-memory-local/ and CLAUDE.md${NC}"
