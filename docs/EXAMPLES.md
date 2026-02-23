# Real-World Examples

Examples based on production use of this workflow on the amplifyme.ai project.

## Session Startup

Agent starts a new session and runs the Startup Protocol:

```
Reading workgroup lock files...

| Workgroup | Status    | Issue                        | Locked Since         |
|-----------|-----------|------------------------------|----------------------|
| 1         | LOCKED    | #13 amp-backend              | 2026-02-20T14:30:00Z |
| 2         | AVAILABLE | -                            | -                    |
| 3         | STALE     | #11 amp-frontend             | 2026-02-19T09:00:00Z |
| 4         | NOT PROVISIONED | -                      | -                    |

Which workgroup should this session use?
```

User says "use 2". Agent creates `workgroups/workgroup-2.lock`, verifies repos, pulls latest.

## Creating an Issue

User says: "Add a dark mode toggle to the frontend"

```bash
gh issue create --repo myorg/my-frontend \
  --title "Add dark mode toggle" \
  --label "priority: medium" \
  --label "step: 1-created" \
  --label "type: ux" \
  --body "Add a toggle switch in the header that switches between light and dark themes."
```

Output: Created issue #14

Agent immediately creates the branch:
```bash
cd /projects/my-frontend
git checkout -b todo/14-my-frontend
```

Agent responds:
```
								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
								WG2: my-frontend (todo/14-my-frontend)

Created issue #14 with branch todo/14-my-frontend. Ready to proceed?

								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
```

## Cross-Repo Issue

User says: "Add user preferences API endpoint and connect it to the settings page"

This touches both backend and frontend. Agent creates the issue in the repo with more changes:

```bash
gh issue create --repo myorg/my-backend \
  --title "User preferences API + settings page" \
  --label "priority: high" \
  --label "step: 1-created" \
  --label "type: feature" \
  --body "New /api/preferences endpoint. Frontend settings page consumes it."
```

Output: Created issue #15

Agent creates branches in BOTH repos:
```bash
cd /projects/my-backend
git checkout -b todo/15-my-backend

cd /projects/my-frontend
git checkout -b todo/15-my-frontend
```

Header shows both:
```
								#15 MY-BACKEND - USER PREFERENCES API + SETTINGS PAGE
								WG1: my-backend (todo/15-my-backend) | my-frontend (todo/15-my-frontend)
```

## Adding a Plan (Step 2)

After user approves issue #14:

```bash
gh issue comment 14 --repo myorg/my-frontend --body "## Plan

### Changes
1. Add CSS variables for light/dark themes in styles.css
2. Create toggle component in header
3. Save preference to localStorage
4. Apply theme on page load

### Files Modified
- styles.css (theme variables)
- header.js (toggle component)
- app.js (theme initialization)

### Risks
- Existing hardcoded colors will need migration to CSS variables"

gh issue edit 14 --repo myorg/my-frontend \
  --remove-label "step: 1-created" \
  --add-label "step: 2-planned"
```

## Breaking a Stale Lock

From the startup table, workgroup 3 has been locked for 29+ hours:

```
Workgroup 3 has been locked for 29 hours (since 2026-02-19T09:00:00Z).
It was working on #11 amp-frontend.
This lock is likely from a crashed session. Break the lock?
```

User says "yes". Agent deletes the old lock and creates a new one:

```bash
rm workgroups/workgroup-3.lock
# Creates new lock for this session
```

## Response Header/Footer

Every response uses the header/footer format:

```
								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
								WG2: my-frontend (todo/14-my-frontend)

[... response content ...]

								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
```

When no issue is active:
```
								NO ACTIVE ISSUE

What would you like to work on?

								NO ACTIVE ISSUE
```

## Merge to Main (Step 10)

User explicitly says "merge to main" after step 9 is complete:

```bash
# For each repo with a todo branch for this issue
cd /projects/my-backend
git checkout main
git merge todo/15-my-backend
git push
git branch -d todo/15-my-backend
git push origin --delete todo/15-my-backend

cd /projects/my-frontend
git checkout main
git merge todo/15-my-frontend
git push
git branch -d todo/15-my-frontend
git push origin --delete todo/15-my-frontend
```

