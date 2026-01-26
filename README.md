# TODO Workflow for AI Agents

A structured task management workflow designed for AI coding agents (Claude Code, Cursor, Copilot, etc.). Provides a 9-step process with mandatory checkpoints that ensures quality, prevents scope creep, and maintains user control.

## Why Use This?

- **Prevents runaway implementations** - Agent must get approval at each step
- **TDD by default** - Tests are written before implementation
- **Full traceability** - Every task has a plan file and commit trail
- **Works with any project** - Language and framework agnostic

## Quick Adoption

Tell your AI agent:

> "Adopt this workflow: https://github.com/mblua/todo-workflow"

The agent will read the [ADOPTION.md](ADOPTION.md) file and set up everything automatically.

## Manual Installation

Copy these files to your project:

```bash
# From the template/ directory
cp template/AGENTS.md YOUR_PROJECT/AGENTS.md
cp -r template/TO-DOs YOUR_PROJECT/TO-DOs
```

## Workflow Overview

```
Step 1: Create TODO     -> User approves
Step 2: Generate Plan   -> User approves
Step 3: Review Plan     -> User approves
Step 4: Analyze Improvements -> User approves
Step 5: Generate Tests  -> Auto-run (must FAIL)
Step 6: Implement       -> User requests "implementa"
Step 7: Run Tests       -> Must PASS
Step 8: Complete Task   -> Move to DONE/
Step 9: Commit          -> User requests "commit"
```

See [docs/WORKFLOW_DIAGRAM.md](docs/WORKFLOW_DIAGRAM.md) for a visual flowchart.

## File Structure After Adoption

```
your-project/
  AGENTS.md                    # Agent instructions (includes TODO reference)
  TO-DOs/
    AGENTS.md                  # Complete workflow instructions
    NEXT_ID.txt                # Next available task ID
    001-my-first-task.md       # Example task
    001_PLAN_MY_FIRST_TASK.md  # Task plan
    DONE/                      # Completed tasks
```

## TODO File Format

```yaml
---
title: "Task title"
meta: pending | 2026-01-26T10:00 | medium
step: 1-TODO created
summary: "One-line description"
---

# Task details here...
```

## Key Rules

| Rule | Description |
|------|-------------|
| Never skip steps | Each step must complete before the next |
| Never assume approval | Wait for explicit user confirmation |
| Tests must fail first | TDD approach validates tests are correct |
| One auto-action only | Only Step 5 test execution is automatic |

## License

MIT - See [LICENSE](LICENSE)

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md)
