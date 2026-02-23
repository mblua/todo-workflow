<!-- workflow-version: 1.2.0 -->
<!-- template: https://github.com/mblua/todo-workflow -->

# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Configuration

```
WORKGROUP_BASE_PATH = {WORKGROUP_BASE_PATH}
WORKGROUP_HUB_REPO  = {WORKGROUP_HUB_REPO}
WORKGROUP_REPOS     = {WORKGROUP_REPOS}
GITHUB_ORG          = {GITHUB_ORG}
```

> **Adoption note:** The variables above were set during adoption. If you need to change them, edit this section directly. See https://github.com/mblua/todo-workflow for the template source.

---

## Workgroup System

Multiple Claude Code agents may work on related projects simultaneously. To prevent file conflicts, each agent claims a **workgroup** - a numbered set of independent repo clones.

### Workgroup Layout

| Group | {WORKGROUP_REPOS} |
|-------|-------------------|
| 1 (default) | base name (no suffix) |
| 2 | name + `2` suffix |
| N | name + `N` suffix |

All paths are relative to `{WORKGROUP_BASE_PATH}`. The hub repo (`{WORKGROUP_HUB_REPO}`) is never suffixed - it is shared by all workgroups.

**Path resolution rule:** Group 1 = base name (no suffix). Group N = append N to the repo name.

### Session Startup Protocol (MANDATORY)

Every new Claude Code session MUST execute these steps before any other work:

1. **Read lock files** - Read all `workgroups/workgroup-*.lock` files in `{WORKGROUP_BASE_PATH}/{WORKGROUP_HUB_REPO}/workgroups/`.
2. **Display status** - Show a table of all workgroups:

   | Workgroup | Status | Issue | Locked Since |
   |-----------|--------|-------|-------------|
   | 1 | LOCKED / AVAILABLE / STALE / NOT PROVISIONED | #N repo | timestamp |

   - **LOCKED** - lock file exists, age < 4 hours
   - **STALE** - lock file exists, age >= 4 hours (likely crashed session)
   - **AVAILABLE** - no lock file, repos exist on disk
   - **NOT PROVISIONED** - no lock file, repos do not exist on disk

3. **Ask user** - "Which workgroup should this session use?"
4. **Wait** - Do NOT proceed until the user explicitly responds.
5. **Create lock file** - Write `workgroups/workgroup-{N}.lock` with JSON:
   ```json
   {
     "workgroup": N,
     "locked_at": "ISO-8601 timestamp",
     "session_id": "optional identifier",
     "issue": "#N repo-name or description",
     "repos": [
       "{WORKGROUP_BASE_PATH}/repo-name{suffix}",
       "..."
     ]
   }
   ```
6. **Verify repos exist** - Check that the repo directories for the claimed workgroup exist on disk. If any are missing, ask the user for approval before cloning.
7. **Set active paths** - Announce to the user which paths are active for this session.
8. **Run git pull** - Pull latest in all active repos. Do NOT pull before workgroup selection.

### Lock Conflict Resolution

- If a workgroup is **STALE** (locked 4+ hours ago), ask the user: "Workgroup N has been locked for X hours. Break the lock?"
- If user confirms, delete the old lock file and create a new one.
- If a workgroup is **LOCKED** (< 4 hours), it is unavailable. Pick a different one.

### Lock Release

- **On session end:** Delete the lock file before closing.
- **On crash:** The lock becomes stale after 4 hours and can be broken by the next session.
- **Explicit release:** User can say "release workgroup N" at any time to delete the lock file.

---

## Task Tracking - GitHub Issues

All tasks are tracked as **GitHub Issues** in the repo where the work happens. If a task touches multiple repos, create the issue in the one with the most changes.

### Labels

Issues use three label dimensions:

**Priority:**

| Label | Use |
|-------|-----|
| `priority: critical` | Blocker, system down or data corruption |
| `priority: high` | Core functionality broken, no workaround |
| `priority: medium` | Important bug or feature but with workaround |
| `priority: low` | Minor improvement, cosmetic, nice-to-have |

**Step (workflow progress):**
`step: 1-created` | `step: 2-planned` | `step: 3-reviewed` | `step: 4-improvements` | `step: 5-tests` | `step: 6-implementing` | `step: 7-verified` | `step: 8-completed` | `step: 9-committed`

**Type:** `type: feature` | `type: bug` | `type: security` | `type: ux` | `type: infra`

### Operations

| Action | Command |
|--------|---------|
| Create issue | `gh issue create --repo {GITHUB_ORG}/<repo> --title "..." --label "priority: X" --label "step: 1-created" --label "type: Y" --body "..."` |
| View issue | `gh issue view <num> --repo {GITHUB_ORG}/<repo>` |
| Update step | `gh issue edit <num> --repo {GITHUB_ORG}/<repo> --remove-label "step: old" --add-label "step: new"` |
| Add plan | `gh issue comment <num> --repo {GITHUB_ORG}/<repo> --body "## Plan\n..."` |
| Close issue | `gh issue close <num> --repo {GITHUB_ORG}/<repo>` |
| List open | `gh issue list --repo {GITHUB_ORG}/<repo> --state open` |
| List by priority | `gh issue list --repo {GITHUB_ORG}/<repo> --label "priority: high"` |