Agent verifies no stale branches remain:
```bash
git branch -a | grep "todo/15"
# Should return nothing
```

## Skipping a Step (With Approval)

Agent is at Step 5 (tests) for a CSS-only change:

```
								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
								WG2: my-frontend (todo/14-my-frontend)

This issue only modifies CSS variables and a simple toggle.
Writing unit tests for CSS changes would not add meaningful value.

Can we skip Step 5 (tests) and move directly to implementation?

								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
```

User says "yes, skip tests". Agent proceeds to Step 6.

**Note:** This permission applies ONLY to issue #14. The next issue starts fresh with all steps.

## Checklist File (Completed Issue)

After all steps are done, `_issues/14.md` looks like:

```markdown
# Issue #14 - Add dark mode toggle

- repo: my-frontend
- branch: todo/14-my-frontend

## Checklist

- [x] Step 1: Created (2026-02-20T14:30:00Z)
  Issue #14 created, branch: todo/14-my-frontend
- [x] Step 2: Planned (2026-02-20T14:35:00Z)
  Plan posted as issue comment
- [x] Step 3: Reviewed (2026-02-20T14:50:00Z)
  Plan reviewed in plan mode, no changes
- [x] Step 4: Improvements (2026-02-20T15:00:00Z)
  No scope changes needed
- [x] Step 5: Tests (2026-02-20T15:10:00Z)
  COMMAND: npm test
  RESULT: FAIL (3 tests, 3 failed)
  EVIDENCE: Posted as issue comment
- [x] Step 6: Implementing (2026-02-20T15:30:00Z)
  Implementation complete
- [x] Step 7: Verified (2026-02-20T15:35:00Z)
  COMMAND: npm test
  RESULT: PASS (3 tests, 3 passed)
  EVIDENCE: Posted as issue comment
- [x] Step 8: Completed (2026-02-20T15:40:00Z)
  Issue closed
- [x] Step 9: Committed (2026-02-20T15:42:00Z)
  Committed and pushed to todo/14-my-frontend
- [x] Step 10: Merged (2026-02-20T15:45:00Z)
  Merged to main, branch deleted
```

## Checklist File (Skipped Step 5)

When tests are skipped with user approval:

```markdown
- [x] Step 5: Tests SKIPPED (2026-02-20T15:10:00Z)
  REASON: CSS-only change, no testable logic
  APPROVED_BY: user
```

## Pre-Commit Hook: Missing Checklist

Agent tries to commit on `todo/14-my-frontend` but forgot to create the checklist:

```
$ git commit -m "#14: Add dark mode toggle"
ERROR: No checklist found for issue #14
Expected: /projects/my-hub/_issues/14.md

Create _issues/14.md in the hub repo before committing.
```

## Pre-Commit Hook: Step 5 Not Completed

Agent tries to commit before running tests:

```
$ git commit -m "#14: Add dark mode toggle"
ERROR: Step 5 (Tests) not completed in checklist for issue #14
Update _issues/14.md to mark Step 5 as done before committing.
```

## Test Evidence as Issue Comment

At Step 5, agent posts the test output:

```bash
gh issue comment 14 --repo myorg/my-frontend --body "## Step 5: Test Results

**Command:** \`npm test\`

**Result:** FAIL (3 tests, 3 failed)

\`\`\`
FAIL src/components/ThemeToggle.test.js
  ThemeToggle component
    x should render toggle button (5ms)
    x should switch theme on click (3ms)
    x should persist preference to localStorage (2ms)

Tests: 3 failed, 3 total
\`\`\`

Tests fail as expected (TDD). Ready to implement."
```

At Step 7, after implementation:

```bash
gh issue comment 14 --repo myorg/my-frontend --body "## Step 7: Verification Results

**Command:** \`npm test\`

**Result:** PASS (3 tests, 3 passed)

\`\`\`
PASS src/components/ThemeToggle.test.js
  ThemeToggle component
    v should render toggle button (4ms)
    v should switch theme on click (6ms)
    v should persist preference to localStorage (3ms)

Tests: 3 passed, 3 total
\`\`\`

All tests pass."
```
