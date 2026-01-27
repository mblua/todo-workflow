# TODO Workflow - Quick Start Guide

Get started with the TODO Workflow in 5 minutes.

## Prerequisites

- An AI coding agent (Claude Code, Cursor, or Copilot)
- A software project (any language/framework)

## Step 1: Adopt the Workflow (30 seconds)

Tell your AI agent:

```
"Adopt this workflow: https://github.com/mblua/todo-workflow"
```

The agent will:
- Create `TO-DOs/` directory structure
- Add `TO-DOs/AGENTS.md` with workflow instructions
- Create `TO-DOs/NEXT_ID.txt` (initialized to 001)
- Update or create root `AGENTS.md` with TODO reference

**Verify installation:**
```bash
ls TO-DOs/
# Should show: AGENTS.md  NEXT_ID.txt  DONE/
```

## Step 2: Create Your First TODO (1 minute)

Tell your agent what you want to build:

```
"Create a TODO for adding logging to the authentication module"
```

**Agent will:**
1. Read `NEXT_ID.txt` (says "001")
2. Create `TO-DOs/001-add-logging-to-auth.md`
3. Increment `NEXT_ID.txt` to "002"
4. Ask: **"TODO created. Continue with the plan?"**

**You say:** "Yes"

## Step 3: Generate Plan (1 minute)

**Agent will:**
1. Create `TO-DOs/001_PLAN_ADD_LOGGING.md`
2. Document the approach
3. Ask: **"Plan created. Enter plan mode to validate it?"**

**You say:** "Yes"

## Step 4: Validate Plan in Plan Mode (1 minute)

**Agent will:**
1. Enter Claude Code plan mode
2. Explore your codebase
3. Validate assumptions
4. Update plan with findings
5. Exit plan mode
6. Ask: **"Plan validated. Ready for your approval."**

**You say:** "Approved"

## Step 5: Review Improvements (30 seconds)

**Agent will:**
1. Analyze potential improvements
2. Present them
3. Ask: **"These are the possible improvements. Approve to proceed to generate tests?"**

**You say:** "Yes"

## Step 6: Generate Tests (TDD) (1 minute)

**Agent will:**
1. Generate test file: `tests/test_001_add_logging.py`
2. **AUTOMATICALLY run tests**
3. Verify tests FAIL (expected in TDD)
4. Say: **"Tests generated and executed (5 tests, all fail as expected). Ask me to 'implement' when ready."**

**Important:** Agent STOPS here and waits.

**You say:** "Implement"

## Step 7: Implement the Feature (varies)

**Agent will:**
1. Change TODO status to `in_progress`
2. Write the code according to plan
3. Ask: **"Implementation complete. Run the tests?"**

**You say:** "Yes"

## Step 8: Run Tests (30 seconds)

**Agent will:**
1. Run the test suite
2. If tests PASS: **"All tests pass. Complete the task (move files to DONE/)?"**
3. If tests FAIL: Fix implementation and retry

**You say:** "Complete it"

## Step 9: Complete Task (15 seconds)

**Agent will:**
1. Change TODO status to `completed`
2. Move files to `DONE/`:
   - `001-add-logging-to-auth.md`
   - `001_PLAN_ADD_LOGGING.md`
3. Say: **"Task completed. Ask me to 'commit' when ready."**

**You say:** "Commit"

## Step 10: Commit Changes (15 seconds)

**Agent will:**
1. Stage all related files
2. Commit with format: `001-add-logging-to-auth: Add structured logging to authentication module`
3. Report: **"Committed: abc1234"**

**Done! ✅**

---

## What You Just Accomplished

- ✅ Created a TODO with clear scope
- ✅ Generated a detailed implementation plan
- ✅ Validated plan against actual codebase
- ✅ Wrote tests BEFORE implementation (TDD)
- ✅ Implemented the feature
- ✅ Verified all tests pass
- ✅ Moved completed work to DONE/
- ✅ Created a clean git commit

**Total time:** ~7 minutes (excluding implementation)

---

## Next Steps

### Create Another TODO

```
"Create a TODO for refactoring the database connection pooling"
```

Agent will use ID 002 (automatically incremented).

### List Existing TODOs

```
"List all TODOs grouped by priority"
```

Agent will show:
```
MEDIUM
  002  refactor-db-pooling     Refactor database connection pooling

DONE/
  001  add-logging-to-auth     Add logging to authentication module
```

### Check TODO Status

```
"Show me details of TODO 002"
```

Agent will read the full TODO file and show current state.

### Work on Multiple TODOs

```
"Create TODOs for:
1. Fix login timeout bug
2. Add password strength validator
3. Update documentation"
```

Agent will create three TODOs (IDs 003, 004, 005).

---

## Common Commands

| What You Want | What You Say |
|---------------|--------------|
| Create TODO | "Create a TODO for X" |
| List TODOs | "List all TODOs" or "Show pending TODOs" |
| Work on TODO | "Let's work on TODO 042" |
| Continue workflow | "Yes" / "Approved" / "Continue" |
| Implement (Step 6) | "Implement" / "Do it" |
| Commit (Step 9) | "Commit" / "Commit it" |
| Skip improvements | "No improvements, proceed" |

---

## Understanding the Workflow

### Why 9 Steps?

Each step has a purpose:

