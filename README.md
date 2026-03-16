# sf-agents

Salesforce subagent definitions for Claude Code. A 7-agent DevOps workflow covering design, admin, development, unit testing, code review, deployment, and documentation — with proper Git branching built in.

---

## Quick Start

```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh && chmod +x setup-sf-agents.sh && ./setup-sf-agents.sh
```

Run this from the root of any Salesforce DX project. That's it.

---

## Prerequisites

Before using these agents, make sure you have the following connected in Claude Code:

| Tool | Why it's needed |
|------|----------------|
| **Claude Code** | Runs the agents |
| **Salesforce MCP** | Deploys metadata to your org |
| **GitHub MCP** | Creates branches, pushes code, creates PRs |
| **Jira MCP** (optional) | Links deployments to tickets |

The GitHub MCP connection is required for the Git branching workflow to function. Without it the developer agent cannot create branches or push code programmatically.

To connect MCPs in Claude Code, go to Settings → MCP Servers and add your connections before running any agent workflow.

---

## How it works

The workflow follows proper Git-based DevOps — the branch is created before any code is written, and deployment only happens after the PR is reviewed and merged to main.

```
User request
    │
    ▼
salesforce-design (opus)
Analyzes request, asks clarifying questions, outputs spec
    │
    ▼ Gate 1: user confirms plan
    │
    ├──► salesforce-admin (sonnet)
    │    Creates objects, fields, flows, metadata
    │
    └──► salesforce-developer (opus)
         1. Creates feature branch FIRST
         2. Writes Apex, LWC, triggers
         3. Commits as work progresses
         4. Pushes branch, shows PR link
              │
              ▼
    salesforce-unit-testing (sonnet)
    Writes test classes — narrates each test written
    90%+ coverage, bulk scenarios for all triggers
              │
              ▼
    salesforce-code-review (sonnet)
    Reviews for SOQL in loops, security, bulkification
    Verdict: APPROVED / WARNINGS / CHANGES REQUIRED
              │
              ▼ Gate 2: approved / fix / cancel
              │
    salesforce-documentation (sonnet)
    Saves docs to docs/ folder
              │
              ▼
    *** User reviews and merges PR on GitHub ***
              │
              ▼ Gate 3: user confirms PR merged
              │
    salesforce-devops (opus)
    Pulls latest main → deploys to org via MCP
    Runs tests → shows coverage → logs deployment
```

---

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `salesforce-design` | opus | Requirements analysis — always first |
| `salesforce-admin` | sonnet | Declarative/metadata work |
| `salesforce-developer` | opus | Creates branch first, writes Apex/LWC, commits, pushes |
| `salesforce-unit-testing` | sonnet | 90%+ coverage, verbose output per test written |
| `salesforce-code-review` | sonnet | Best practice review before PR merge |
| `salesforce-documentation` | sonnet | Docs saved to `docs/` |
| `salesforce-devops` | opus | Deploys from main AFTER PR is merged |

---

## Setup — new project

Run from the **root of your Salesforce DX project** (where `sfdx-project.json` lives):

```bash
# Step 1 — download the setup script
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh

# Step 2 — make it executable
chmod +x setup-sf-agents.sh

# Step 3 — run it
./setup-sf-agents.sh

# Step 4 — fill in your project conventions
open CLAUDE.md
```

In `CLAUDE.md` fill in:
- `API Version` — check your `sfdx-project.json`
- `Field prefix` — your org-specific prefix (e.g. `WORK_` or leave blank)

### What gets installed

```
your-project/
├── CLAUDE.md                          ← fill in API version + field prefix
├── .claude/
│   ├── agents/                        ← 7 agent .md files
│   ├── templates/                     ← 4 report templates
│   └── agent-memory-local/            ← isolated per-project memory
├── agent-output/                      ← runtime files written by agents
└── docs/                              ← documentation saved here
```

---

## Update — existing project

Pulls latest agent files without touching your project memory or `CLAUDE.md`:

```bash
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/update-sf-agents.sh
chmod +x update-sf-agents.sh
./update-sf-agents.sh
```

---

## Memory isolation

Each project gets its own memory — nothing crosses between projects:

```
work-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← work org patterns only

personal-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← personal org patterns only
```

---

## Add to .gitignore in your Salesforce projects

```gitignore
# Agent memory is project-specific — do not commit
.claude/agent-memory-local/

# Agent runtime output — regenerated each session
agent-output/
```
