<!-- workflow-version: 2.1.0 -->
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

## Plugin Dependencies

This workflow requires the **feature-dev** plugin for Claude Code. It handles codebase exploration, architecture design, implementation, and quality review through specialized agents (code-explorer, code-architect, code-reviewer).

**Verify:** Run `/feature-dev` in Claude Code. If it is not recognized, install it before proceeding.

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
`step: 1-workgroup` | `step: 2-created` | `step: 3-developing` | `step: 4-documented` | `step: 5-verified` | `step: 6-completed` | `step: 7-committed` | `step: 8-merged` | `step: 9-released`

**Type:** `type: feature` | `type: bug` | `type: security` | `type: ux` | `type: infra`

### Operations

| Action | Command |
|--------|---------|
| Create issue | `gh issue create --repo {GITHUB_ORG}/<repo> --title "..." --label "priority: X" --label "step: 2-created" --label "type: Y" --body "..."` |
| View issue | `gh issue view <num> --repo {GITHUB_ORG}/<repo>` |
| Update step | `gh issue edit <num> --repo {GITHUB_ORG}/<repo> --remove-label "step: old" --add-label "step: new"` |
| Add comment | `gh issue comment <num> --repo {GITHUB_ORG}/<repo> --body "..."` |
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

## 9-Step Workflow

**MANDATORY SEQUENCE** - Follow these steps in order for every task. The workflow wraps the `feature-dev` plugin: we handle GitHub tracking (issues, labels, audit trail, branches) and feature-dev handles development work (exploration, architecture, implementation, review).

1. **Claim Workgroup** - Read all `workgroups/workgroup-*.lock` files in `{WORKGROUP_BASE_PATH}/{WORKGROUP_HUB_REPO}/workgroups/`. Display workgroup status table (LOCKED / AVAILABLE / STALE / NOT PROVISIONED). Ask user which workgroup to use. **Wait for user response.** Create lock file with JSON (workgroup, locked_at, session_id, issue, repos). Verify repos exist on disk. Set active paths. **Sync all repos to latest main** (see rule below). Update label to `step: 1-workgroup`.

2. **Create Issue** - **Prerequisite: a workgroup must be claimed (lock file exists).** `gh issue create` with priority, step (`2-created`), and type labels. **Immediately create branch** `todo/<num>-<repo>` in every repo that will be modified. **Create `_issues/<num>.md`** in the hub repo with the initial checklist (see Step Evidence section). Confirm branch names to user. Update label to `step: 2-created`. **STOP.** Wait for user approval.

3. **Run /feature-dev** - Execute `/feature-dev <issue title and description>`. The plugin runs its phases: Discovery (pauses for user confirmation), Codebase Exploration (code-explorer agents), Clarifying Questions (pauses for user answers), Architecture Design (code-architect agents, pauses for user choice), Implementation (pauses for user approval, then implements), Quality Review (code-reviewer agents, pauses for user decision), Summary. Update label to `step: 3-developing` before launching. **STOP** after feature-dev completes.

4. **Post to Issue** - Capture feature-dev output and post a structured summary as issue comment: Discovery (what was understood), Exploration (key findings, architecture patterns), Clarifying Q&A (questions asked and answers received), Architecture (chosen approach and rationale), Implementation (what was built, files modified), Quality Review (issues found and resolved). Include Mermaid diagrams where relevant. Update label to `step: 4-documented`. **STOP.** Wait for user approval.

5. **Run Tests** - Run the project test suite (if it exists). Post test command + output as issue comment. Update `_issues/<num>.md` with COMMAND, RESULT, EVIDENCE. Update label to `step: 5-verified`. If no test suite exists: ask user if they want to skip (record skip with REASON). If tests fail: ask user to fix or proceed. **STOP.** Wait for user approval.

6. **Complete** - Close issue with `gh issue close`. Update label to `step: 6-completed`. **STOP.** Wait for user to say "commit".

7. **Commit and Push** - Commit with `#<num>: description` message. Push the `todo/<num>-*` branch to remote. Update label to `step: 7-committed`. **The pre-commit hook will verify the `_issues/<num>.md` checklist before allowing the commit.** **STOP.** Wait for user to explicitly say "merge" or "merge to main".

8. **Merge to Main** - **ONLY when user explicitly requests merge.** For every repo that has a `todo/<num>-*` branch: `git checkout main && git merge todo/<num>-<repo> && git push`. Delete the branch locally and remotely. Verify no stale branches remain. Update label to `step: 8-merged`.

9. **Release Workgroup** - Delete the lock file. This step is automatic after merge completes. Update label to `step: 9-released`.

### Repo Sync Rule (Step 1 - MANDATORY)

Before any work begins, **every repo in the workgroup MUST be on `main` at its latest remote state**. A repo left on a stale branch from a previous session will cause merge conflicts and wasted work.

**For each repo in the workgroup, run:**

```bash
git checkout main && git pull
```

**If `git checkout main` fails** (e.g., uncommitted changes from a crashed session), STOP and ask the user how to proceed. Do NOT force-checkout or discard changes.

**If `git pull` fails** (e.g., merge conflicts on main), STOP and ask the user. Do NOT auto-resolve.

This sync happens as part of Step 1 (Claim Workgroup), after the lock file is created and repos are verified on disk. Do NOT proceed to Step 2 until every repo reports `Already up to date` or successfully pulled new changes.

### Enforcement Rules (NEVER SKIP)