| Step | Purpose | Why It Matters |
|------|---------|----------------|
| 1. Create TODO | Capture the task | Clear scope definition |
| 2. Generate Plan | Document approach | Think before coding |
| 3. Review Plan | Validate assumptions | Catch issues early |
| 4. Analyze Improvements | Identify optimizations | Continuous improvement |
| 5. Generate Tests | Write TDD tests | Quality assurance |
| 6. Implement | Write the code | Controlled execution |
| 7. Run Tests | Verify correctness | Confidence in changes |
| 8. Complete Task | Archive work | Clean project state |
| 9. Commit | Version control | Git history |

### Why So Many Approval Gates?

**Without gates:**
- Agent implements what it thinks you want
- You review 500 lines of code after the fact
- "That's not what I asked for"
- Wasted time

**With gates:**
- Agent shows plan first
- You approve or correct
- Agent implements exactly what you want
- Efficient collaboration

### When Does Agent Stop and Wait?

**BLOCKER steps (agent must wait):**
- After Step 1: Wait for "continue with plan"
- After Step 2: Wait for "enter plan mode"
- After Step 3: Wait for "approved"
- After Step 4: Wait for "generate tests"
- After Step 5: Wait for "implement"
- After Step 6: Wait for "run tests"
- After Step 7: Wait for "complete task"
- After Step 8: Wait for "commit"

**AUTOMATIC step (no approval needed):**
- Step 5 test execution: Tests run immediately after generation (validates TDD)

---

## Tips for Success

### 1. Write Clear TODO Summaries

**Good:**
```
summary: "Add retry logic for transient network errors in API client"
```

**Bad:**
```
summary: "Fix API"
```

### 2. Keep TODOs Focused

**One TODO should:**
- Address one problem
- Have clear success criteria
- Be completable in one session

**If too large:**
- Break into multiple TODOs
- Create parent TODO with checklist
- Link related TODOs in descriptions

### 3. Use Priority Levels

**critical:** Production is broken, data loss risk
**high:** Blocking other work, user-facing bug
**medium:** Important but not blocking (default)
**low:** Nice to have, cleanup

### 4. Trust the Process

**First time:**
- Workflow may feel slow
- You will want to skip steps
- Resist the urge

**After a few TODOs:**
- Muscle memory develops
- Agent anticipates your needs
- Speed increases naturally

### 5. Read the Docs

- **Stuck?** → [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **Best practices?** → [BEST_PRACTICES.md](docs/BEST_PRACTICES.md)
- **Examples?** → [EXAMPLES.md](docs/EXAMPLES.md)

---

## Customization

### Change Test Directory

If your project uses `spec/` instead of `tests/`:

**Update TO-DOs/AGENTS.md:**
```markdown
## Project-Specific Testing

Tests for this project are in `spec/` directory (not `tests/`).
```

### Add Ticket Numbers to Commits

**Update root AGENTS.md:**
```markdown
## Commit Format

For this project, include Jira ticket:
`###-todo-name [PROJ-123]: description`
```

### Use Different Language

**Update TO-DOs/AGENTS.md Step messages:**
```markdown
# Spanish
- **STOP HERE.** Inform user: "TODO creado. ¿Continúo con el plan?"

# French
- **STOP HERE.** Inform user: "TODO créé. Continuer avec le plan?"
```

---

## Troubleshooting

### Agent Skips Steps

**Problem:** Agent creates TODO and implements immediately.

**Solution:**
```
"STOP. Read TO-DOs/AGENTS.md section 'ENFORCEMENT RULES'.
You must NEVER skip steps. Start over from Step 1."
```

### Tests Pass Before Implementation

**Problem:** Step 5 tests run and all pass (should fail).

**Solution:**
```
"STOP. These tests are not validating the new feature.
Rewrite tests to actually check the feature works.
They must FAIL until the feature is implemented."
```

### Plan File in Wrong Location

**Problem:** Plan appears in `.claude/plans/` instead of `TO-DOs/`.

**Solution:**
```
"STOP. Wrong location. Read TO-DOs/AGENTS.md section
'CRITICAL: Plan File Location'. Copy plan to
TO-DOs/001_PLAN_ADD_LOGGING.md"
```

### More Issues?

See [TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for comprehensive solutions.

---

## What's Next?

### Master the Workflow

Work through 5-10 TODOs to build fluency. After that, the workflow becomes second nature.

### Contribute Improvements

Found a better way? Encountered an edge case? See [CONTRIBUTING.md](CONTRIBUTING.md).

### Share Your Experience

Help others by:
- Creating issues for problems you encounter
- Suggesting documentation improvements
- Sharing your TODO examples

---

## FAQ

**Q: Can I skip steps for simple changes?**
A: For trivial changes (typos, version bumps), it is acceptable to skip the workflow. For anything requiring thought, use the workflow.

**Q: What if I need to pivot mid-implementation?**
A: Update the plan file, return to Step 3 (plan review), and proceed from there.

**Q: Can multiple people use this workflow on the same project?**
A: Yes. Each person reads NEXT_ID.txt, creates TODO, and increments immediately to avoid collisions.

**Q: Does this work with non-AI workflows?**
A: Yes, humans can follow it too. However, it is optimized for AI agent behavior (hence the strict enforcement rules).

**Q: What if my agent does not support plan mode?**
A: Skip Step 3 (plan mode validation) and manually review the plan in Step 2.

**Q: Is this overkill for small projects?**
A: For <10 TODOs, it may feel heavy. For 50+ TODOs, it is essential. Adjust based on project size.

---

## Summary

**5-minute adoption** → Lifetime of organized development

The TODO Workflow turns AI agents from "code generators" into "collaborators who follow your process."

**Ready to start?** Tell your agent:

```
"Adopt this workflow: https://github.com/mblua/todo-workflow"
```

Then create your first TODO and experience the difference.
