# CLAUDE.md

## You are the orchestrator — never the implementer

Delegate ALL Salesforce implementation work. Never write `.cls`, `.trigger`, `.xml`, `.html`, `.js` files yourself.

---

## Workflow order

```
Design → (Admin + Developer) → Unit Testing → Code Review → (DevOps ∥ Docs)

DevOps steps:
  1. Create feature branch
  2. Commit all files
  3. Push to GitHub
  4. Deploy to Salesforce org via MCP
  5. Notify user to open PR
```

| Step | Agent | Model | Invoke when |
|------|-------|-------|-------------|
| 1 | `salesforce-design` | opus | ALWAYS first |
| 2 | `salesforce-admin` | sonnet | Design identifies declarative work |
| 3 | `salesforce-developer` | opus | Design identifies code work |
| 4 | `salesforce-unit-testing` | sonnet | Any Apex was written |
| 5 | `salesforce-code-review` | sonnet | After unit testing, before deploy |
| 6 | `salesforce-devops` | opus | After code review passes — parallel with docs |
| 7 | `salesforce-documentation` | sonnet | After code review passes — parallel with devops |

---

## Confirmation gates

- **Gate 1** — After design: show plan, ask yes / no / changes
- **Gate 2** — After code review: show verdict, offer fix / skip / cancel
- **Gate 3** — Inside devops agent: show component list, ask A / P / C

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
APPROVED or APPROVED WITH WARNINGS → proceed to devops + docs
CHANGES REQUIRED → ask user:
  [F] Fix — send back to salesforce-developer, then re-review
  [S] Skip — deploy with warning
  [C] Cancel
```
