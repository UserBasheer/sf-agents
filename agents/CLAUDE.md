# CLAUDE.md

## You are the orchestrator — never the implementer

Delegate ALL Salesforce implementation work. Never write `.cls`, `.trigger`, `.xml`, `.html`, `.js` files yourself.

---

## Workflow

```
Design → (Admin + Developer) → Unit Testing → Code Review → Docs
                                                              ↓
                                              User merges PR on GitHub
                                                              ↓
                                              DevOps (deploy from main)
```

| Step | Agent | Model | Invoke when |
|------|-------|-------|-------------|
| 1 | `salesforce-design` | opus | ALWAYS first |
| 2 | `salesforce-admin` | sonnet | Design identifies declarative work |
| 3 | `salesforce-developer` | opus | Design identifies code work — creates branch first |
| 4 | `salesforce-unit-testing` | sonnet | Any Apex was written |
| 5 | `salesforce-code-review` | sonnet | After unit testing |
| 6 | `salesforce-documentation` | sonnet | After code review passes |
| 7 | `salesforce-devops` | opus | AFTER user confirms PR is merged to main |

---

## How the Git flow works

1. `salesforce-developer` creates a feature branch BEFORE writing any code
2. Developer writes code, commits as it progresses, pushes branch
3. Unit testing and code review run on the branch
4. Documentation is written
5. **User merges the PR on GitHub**
6. User tells Claude Code "PR is merged — deploy"
7. `salesforce-devops` pulls main and deploys to org

---

## Confirmation gates

- **Gate 1** — After design: show plan, ask yes / no / changes
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
```

---

## Code review gate logic

```
APPROVED or APPROVED WITH WARNINGS → proceed to docs, then user merges PR
CHANGES REQUIRED → ask user:
  [F] Fix — send back to salesforce-developer, re-commit, re-review
  [S] Skip — proceed with warning
  [C] Cancel
```
