# Real-World Examples

Examples based on production use of this workflow.

## Session Startup (Step 1)

Agent starts a new session and runs the workgroup claim:

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

## Creating an Issue (Step 2)

User says: "Add a dark mode toggle to the frontend"

```bash
gh issue create --repo myorg/my-frontend \
  --title "Add dark mode toggle" \
  --label "priority: medium" \
  --label "step: 2-created" \
  --label "type: ux" \
  --body "Add a toggle switch in the header that switches between light and dark themes."
```

Output: Created issue #14

Agent immediately creates the branch and checklist:
```bash
cd /projects/my-frontend
git checkout -b todo/14-my-frontend
```

Agent responds:
```
								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
								WG2: my-frontend (todo/14-my-frontend)

Created issue #14 with branch todo/14-my-frontend.
Created _issues/14.md checklist. Ready to proceed?

								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
```

## Running feature-dev (Step 3)

After user approves, agent updates the label and launches feature-dev:

```bash
gh issue edit 14 --repo myorg/my-frontend \
  --remove-label "step: 2-created" \
  --add-label "step: 3-developing"
```

Agent runs `/feature-dev Add dark mode toggle - a toggle switch in the header that switches between light and dark themes`.

feature-dev then runs its internal phases:
1. **Discovery** - Understands the request, pauses for user confirmation
2. **Codebase Exploration** - code-explorer agents analyze the frontend codebase
3. **Clarifying Questions** - Asks about theme persistence, system preference detection
4. **Architecture Design** - code-architect agents propose approaches, user picks one
5. **Implementation** - User approves, code is written
6. **Quality Review** - code-reviewer agents check the implementation
7. **Summary** - feature-dev outputs a summary of everything done

## Posting Summary to Issue (Step 4)

After feature-dev completes, agent captures the output and posts it:

```bash
gh issue comment 14 --repo myorg/my-frontend --body "## Step 4: feature-dev Summary

### Discovery
Task: Add dark mode toggle to the header with light/dark theme switching.

### Codebase Exploration
- \`styles.css\` uses CSS custom properties for navbar colors
- \`app.js\` has \`initUI()\` function suitable for theme initialization
- No existing localStorage usage in the project

### Clarifying Q&A
- Q: Should the toggle persist across sessions? A: Yes, use localStorage
- Q: Respect system preference? A: Yes, use \`prefers-color-scheme\` as default

### Architecture

\`\`\`mermaid
graph TD
    A[Page Load] --> B[app.js initUI]
    B --> C{localStorage has theme?}
    C -->|Yes| D[Apply saved theme]
    C -->|No| E[Use system preference]
    D --> F[Render page]
    E --> F
    F --> G[header.js toggle]
    G -->|Click| H[Switch CSS variables]
    H --> I[Save to localStorage]
\`\`\`

Approach: CSS custom properties with JavaScript toggle, localStorage persistence, \`prefers-color-scheme\` fallback.

### Implementation
Files modified:
- \`styles.css\` - Added light/dark theme CSS variables
- \`header.js\` - Added ThemeToggle component
- \`app.js\` - Added theme initialization in \`initUI()\`

### Quality Review
- No issues found by code-reviewer agents
- All changes follow existing code conventions"
```

## Running Tests (Step 5)

Agent runs the test suite and posts results:

```bash
gh issue comment 14 --repo myorg/my-frontend --body "## Step 5: Test Results

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

Agent updates the checklist:
```markdown
- [x] Step 5: Verified (2026-02-20T15:25:00Z)
  COMMAND: npm test
  RESULT: PASS (3 tests, 3 passed)
  EVIDENCE: Posted as issue comment
```

## Skipping Tests (Step 5 - No Test Suite)

For a project without tests:

```
								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
								WG2: my-frontend (todo/14-my-frontend)

This project does not have a test suite configured.
Can we skip Step 5 (Run Tests)?

								#14 MY-FRONTEND - ADD DARK MODE TOGGLE
```

User says "yes, skip". Agent records:
```markdown
- [x] Step 5: Verified SKIPPED (2026-02-20T15:25:00Z)
  REASON: No test suite configured in project
  APPROVED_BY: user
```

## Cross-Repo Issue

User says: "Add user preferences API endpoint and connect it to the settings page"

This touches both backend and frontend. Agent creates the issue in the repo with more changes:

```bash
gh issue create --repo myorg/my-backend \
  --title "User preferences API + settings page" \
  --label "priority: high" \
  --label "step: 2-created" \
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

## Merge to Main (Step 8)

User explicitly says "merge to main" after Step 7 is complete:

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

Step 9 (Release Workgroup) happens automatically - agent deletes the lock file.

## Checklist File (Completed Issue)

After all steps are done, `_issues/14.md` looks like:

```markdown
# Issue #14 - Add dark mode toggle

- repo: my-frontend
- branch: todo/14-my-frontend

## Checklist

- [x] Step 1: Workgroup (2026-02-20T14:28:00Z)
  Claimed workgroup 2
- [x] Step 2: Created (2026-02-20T14:30:00Z)
  Issue #14 created, branch: todo/14-my-frontend
- [x] Step 3: Developing (2026-02-20T14:35:00Z)
  /feature-dev completed - discovery, exploration, architecture, implementation, quality review
- [x] Step 4: Documented (2026-02-20T15:20:00Z)
  Summary posted as issue comment
- [x] Step 5: Verified (2026-02-20T15:25:00Z)
  COMMAND: npm test
  RESULT: PASS (3 tests, 3 passed)
  EVIDENCE: Posted as issue comment
- [x] Step 6: Completed (2026-02-20T15:30:00Z)
  Issue closed
- [x] Step 7: Committed (2026-02-20T15:32:00Z)
  Committed and pushed to todo/14-my-frontend
- [x] Step 8: Merged (2026-02-20T15:35:00Z)
  Merged to main, branch deleted
- [x] Step 9: Released (2026-02-20T15:35:00Z)
  Workgroup 2 lock released
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
ERROR: Step 5 (Verified) not completed in checklist for issue #14
Update _issues/14.md to mark Step 5 as done before committing.
```
