# sf-agents

Salesforce subagent definitions for Claude Code. A 7-agent DevOps workflow covering design, admin, development, unit testing, code review, deployment, and documentation — with full Git branching built in.

---

## Workflow

```
User request
    │
    ▼
salesforce-design (opus) ── always first, analyzes and clarifies requirements
    │
    ▼ Gate 1: user confirms plan
    │
    ├──► salesforce-admin (sonnet)      declarative/metadata work
    └──► salesforce-developer (opus)    Apex, LWC, integrations
                   │
                   ▼
       salesforce-unit-testing (sonnet) 90%+ test coverage
                   │
                   ▼
       salesforce-code-review (sonnet)  best practice review before deploy
                   │
                   ▼ Gate 2: approved / warnings / changes required
                   │
         ┌─────────┴──────────┐
         ▼                    ▼
salesforce-devops (opus)     salesforce-documentation (sonnet)
  1. Create feature branch   Save docs to docs/ folder
  2. Commit all files
  3. Push to GitHub
  4. Deploy to org via MCP
  5. Prompt user to open PR
```

---

## Agents

| Agent | Model | Role |
|-------|-------|------|
| `salesforce-design` | opus | Requirements analysis — always first |
| `salesforce-admin` | sonnet | Declarative/metadata work |
| `salesforce-developer` | opus | Apex, LWC, integrations |
| `salesforce-unit-testing` | sonnet | 90%+ test coverage |
| `salesforce-code-review` | sonnet | Best practice review |
| `salesforce-devops` | opus | Git branch + MCP deploy |
| `salesforce-documentation` | sonnet | Docs saved to `docs/` |

---

## Setup — new project

Run these commands from the **root of your Salesforce DX project** (where `sfdx-project.json` lives):

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
- `Field prefix` — your org-specific prefix (e.g. `WORK_`, `PROD_`, or leave blank if none)

### What the setup script installs

```
your-project/
├── CLAUDE.md                          ← fill in API version + field prefix
├── .claude/
│   ├── agents/                        ← 7 agent .md files
│   ├── templates/                     ← 4 report templates
│   └── agent-memory-local/            ← isolated per-project memory
│       ├── salesforce-design/
│       ├── salesforce-admin/
│       ├── salesforce-developer/
│       ├── salesforce-unit-testing/
│       ├── salesforce-code-review/
│       ├── salesforce-devops/
│       └── salesforce-documentation/
├── agent-output/                      ← runtime files written by agents
│   ├── design-requirements.md
│   ├── components-created.md
│   ├── review-verdict.md
│   └── deployment-log.md
└── docs/                              ← documentation saved here
```

---

## Update — existing project

Pulls latest agent files without touching your project memory or `CLAUDE.md`:

```bash
# Step 1 — download the update script
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/update-sf-agents.sh

# Step 2 — make it executable
chmod +x update-sf-agents.sh

# Step 3 — run it
./update-sf-agents.sh
```

---

## Memory isolation

Each project gets its own memory — nothing crosses between projects:

```
project-A/  (work org)
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← work org patterns only

project-B/  (personal org)
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← personal org patterns only
```

---

## Improving an agent

1. Edit the relevant `.md` file in this repo
2. Push to GitHub
3. Run `update-sf-agents.sh` in any project that should get the update

Existing projects keep their current version until you explicitly update them.

---

## Add to .gitignore in your Salesforce projects

```gitignore
# Agent memory is project-specific — do not commit
.claude/agent-memory-local/

# Agent runtime output — regenerated each session
agent-output/
```

Keep `.claude/agents/` and `.claude/templates/` out of gitignore — commit those if you customise them per project.
