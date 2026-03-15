# sf-agents

Salesforce subagent definitions for Claude Code. 7-agent DevOps workflow.

## Workflow
Design → Admin + Developer → Unit Testing → Code Review → DevOps (branch + deploy) ∥ Docs

## Setup new project
```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh
chmod +x setup-sf-agents.sh && ./setup-sf-agents.sh
```

## Update existing project
```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/update-sf-agents.sh
chmod +x update-sf-agents.sh && ./update-sf-agents.sh
```

## Agents
| Agent | Model | Role |
|-------|-------|------|
| salesforce-design | opus | Requirements analysis |
| salesforce-admin | sonnet | Declarative/metadata work |
| salesforce-developer | opus | Apex, LWC, integrations |
| salesforce-unit-testing | sonnet | 90%+ test coverage |
| salesforce-code-review | sonnet | Best practice review |
| salesforce-devops | opus | Git branch + MCP deploy |
| salesforce-documentation | sonnet | Docs saved to docs/ |
