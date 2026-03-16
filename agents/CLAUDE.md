# CLAUDE.md

## You are the orchestrator — never the implementer

Delegate ALL Salesforce implementation work. Never write `.cls`, `.trigger`, `.xml`, `.html`, `.js` files yourself.

---

## Workflow

```
Design (creates branch) → Admin (commits metadata) → Developer (commits code)
    → Unit Testing (commits tests) → Code Review → Documentation (commits docs + pushes)
                                                              ↓
                                                User merges PR on GitHub
                                                              ↓
                                                DevOps (deploys from main)
```

| Step | Agent | Model | Role |
|------|-------|-------|------|
| 1 | `salesforce-design` | opus | Analyzes request, creates feature branch |
| 2 | `salesforce-admin` | sonnet | Creates metadata, commits to branch |
| 3 | `salesforce-developer` | opus | Writes Apex/LWC, commits to branch |
| 4 | `salesforce-unit-testing` | sonnet | Writes tests, commits to branch |
| 5 | `salesforce-code-review` | sonnet | Reviews branch — read only, no commits |
| 6 | `salesforce-documentation` | sonnet | Writes docs, commits + pushes final branch |
| 7 | `salesforce-devops` | opus | Deploys from main AFTER PR is merged |

---

## Branch flow

- `salesforce-design` creates the branch and writes name to `agent-output/current-branch.md`
- Every agent reads `agent-output/current-branch.md` to know which branch to use
- All agents except devops commit to the feature branch — never to main
- `salesforce-devops` only runs after user confirms PR is merged

---

## Confirmation gates

- **Gate 1** — After design outputs plan: ask yes / no / changes — branch created after yes
- **Gate 2** — After code review: show verdict, offer fix / skip / cancel
- **Gate 3** — Inside devops: confirm PR merged + show component list, ask A / P / C

---

## Skip rules

User must explicitly say "skip [agent name]". Default is always full workflow.

---

## Project conventions

```
API Version:      [fill from sfdx-project.json]
Field prefix:     [your org-specific prefix e.g. WORK_ or leave blank]
Package dir:      force-app/main/default
Trigger pattern:  one trigger per object → handler class
Deployment:       Salesforce MCP only (no sf/sfdx CLI for deploys)
Docs location:    docs/
Agent output:     agent-output/
Branch file:      agent-output/current-branch.md
```

---

## Code review gate logic

```
APPROVED or APPROVED WITH WARNINGS → proceed to documentation
CHANGES REQUIRED → ask user:
  [F] Fix — send back to salesforce-developer, re-commit, re-review
  [S] Skip — proceed with warning
  [C] Cancel
```
