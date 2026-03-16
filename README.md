# sf-agents

A 7-agent AI workflow for Salesforce development using Claude Code. Give it a feature request — it designs, builds, tests, reviews, documents, and deploys it using proper Git branching.

---

## What this does

Instead of asking AI to write individual pieces of code, sf-agents runs a full development pipeline automatically:

1. **Analyzes** your request and asks clarifying questions if anything is unclear
2. **Creates a Git feature branch** before any code is written
3. **Builds** all Salesforce metadata, Apex, and LWC — committing to the branch as it goes
4. **Tests** with 90%+ code coverage — narrating each test as it writes it
5. **Reviews** the code against Salesforce best practices before anything is deployed
6. **Documents** everything in a technical doc saved to your project
7. **Waits for you to merge the PR** — then deploys from main to your org

Nothing is deployed until you review and merge the PR on GitHub.

---

## Prerequisites

You need the following before starting:

| Requirement | Purpose |
|-------------|---------|
| [Claude Code](https://claude.ai/code) | Runs the agents |
| Salesforce MCP | Deploys metadata to your org |
| GitHub MCP | Creates branches, pushes code, opens PRs |
| Salesforce DX project | Your project must have `sfdx-project.json` |
| Git initialized | Your project must be a Git repo with a GitHub remote |
| Dev Hub enabled | Required for scratch org creation during deployment validation |

**Connect MCP servers in Claude Code:** Settings → MCP Servers → add Salesforce MCP and GitHub MCP.

GitHub MCP is required — the design agent uses it to create the feature branch before any work begins.

### Why scratch orgs?

Before deploying to your target org, the devops agent spins up a **fresh scratch org**, deploys everything there, and runs all tests in complete isolation. If anything fails, the scratch org is deleted and your target org is never touched.

This is better than running tests locally because:
- Scratch orgs match your actual Salesforce environment exactly
- Tests run against real Salesforce metadata compilation — not just local files
- Every validation is in a clean, isolated environment with no interference from existing data
- Works perfectly with free Developer Edition accounts — no paid sandbox needed

To use scratch orgs you need a **Dev Hub** enabled. If you have a Developer Edition org, enable it at: Setup → Dev Hub → Enable.

---

## Setup — new project

Run these commands from the **root of your Salesforce DX project** (the folder that contains `sfdx-project.json`):

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/UserBasheer/sf-agents/main/scripts/setup-sf-agents.sh

# Run it
chmod +x setup-sf-agents.sh && ./setup-sf-agents.sh
```

When setup completes, open `CLAUDE.md` and fill in two values:

```bash
open CLAUDE.md
```

- `API Version` — copy this from your `sfdx-project.json` (e.g. `62.0`)
- `Field prefix` — your org's custom field prefix if you have one (e.g. `ACME_`), or leave blank

The setup script also checks for `config/project-scratch-def.json` — the devops agent needs this to spin up scratch orgs for deployment validation. If your project doesn't have one, the devops agent will create a default one automatically on first deployment.

---

## What gets installed

The setup script creates this structure inside your project:

```
your-project/
├── CLAUDE.md                        ← fill in API version + field prefix
├── setup-sf-agents.sh               ← the script you just ran
├── update-sf-agents.sh              ← run this when a new version is released
├── .claude/
│   ├── agents/                      ← 7 agent definition files
│   ├── templates/                   ← report templates used by agents
│   └── agent-memory-local/          ← agents learn your project over time (local only)
├── agent-output/                    ← temporary files agents write each session (local only)
└── docs/                            ← technical documentation saved here after each feature
```

### What stays local vs what goes to GitHub

The setup script automatically adds the right entries to your `.gitignore` so you don't have to think about this. Here's what it means:

| Folder | Goes to GitHub? | Why |
|--------|----------------|-----|
| `force-app/` | ✅ Yes | Your Salesforce code |
| `.claude/agents/` | ✅ Yes | Agent definitions — same for everyone |
| `.claude/templates/` | ✅ Yes | Report templates |
| `docs/` | ✅ Yes | Technical documentation |
| `CLAUDE.md` | ✅ Yes | Your project conventions |
| `.claude/agent-memory-local/` | ❌ No | Agents learn your org's specific patterns over time — this is personal to your machine and should never be shared |
| `agent-output/` | ❌ No | Temporary working files regenerated every session — no value in git history |

---

## How to use it

Open Claude Code in your project and describe what you want to build:

```
Create a Feedback__c object with a Rating picklist and a trigger 
that updates the related Contact when feedback is submitted
```

The agents take it from there. You will be asked to confirm at three points:

1. **After design** — approve the plan before any code is written
2. **After code review** — approve, fix, or cancel before the PR is ready
3. **After you merge the PR** — tell the devops agent to deploy

---

## The full workflow

```
Your request
    │
    ▼
salesforce-design (opus)
Analyzes request, asks questions if unclear
Creates feature branch, writes plan
    │
    ▼ You confirm the plan
    │
    ├──► salesforce-admin (sonnet)
    │    Creates objects, fields, flows
    │    Commits to feature branch
    │
    └──► salesforce-developer (opus)
         Writes Apex, LWC, triggers
         Commits to feature branch
              │
              ▼
    salesforce-unit-testing (sonnet)
    Writes test classes — 90%+ coverage
    Narrates each test as it writes it
    Commits to feature branch
              │
              ▼
    salesforce-code-review (sonnet)
    Reviews for SOQL in loops, security issues,
    missing null checks, recursion problems
    Verdict: APPROVED / WARNINGS / CHANGES REQUIRED
              │
              ▼ You approve, fix, or cancel
              │
    salesforce-documentation (sonnet)
    Writes technical doc to docs/ folder
    Commits and pushes the final branch
    Shows you the PR link
              │
              ▼
    *** You review and merge the PR on GitHub ***
              │
              ▼ You tell Claude Code "PR is merged — deploy"
              │
    salesforce-devops (opus)
    Confirms PR is merged → pulls latest main
    Spins up a fresh scratch org
    Deploys to scratch org → runs ALL tests in isolation
    Tests fail → scratch org deleted → target org never touched → stop
    Tests pass → scratch org deleted → deploys to target org via MCP
    Logs deployment
```

---

## Agents

| Agent | Model | What it does |
|-------|-------|-------------|
| `salesforce-design` | opus | Analyzes request, creates feature branch |
| `salesforce-admin` | sonnet | Creates metadata, commits to branch |
| `salesforce-developer` | opus | Writes Apex/LWC, commits to branch |
| `salesforce-unit-testing` | sonnet | 90%+ test coverage, commits to branch |
| `salesforce-code-review` | sonnet | Reviews code — never modifies it |
| `salesforce-documentation` | sonnet | Writes docs, pushes final branch state |
| `salesforce-devops` | opus | Validates in scratch org first, then deploys to target org after PR is merged |

---

## Updating agents

When a new version is released, update your project with one command:

```bash
./update-sf-agents.sh
```

This pulls the latest agent files from GitHub. It never touches your project memory or `CLAUDE.md` — everything you have configured stays intact.

---

## Memory isolation between projects

Each project has its own isolated agent memory. Agents learn your project's specific conventions over time — naming patterns, deployment quirks, org-specific details. This knowledge never crosses into another project.

```
work-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← work org patterns only

personal-project/
└── .claude/agent-memory-local/
    └── salesforce-developer/MEMORY.md  ← personal org patterns only
```

If you delete a project or start fresh, the memory starts empty again automatically.

