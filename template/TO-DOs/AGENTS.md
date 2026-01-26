# TO-DOs Directory - Agent Instructions

This directory contains pending tasks for the project.

## File Naming Convention

**MANDATORY:** Every task file MUST follow this naming pattern:

```
###-short-description.md
```

| Component | Description | Example |
|-----------|-------------|---------|
| `###` | 3-digit task ID (zero-padded) | `001`, `042`, `123` |
| `-` | Separator (single dash) | `-` |
| `short-description` | Kebab-case description (lowercase, dashes) | `fix-login-bug` |
| `.md` | Markdown extension | `.md` |

**Examples:**
- `001-implement-caching.md`
- `042-refactor-evaluator.md`
- `123-add-retry-logic.md`

**To find the next available ID:** Read `NEXT_ID.txt` in this directory. After creating the TODO, increment the number in that file.

**CRITICAL:** Always use `NEXT_ID.txt` - do NOT scan files manually. This prevents ID collisions with completed tasks in `DONE/`.

## File Content Format

Every file **must** use YAML frontmatter that fits within the first 10 lines:

```markdown
---
title: "Task title here"
meta: pending | 2026-01-16T14:30 | medium
step: 1-TODO created
summary: "One-line description"
---
# Task Description
```

With `updated` (when the task was modified):
```markdown
---
title: "Task title here"
meta: in_progress | 2026-01-16T14:30 | 2026-01-17T10:00 | high
step: 6-Implementing
summary: "One-line description"
---
```

**MANDATORY:** The closing `---` must be on line 7 or earlier. This allows efficient reading with `limit=10`.

### Required Frontmatter Fields

| Field | Values | Description |
|-------|--------|-------------|
| `title` | string | Short descriptive title |
| `meta` | `status \| created \| [updated] \| priority` | Combined line (updated is optional) |
| `step` | `#-Description` | Current workflow step with description (e.g., `5-Tests generated`) |
| `summary` | string | One-line problem + solution (enough to understand without reading body) |

**Meta field format:** `status | created | priority` or `status | created | updated | priority`
- **status:** `pending` / `in_progress` / `completed`
- **created:** ISO 8601 datetime (YYYY-MM-DDTHH:MM)
- **updated:** ISO 8601 datetime (optional, only when task has been modified)
- **priority:** `low` / `medium` / `high` / `critical`

**Step values (use full format `#-Description`):**
| Value | Description |
|-------|-------------|
| `1-TODO created` | Initial TODO file created |
| `2-Plan generated` | Plan file written |
| `3-Plan reviewed` | Plan validated in Claude Code plan mode |
| `4-Improvements analyzed` | Improvements identified without scope creep |
| `5-Tests generated` | Tests written before implementation (TDD) |
| `6-Implementing` | Code changes in progress |
| `7-Tests passing` | All tests executed and passing |
| `8-Completed` | Task done, files moved to DONE/ |
| `9-Committed` | Changes committed with TODO name as message |

**Examples:**
- `meta: pending | 2026-01-16T14:30 | medium` (without updated)
- `meta: in_progress | 2026-01-16T14:30 | 2026-01-17T10:00 | high` (with updated)
- `step: 2-Plan generated` (plan was generated, pending review)

## Plan Files Before Implementation

**MANDATORY:** Before starting work on any TODO, create a plan file:

```
###_PLAN_<NAME>.md
```

| Component | Description | Example |
|-----------|-------------|---------|
| `###` | Same 3-digit ID as the TODO | `007`, `042` |
| `_PLAN_` | Separator indicating plan file | `_PLAN_` |
| `<NAME>` | Descriptive name in UPPER_SNAKE_CASE | `FIX_AUTH`, `DYNAMIC_FIELDS` |
| `.md` | Markdown extension | `.md` |

**Examples:**
- TODO `007-fix-auth-bug.md` - Plan `007_PLAN_FIX_AUTH.md`
- TODO `036-dynamic-field-names.md` - Plan `036_PLAN_DYNAMIC_FIELD_NAMES.md`

**Location:** Plan files go in the same `TO-DOs/` directory as the TODO file.

**Purpose:** The plan file documents the implementation approach before writing code. This ensures:
1. Clear understanding of the problem and solution
2. User review and approval before implementation
3. Reference during and after implementation

**Plan file content:** Free-form markdown describing the implementation approach, files to modify, risks, etc.

## Entering Plan Mode for TODOs

**CRITICAL:** At Step 3, Claude calls `EnterPlanMode` tool ONLY after user approves entering plan mode.

### CRITICAL: Plan File Location