### Listing Format

```bash
gh issue list --repo {GITHUB_ORG}/<repo> --state open --json number,title,labels --jq '.[] | "#\(.number) [\(.labels | map(.name) | join(", "))] \(.title)"'
```

### Branch and Commit Convention

- **Branch:** `todo/<num>-<repo>` (e.g., `todo/6-my-frontend` for issue #6 in my-frontend). The repo suffix avoids collisions when multiple repos have issues with the same number.
- **Commit message:** `#<num>: description` (GitHub auto-links the issue)
- **Cross-repo tasks:** If an issue touches multiple repos, create the branch in EACH repo using the same issue number and each repo's name.

---

## 10-Step Workflow

**MANDATORY SEQUENCE** - Follow these steps in order for every task.

1. **Create Issue** - **Prerequisite: a workgroup must be claimed (lock file exists) before this step.** `gh issue create` with priority, step (`1-created`), and type labels. **Immediately create branch** `todo/<num>-<repo>` in every repo that will be modified. **Create `_issues/<num>.md`** in the hub repo with the initial checklist (see Step Evidence section below). Confirm branch names to user. **STOP.** Wait for user approval.

2. **Generate Plan** - Add plan as comment on the issue with `gh issue comment`. Update label to `step: 2-planned`. **STOP.** Wait for user approval to enter plan mode.

3. **Review Plan (Plan Mode)** - Call `EnterPlanMode`. Explore codebase, validate assumptions, identify pending decisions. Update the plan comment on the issue. Call `ExitPlanMode`. Update label to `step: 3-reviewed`. **STOP.** Wait for user approval.

4. **Analyze Improvements** - Review potential improvements without scope creep. Update label to `step: 4-improvements`. **STOP.** Wait for user approval.

5. **Generate Tests (TDD)** - Write tests that validate expected behavior. **AUTO-RUN** tests immediately (this is the ONLY automatic action). Tests MUST FAIL (TDD). Update label to `step: 5-tests`. **Post test command + full output as issue comment.** Update `_issues/<num>.md` checklist with COMMAND, RESULT, and EVIDENCE fields. **STOP.** Wait for user to say "implement".

6. **Implement** - Only when user explicitly requests. Update label to `step: 6-implementing`. Execute the approved plan. **STOP.** Wait for user approval to run tests.

7. **Run Tests** - Execute tests. Update label to `step: 7-verified`. **Post test command + full output as issue comment.** Update `_issues/<num>.md` checklist with COMMAND, RESULT, and EVIDENCE fields. **STOP.** If pass: ask to complete. If fail: ask to fix.

8. **Complete** - Close issue with `gh issue close`. Update label to `step: 8-completed`. **STOP.** Wait for user to say "commit".

9. **Commit and Push** - Commit with `#<num>: description` message. Push the `todo/<num>-*` branch to remote. Update label to `step: 9-committed`. **The pre-commit hook will verify the `_issues/<num>.md` checklist before allowing the commit.** **STOP.** Wait for user to explicitly say "merge" or "merge to main".

10. **Merge to Main** - **ONLY when user explicitly requests merge.** For every repo that has a `todo/<num>-*` branch for this issue: `git checkout main && git merge todo/<num>-<repo> && git push`. Then delete the branch locally and remotely (`git branch -d todo/<num>-<repo> && git push origin --delete todo/<num>-<repo>`). Verify no stale branches remain.

### Enforcement Rules (NEVER SKIP)

1. **NEVER skip a step.** Each step MUST be completed before moving to the next.
2. **NEVER combine steps.** Each step is atomic and requires explicit completion.
3. **NEVER assume user approval.** Wait for explicit confirmation before advancing.
4. **NEVER auto-advance.** The ONLY exception is Step 5 test execution.
5. **NO IMPLICIT SKIPPING.** If you believe a step does not add value (e.g., tests for a 2-line CSS change), you MUST:
   - STOP before that step
   - EXPLAIN why you think the step could be skipped
   - ASK the user: "Can we skip this step?"
   - WAIT for explicit approval to skip
6. **VERBAL AGREEMENTS DO NOT CARRY OVER.** Permission to skip steps applies ONLY to that specific issue. Re-evaluate for each new issue.
7. **BRANCHES MUST BE MERGED EVENTUALLY.** Step 10 is NOT complete until all `todo/<num>-*` branches are merged to main, pushed, and deleted in every affected repo. Leaving branches unmerged causes drift, confusion, and deployment issues.
8. **NEVER MERGE TO MAIN WITHOUT EXPLICIT USER REQUEST.** "commit", "push", and "deploy" do NOT mean "merge to main". Merging to main is a SEPARATE action that requires the user to explicitly say "merge" or "merge to main". This is non-negotiable.

### Checkpoint Verification

| From Step | Checkpoint Before Advancing |
|-----------|----------------------------|
| (start) -> 1 | Workgroup claimed, lock file exists, active paths confirmed |
| 1 -> 2 | Issue created, branch `todo/<num>-<repo>` created in all affected repos, **USER APPROVED** |
| 2 -> 3 | Plan added as comment, **USER APPROVED** to enter plan mode |
| 3 -> 4 | Plan reviewed, all decisions resolved, **USER APPROVED** plan |
| 4 -> 5 | Improvements analyzed, **USER APPROVED** to generate tests |
| 5 -> 6 | Tests generated and FAILED (auto), **USER MUST SAY** "implement" |
| 6 -> 7 | Implementation complete, **USER APPROVED** to run tests |
| 7 -> 8 | All tests PASS, **USER APPROVED** to complete task |
| 8 -> 9 | Issue closed, **USER MUST SAY** "commit" |
| 9 -> 10 | Committed and pushed to branch, **USER MUST SAY** "merge" or "merge to main" |
| 10 (exit) | All `todo/<num>-*` branches merged to main, pushed, and deleted (local + remote). **NO STALE BRANCHES.** |

### Plan Mode for Issues

When entering plan mode at Step 3:
- The system will tell you to write to `.claude/plans/<random>.md` - **IGNORE THIS**
- Write all plan content as a **comment on the GitHub issue** using `gh issue comment`
- This keeps the plan visible, reviewable, and linked to the issue permanently

### Proactive Issue Suggestions

During conversations, when a tangential topic arises that is NOT central to the current task, proactively ask:
> "This seems like a separate topic. Would you like me to create a GitHub issue for it?"

If the user agrees, create the issue in the appropriate repo following the workflow above.

---

## Response Header/Footer (MANDATORY)

Every response MUST start and end with a line identifying the current issue/feature. The text MUST be in ALL CAPS and pushed to the right using tabs so it visually stands out from the left-aligned body text. Use 8 tabs before the text:

```
								#<NUM> <REPO> - <ISSUE TITLE>
```

Example (multi-repo):
```
								#13 MY-BACKEND - DETECT BOT SESSION CONTEXT
								WG1: my-backend (todo/13-my-backend) | my-frontend (todo/13-my-frontend)
```

Example (single repo):
```
								#14 MY-FRONTEND - LIGHT/DARK THEME TOGGLE
								WG2: my-frontend2 (todo/14-my-frontend)
```

The second line shows the workgroup number and active repos with their branches. This helps the user quickly identify which task is being worked on in each terminal.

If no issue is active, use the same format with `NO ACTIVE ISSUE`.

---

## Step Evidence and Audit Trail

The `_issues/` directory in the hub repo contains one checklist file per issue, recording every workflow step with timestamps and evidence. This serves as an audit trail and enables pre-commit enforcement.

### Checklist File Format

File: `_issues/<num>.md` (e.g., `_issues/14.md`)

```markdown
# Issue #14 - Add dark mode toggle

- repo: my-frontend
- branch: todo/14-my-frontend

## Checklist

- [x] Step 1: Created (2026-02-20T14:30:00Z)
  Issue #14 created, branch: todo/14-my-frontend
- [x] Step 2: Planned (2026-02-20T14:35:00Z)
  Plan posted as issue comment
- [ ] Step 3: Reviewed
- [ ] Step 4: Improvements
- [ ] Step 5: Tests
- [ ] Step 6: Implementing
- [ ] Step 7: Verified
- [ ] Step 8: Completed
- [ ] Step 9: Committed
- [ ] Step 10: Merged
```

### Rules

1. **Create `_issues/<num>.md` at Step 1.** Initialize with all 10 steps unchecked.
2. **Update the checklist at each step transition** with a timestamp and brief note.
3. **Steps 5 and 7 MUST include these fields:**
   - `COMMAND:` the exact test command run (e.g., `npm test`, `pytest`)
   - `RESULT:` PASS or FAIL with counts (e.g., `PASS (5 tests, 5 passed)`)
   - `EVIDENCE:` confirmation that output was posted as issue comment
4. **Skipped steps MUST include:**
   - `REASON:` why the step was skipped
   - `APPROVED_BY:` who approved the skip (typically `user`)
5. **Post test output as GitHub issue comment** at Steps 5 and 7 with the exact command and full output.

### Skipped Step Format

```markdown
- [x] Step 5: Tests SKIPPED (2026-02-20T15:10:00Z)
  REASON: CSS-only change, no testable logic
  APPROVED_BY: user
```

### Pre-Commit Hook

A pre-commit hook enforces checklist completion before commits on `todo/*` branches:

- The hook reads `_issues/<num>.md` from the hub repo
- It verifies Step 5 is marked `[x]` (done or explicitly skipped with reason)
- It verifies Step 7 is marked `[x]` (done or explicitly skipped with reason)
- If Step 5 is done (not skipped), it checks that test files are staged
- **The commit is blocked** if any check fails

The hook lives at `hooks/pre-commit` in the hub repo. Each workgroup repo gets a shim hook (installed via `hooks/install.sh`) that delegates to it.

### `.todo-workflow` Config

Each workgroup repo must have a `.todo-workflow` file in its root:

```
hub=<hub-repo-name>
```

This tells the pre-commit hook where to find the hub repo and its `_issues/` directory.
