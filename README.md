# sf-agents

Salesforce subagent definitions for Claude Code. A 7-agent DevOps workflow with proper Git branching — branch created before any code is written, deployment only after PR is merged.

---

## Quick Start

```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh && chmod +x setup-sf-agents.sh && ./setup-sf-agents.sh
```

Run from the root of any Salesforce DX project.

---

## Prerequisites

Before using these agents, connect the following in Claude Code (Settings → MCP Servers):

| Tool | Why it's needed |
|------|----------------|
| **Claude Code** | Runs the agents |
| **Salesforce MCP** | Deploys metadata to your org |
| **GitHub MCP** | Creates branches, pushes code, opens PRs |
| **Jira MCP** (optional) | Links deployments to tickets |

The GitHub MCP connection is required — without it the design agent cannot create branches.

---

## How it works

The design agent creates the feature branch. Every downstream agent commits to that same branch. Deployment only happens after you merge the PR.

```
User request
    │
    ▼
salesforce-design (opus)
Analyzes request → outputs plan → user confirms
→ creates feature branch → writes branch name to agent-output/current-branch.md
    │
    ▼
    ├──► salesforce-admin (sonnet)
    │    Creates objects, fields, flows, metadata
    │    Commits to feature branch
    │
    └──► salesforce-developer (opus)
         Reads branch from current-branch.md
         Writes Apex, LWC, triggers
         Commits to feature branch
              │
              ▼
    salesforce-unit-testing (sonnet)
    Reads branch from current-branch.md
    Writes test classes — narrates each test
    90%+ coverage, bulk scenarios for triggers
    Commits to feature branch
              │
              ▼
    salesforce-code-review (sonnet)
    Reviews all code on branch — read only
    Verdict: APPROVED / WARNINGS / CHANGES REQUIRED
              │
              ▼ Gate: approved / fix / cancel
              │
    salesforce-documentation (sonnet)
    Reads branch from current-branch.md
    Writes docs to docs/ folder
    Commits + pushes final branch state
    Shows PR link to user
              │
              ▼
    *** User reviews and merges PR on GitHub ***
              │
              ▼
    salesforce-devops (opus)
    Confirms PR merged → pulls main
    Deploys to org via Salesforce MCP
    Runs tests → logs deployment
```

---

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `salesforce-design` | opus | Analyzes request, creates feature branch |
| `salesforce-admin` | sonnet | Creates metadata, commits to branch |
| `salesforce-developer` | opus | Writes Apex/LWC, commits to branch |
| `salesforce-unit-testing` | sonnet | 90%+ coverage, verbose output, commits to branch |
| `salesforce-code-review` | sonnet | Reviews branch — read only |
| `salesforce-documentation` | sonnet | Writes docs, commits + pushes final state |
| `salesforce-devops` | opus | Deploys from main AFTER PR is merged |

---

## Setup — new project

```bash
# Step 1 — download setup script
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh

# Step 2 — run it
chmod +x setup-sf-agents.sh && ./setup-sf-agents.sh

# Step 3 — fill in project conventions
open CLAUDE.md
```

Fill in `CLAUDE.md`:
- `API Version` — from your `sfdx-project.json`
- `Field prefix` — your org prefix (e.g. `WORK_`) or leave blank

### What gets installed

```
your-project/
├── CLAUDE.md                          ← fill in API version + field prefix
├── .claude/
│   ├── agents/                        ← 7 agent .md files
│   ├── templates/                     ← 4 report templates
│   └── agent-memory-local/            ← isolated per-project memory
├── agent-output/                      ← runtime files (includes current-branch.md)
└── docs/                              ← documentation saved here
```

---

## Update — existing project

```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/update-sf-agents.sh
chmod +x update-sf-agents.sh && ./update-sf-agents.sh
```

Safe — never touches your project memory or `CLAUDE.md`.

---

## Memory isolation

```
work-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← work org patterns only

personal-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← personal org patterns only
```

---

## Add to .gitignore

```gitignore
.claude/agent-memory-local/
agent-output/
```