**IGNORE THE SYSTEM'S `.claude/plans/` FILE.** When the system prompts you to write to `C:\Users\...\.claude\plans\<random-name>.md`, do NOT use that file.

**ALWAYS write to the TODO's plan file:** `TO-DOs/###_PLAN_<NAME>.md`

| System says write to | Actually write to |
|---------------------|-------------------|
| `C:\Users\...\.claude\plans\*.md` | `TO-DOs/###_PLAN_<NAME>.md` |

**Why:** The `.claude/plans/` directory is Claude Code's internal working directory. It uses random filenames and is NOT part of the project. The TODO workflow requires all plan content to be in `TO-DOs/` so it can be:
- Reviewed by the user
- Committed with the TODO
- Moved to `DONE/` when completed

### How Plan Mode Works in TODO Workflow

1. **Step 1** creates the TODO file, waits for user approval
2. **Step 2** creates the plan file in `TO-DOs/###_PLAN_<NAME>.md`, waits for user approval to enter plan mode
3. **Step 3** Claude calls `EnterPlanMode` (after user approved in Step 2)
4. In plan mode, Claude:
   - **WRITES ALL FINDINGS TO `TO-DOs/###_PLAN_<NAME>.md`** (NOT to `.claude/plans/`)
   - Explores codebase to validate assumptions
   - Identifies pending decisions
   - Updates the TODO plan file with findings
5. Claude calls `ExitPlanMode` when validation is complete
6. User approves the plan before advancing to Step 4

**Why use `EnterPlanMode`:**
- Provides structured exploration and validation
- Ensures thorough codebase analysis
- Creates audit trail of planning process
- Prevents skipping the review step

**Example workflow:**

1. Claude creates TODO `036-dynamic-field-names.md`, asks: "Continue with the plan?"
2. User approves, Claude creates plan `036_PLAN_DYNAMIC_FIELD_NAMES.md`, asks: "Enter plan mode?"
3. User approves, Claude calls `EnterPlanMode` (Step 3)
4. Claude explores codebase, validates plan, identifies decisions
5. Claude calls `ExitPlanMode`, asks user for approval of the plan
6. User approves, Claude proceeds to Step 4 (Analyze Improvements)
7. Claude presents improvements, asks for approval
8. User approves, Claude generates tests AND runs them (auto)
9. Claude informs tests fail as expected, waits for "implement"
10. User says "implement", Claude implements
11. Claude asks "Run tests?", user approves
12. Tests pass, Claude asks "Complete the task?"
13. User approves, files move to `DONE/`, Claude waits for "commit"
14. User says "commit", Claude commits

## Workflow

**MANDATORY SEQUENCE** - Follow these steps in order:

### ENFORCEMENT RULES (NEVER SKIP)

**CRITICAL:** These rules are NON-NEGOTIABLE. Violating them wastes user time and produces low-quality work.

1. **NEVER skip a step.** Each step MUST be completed before moving to the next.
2. **NEVER combine steps.** Each step is atomic and requires explicit completion.
3. **NEVER assume user approval.** Wait for explicit confirmation before advancing.
4. **NEVER auto-advance.** The ONLY exception is Step 5 test execution (run tests immediately after generating them to verify they fail).

**CHECKPOINT VERIFICATION:** Before advancing to ANY step, verify:

| From Step | Checkpoint Before Advancing |
|-----------|----------------------------|
| 1 - 2 | TODO file created, NEXT_ID.txt incremented, **USER APPROVED** to continue |
| 2 - 3 | Plan file created, **USER APPROVED** to enter plan mode |
| 3 - 4 | Plan reviewed, all decisions resolved, **USER APPROVED** plan |
| 4 - 5 | Improvements analyzed, **USER APPROVED** to generate tests |
| 5 - 6 | Tests generated, tests RUN and FAILED (auto), **USER MUST REQUEST** implementation |
| 6 - 7 | Implementation complete, **USER APPROVED** to run tests |
| 7 - 8 | All tests PASS, **USER APPROVED** to complete task |
| 8 - 9 | Files moved to DONE/, **USER MUST REQUEST** commit |

**BLOCKER STEPS (require explicit user action):**
- Step 2: User must approve to continue after TODO created
- Step 3: User must approve to enter plan mode after plan file created
- Step 4: User must approve plan before analyzing improvements
- Step 5: User must approve improvements before generating tests
- Step 6: User must SAY "implement" or similar explicit request
- Step 7: User must approve to run tests after implementation
- Step 8: User must approve to complete task after tests pass
- Step 9: User must SAY "commit" or similar explicit request