1. **NEVER skip a step.** Each step MUST be completed before moving to the next.
2. **NEVER combine steps.** Each step is atomic and requires explicit completion.
3. **NEVER assume user approval.** Wait for explicit confirmation before advancing.
4. **NEVER auto-advance.** Every step requires a user gate except Step 9 (automatic).
5. **NO IMPLICIT SKIPPING.** If you believe a step does not add value, you MUST:
   - STOP before that step
   - EXPLAIN why you think the step could be skipped
   - ASK the user: "Can we skip this step?"
   - WAIT for explicit approval to skip
6. **VERBAL AGREEMENTS DO NOT CARRY OVER.** Permission to skip steps applies ONLY to that specific issue.
7. **BRANCHES MUST BE MERGED EVENTUALLY.** Step 8 is NOT complete until all `todo/<num>-*` branches are merged to main, pushed, and deleted in every affected repo.
8. **NEVER MERGE TO MAIN WITHOUT EXPLICIT USER REQUEST.** "commit", "push", and "deploy" do NOT mean "merge to main". Merging requires the user to explicitly say "merge" or "merge to main".

### Checkpoint Verification

| From Step | Checkpoint Before Advancing |
|-----------|----------------------------|
| (start) -> 1 | Workgroup status displayed, **USER SELECTED** a workgroup |
| 1 -> 2 | Lock file created, repos verified, **all repos on `main` + pulled to latest**, **USER APPROVED** |
| 2 -> 3 | Issue created, branch created, `_issues/<num>.md` created, **USER APPROVED** |
| 3 -> 4 | feature-dev completed all phases, **USER APPROVED** |
| 4 -> 5 | Summary posted as issue comment, **USER APPROVED** |
| 5 -> 6 | Tests run (or skipped with reason), **USER APPROVED** |
| 6 -> 7 | Issue closed, **USER MUST SAY** "commit" |
| 7 -> 8 | Committed and pushed to branch, **USER MUST SAY** "merge" or "merge to main" |
| 8 -> 9 | All branches merged, pushed, deleted. Automatic. |

### Proactive Issue Suggestions

During conversations, when a tangential topic arises that is NOT central to the current task, proactively ask:
> "This seems like a separate topic. Would you like me to create a GitHub issue for it?"

If the user agrees, create the issue in the appropriate repo following the workflow above.

### Issue as Living Document

The GitHub issue is the single source of truth for everything that happens during a task. **Every analysis, decision, and finding MUST be posted as an issue comment.** This builds an incremental record that anyone (human or agent) can follow later.

**What to post as issue comments:**
- **Step 2:** Issue creation details and branch setup
- **Step 3:** feature-dev handles this internally (discovery, exploration, architecture, implementation, quality review)
- **Step 4:** Structured summary of everything feature-dev did (the primary documentation step)
- **Step 5:** Test command + full output

**Step 4 is the primary documentation step.** The summary should be detailed enough that someone reading the issue months later can understand every decision. Include:
- Mermaid diagrams showing architecture and data flows
- Comparison tables when alternatives were evaluated
- Code snippets showing key implementation details
- Clear rationale for every architectural decision

**Diagrams MUST use Mermaid.** GitHub renders Mermaid natively in issue comments. Use them for:
- Architecture diagrams from the exploration phase
- Data flow diagrams from the architecture phase
- Component interaction diagrams
- Before/after comparisons

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

The second line shows the workgroup number and active repos with their branches.

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

- [x] Step 1: Workgroup (2026-02-20T14:28:00Z)
  Claimed workgroup 2
- [x] Step 2: Created (2026-02-20T14:30:00Z)
  Issue #14 created, branch: todo/14-my-frontend
- [ ] Step 3: Developing
- [ ] Step 4: Documented
- [ ] Step 5: Verified
- [ ] Step 6: Completed
- [ ] Step 7: Committed
- [ ] Step 8: Merged
- [ ] Step 9: Released
```

### Rules

1. **Create `_issues/<num>.md` at Step 2.** Initialize with all 9 steps unchecked.
2. **Update the checklist at each step transition** with a timestamp and brief note.
3. **Step 5 MUST include these fields:**
   - `COMMAND:` the exact test command run (e.g., `npm test`, `pytest`)
   - `RESULT:` PASS or FAIL with counts (e.g., `PASS (5 tests, 5 passed)`)
   - `EVIDENCE:` confirmation that output was posted as issue comment
4. **Skipped steps MUST include:**
   - `REASON:` why the step was skipped
   - `APPROVED_BY:` who approved the skip (typically `user`)
5. **Post test output as GitHub issue comment** at Step 5 with the exact command and full output.

### Skipped Step Format

```markdown
- [x] Step 5: Verified SKIPPED (2026-02-20T15:10:00Z)
  REASON: CSS-only change, no testable logic
  APPROVED_BY: user
```

### Pre-Commit Hook

A pre-commit hook enforces checklist completion before commits on `todo/*` branches:

- The hook reads `_issues/<num>.md` from the hub repo
- It verifies Step 5 is marked `[x]` (done or explicitly skipped with reason)
- If Step 5 is done (not skipped), it checks that test files are staged
- **The commit is blocked** if the check fails

The hook lives at `hooks/pre-commit` in the hub repo. Each workgroup repo gets a shim hook (installed via `hooks/install.sh`) that delegates to it.

### `.todo-workflow` Config

Each workgroup repo must have a `.todo-workflow` file in its root:

```
hub=<hub-repo-name>
```

This tells the pre-commit hook where to find the hub repo and its `_issues/` directory.