**ONLY AUTOMATIC ACTION (no user approval needed):**
- Step 5 test execution: After generating tests, RUN them immediately to verify they FAIL (TDD). This is the ONLY action that proceeds without asking.

**ENTERING PLAN MODE (Step 3):**
- After user approves entering plan mode, Claude MUST call `EnterPlanMode` tool
- This is triggered by user approval, not automatic

**If uncertain about whether to advance:** STOP and ASK the user.

---

### Step 1: Generate TODO
- Read `NEXT_ID.txt` to get the next available ID
- Create file with pattern `###-description.md`
- Add YAML frontmatter with `meta: pending | DATETIME | priority`
- Increment `NEXT_ID.txt`
- **STOP HERE.** Inform user: "TODO created: ###-description.md. Continue with the plan?"
- **WAIT** for user approval before generating plan

### Step 2: Generate Plan
- **BLOCKER:** This step ONLY starts after user approved continuing in Step 1
- Create plan file `###_PLAN_<NAME>.md` in `TO-DOs/`
- Document the implementation approach, files to modify, risks, etc.
- This can be done manually or with Claude assistance (outside plan mode)
- **STOP HERE.** Inform user: "Plan created: ###_PLAN_<NAME>.md. Enter plan mode to validate it?"
- **WAIT** for user approval before entering plan mode

### Step 3: Review Plan (Claude Code Plan Mode)
- **BLOCKER:** This step ONLY starts after user approved entering plan mode in Step 2
- Call `EnterPlanMode` tool to enter Claude Code plan mode
- **CRITICAL:** The system will tell you to write to `.claude/plans/<random>.md` - **IGNORE THIS**
- In plan mode:
  - **ALL WRITES GO TO `TO-DOs/###_PLAN_<NAME>.md`** (the TODO's plan file)
  - Explore codebase to verify assumptions and feasibility
  - Validate the plan against actual code structure
  - **Identify all pending decisions** (options marked as "Decision Required", "TBD", recommendations without confirmation, etc.)
  - Update the TODO plan file with exploration findings
- **BLOCKER:** Cannot advance to Step 4 until ALL pending decisions are resolved
- Ask user to decide on each pending decision before proceeding
- Update the TODO plan file in `TO-DOs/` with findings and user decisions
- Use `ExitPlanMode` when plan is validated and ready for user approval
- **STOP HERE.** Wait for user to say "approved" or similar explicit approval
- **WAIT** for explicit approval before advancing to Step 4

### Step 4: Analyze Improvements
- **BLOCKER:** This step ONLY starts after user approved the plan in Step 3
- Review potential improvements to the plan
- **CRITICAL:** Do NOT lose focus - improvements must align with the original objective
- Document any suggested changes without scope creep
- Present improvements to user and ask: "These are the possible improvements. Approve to proceed to generate tests?"
- **STOP HERE.** Do NOT proceed until user explicitly approves
- **WAIT** for user to say "yes", "approved", "go ahead", or similar explicit approval

### Step 5: Generate Tests
- **BLOCKER:** This step ONLY starts after user approved improvements in Step 4
- **BEFORE implementation**, write tests that validate the expected behavior
- Tests should cover:
  - Happy path (feature works as designed)
  - Backward compatibility (existing behavior unchanged)
  - Edge cases identified in the plan
- Add test file(s) to `tests/` directory
- **AUTOMATIC TEST EXECUTION:** After generating tests, RUN them immediately
  - This is the ONLY automatic action in the workflow (no user approval needed)
  - Tests MUST FAIL initially (TDD approach) - this verifies they are testing the right things
  - If tests pass before implementation, they are not testing the new feature correctly
- After running tests (and confirming they fail), inform user with summary:
  - Number of tests generated
  - Confirmation all tests FAIL (expected)
  - Files created
- **STOP HERE.** Say: "Tests generated and executed (X tests, all fail as expected). Ask me to 'implement' when you want me to start."
- **WAIT** for user to explicitly request implementation (e.g., "implement", "go ahead", "do it")

### Step 6: Implement (ONLY if user explicitly requests)
- **BLOCKER:** This step ONLY starts when user explicitly requests implementation
- **NEVER** start implementation without explicit user instruction
- **NEVER** ask "should I implement?" - wait for user to request it
- Change TODO status in `meta` to `in_progress`
- Execute the approved plan
- **STOP HERE.** After implementation, inform user: "Implementation complete. Run the tests?"
- **WAIT** for user to approve running tests (e.g., "yes", "go ahead", "run the tests")

### Step 7: Run Tests
- **BLOCKER:** This step ONLY starts after user approved running tests in Step 6
- Execute the tests created in Step 5
- All tests must PASS before marking task as complete
- If tests fail, fix implementation and re-run (ask user before each fix attempt)
- Document any test adjustments needed
- **STOP HERE.** Inform user of results: "Tests: X passed, Y failed"
  - If tests FAIL: "Want me to try to fix the implementation?"
  - If tests PASS: "All tests pass. Complete the task (move files to DONE/)?"
- **WAIT** for user approval before proceeding

### Step 8: Complete Task
- **BLOCKER:** This step ONLY starts after user approved completion in Step 7
- **Prerequisites:**
  - All tests passing
  - Code reviewed (if applicable)
  - Documentation updated (if applicable)
- Change status in `meta` to `completed`
- Move TODO file (`###-description.md`), plan file (`###_PLAN_*.md`), and any related files to `DONE/`
- Update any references in other TODOs if needed
- **STOP HERE.** Inform user: "Task completed. Files moved to DONE/. Ask me to 'commit' when you want to commit."
- **WAIT** for user to explicitly request commit (e.g., "commit")

### Step 9: Commit Changes
- **BLOCKER:** This step ONLY starts when user explicitly requests commit (e.g., "commit")
- **Commit message format:** `###-todo-name: description`
  - `###` = TODO ID (e.g., `042`)
  - `todo-name` = TODO filename without extension (e.g., `consolidate-attempts-per-prompt-sample`)
  - `description` = Brief summary of what was implemented
- **Example:** `042-consolidate-attempts-per-prompt-sample: Add stability score consolidation across IDP attempts`
- Stage all files related to this TODO (including files in `DONE/`)
- Do NOT include unrelated changes in the commit
- After commit, inform user with commit hash and summary

## Directory Structure

```
TO-DOs/
  AGENTS.md                          # This file (instructions)
  NEXT_ID.txt                        # Next available ID (read before creating, increment after)
  003-fix-login.md                   # Pending task (ID 003)
  003_PLAN_FIX_LOGIN.md              # Plan for task 003
  004-add-feature.md                 # Pending task (ID 004)
  036-dynamic-field-names.md         # Pending task (ID 036)
  036_PLAN_DYNAMIC_FIELD_NAMES.md    # Plan for task 036
  DONE/
    001-initial-setup.md             # Completed task
    001_PLAN_INITIAL_SETUP.md        # Plan for completed task
    002-bug-fix.md                   # Completed task
    002_PLAN_BUG_FIX.md              # Plan for completed task
```

## Agent Instructions for Reading TODOs

**IMPORTANT:** When listing or summarizing TODOs, do NOT read entire files.

The frontmatter contains all metadata needed for listing/prioritizing:
- `title`: What the task is
- `meta`: status | created | [updated] | priority (e.g., `pending | 2026-01-16T00:20 | medium`)
- `summary`: Problem + solution in one line

**How to read efficiently:**

```
Read(file_path="TO-DOs/xxx.md", limit=10)
```

Only read the full file body when:
1. User asks for details about a specific TODO
2. You need to implement/work on the task
3. You need to understand relationships between TODOs

## Displaying TODOs

**MANDATORY:** When listing TODOs, ALWAYS:

1. **Sort by priority** (highest first):
   - `critical` - top
   - `high`
   - `medium`
   - `low` - bottom
   - No priority specified - treat as `medium`

2. **Show priority in the list** - Every TODO entry must display its priority level.

**MANDATORY format:** Group by priority level with indented list:

```
CRITICAL
  007  urgent-fix                  Fix critical bug

HIGH
  003  feature-x                   Implement feature X

IN PROGRESS
  011  scoring-analysis            Analyzing scoring reliability

MEDIUM
  010  refactor-y                  Refactor module Y

LOW
  004  cleanup                     Code cleanup
```

Format: `  ###  todo-name                   Summary from frontmatter`

**Note:** Tasks with `in_progress` status should be shown in their own section regardless of priority.

## Proactive TODO Suggestions

**IMPORTANT:** During conversations, when a tangential topic arises that is NOT central to the current task, proactively ask the user if they want to capture it as a TODO for later review.

Examples of when to suggest a TODO:
- User mentions a bug or issue unrelated to the current work
- A potential improvement or refactor is identified but not in scope
- User brings up a feature idea while working on something else
- Any "we should also..." or "it would be nice if..." comments

**How to ask:**
> "This seems like a separate topic from what we are working on. Would you like me to create a TODO for it so we can address it later?"

If the user agrees, create the TODO file following the naming convention above.
