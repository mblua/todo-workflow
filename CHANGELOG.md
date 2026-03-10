# Changelog

All notable changes to the todo-workflow template are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Semantic Versioning](https://semver.org/).

**For adopters upgrading:** Each version entry lists exactly what changed in `template/CLAUDE.md`. Review the "Migration" note in each entry to know what to update in your adopted copy.

---

## [3.1.0] - 2026-03-09

### Changed

- **Checklist filename convention changed:** `_issues/<num>.md` replaced by `_issues/<repo>-<num>.md` (e.g., `_issues/my-frontend-14.md` instead of `_issues/14.md`). This prevents collisions when issues in different repos share the same number (e.g., issue #14 in `my-backend` and issue #14 in `my-frontend` no longer overwrite each other).
- **Pre-commit hook updated:** The hook now derives the repo name from the working directory (stripping workgroup suffixes like `my-frontend3` -> `my-frontend`) and looks for `_issues/<repo>-<num>.md` instead of `_issues/<num>.md`. Error messages updated accordingly.
- **All documentation updated:** README, EXAMPLES, WORKFLOW_DIAGRAM, and template CLAUDE.md now reference the new `<repo>-<num>.md` naming convention.

### Migration

If you are upgrading from 3.0.0:

1. **Rename existing checklist files** in your hub repo: `_issues/<num>.md` -> `_issues/<repo>-<num>.md` (e.g., `mv _issues/14.md _issues/my-frontend-14.md`)
2. **Update `hooks/pre-commit`** in your hub repo. Copy from `template/hooks/pre-commit`. The key change is adding `REPO_NAME` derivation and updating the `CHECKLIST` path.
3. **Update references in your adopted `CLAUDE.md`**: replace all `_issues/<num>.md` with `_issues/<repo>-<num>.md`
4. Update the version comment in line 1 to `<!-- workflow-version: 3.1.0 -->`

---

## [3.0.0] - 2026-03-07

### Changed (BREAKING)

- **10-step workflow** replaces the 9-step workflow. Steps reordered: "Completed" (close issue) moved from Step 6 to Step 10 (final step). "Committed" moved from Step 7 to Step 6. "Merged" stays at Step 8.
- **Two new deploy steps:** Step 7 "Deploy to Lowers" (DEV/STAGE) after commit, Step 9 "Deploy to Prod" after merge. These replace the old Step 9 "Released" (which just released the workgroup lock).
- **Branch naming convention changed:** `todo/<num>-<repo>` replaced by `todo/<num>-<slug>` where `<slug>` is the issue title in kebab-case (e.g., `todo/14-add-dark-mode-toggle`). Branches are now self-descriptive instead of repeating the repo name.
- **Step labels renamed:** `step: 6-completed` -> `step: 6-committed`, `step: 7-committed` -> `step: 7-deployed-lowers`, `step: 8-merged` stays, `step: 9-released` -> `step: 9-deployed-prod`, new `step: 10-completed`.
- **Workgroup release is no longer a separate step.** Lock file deletion happens as part of Step 10 (Completed).
- **All steps now require user approval.** Previously Step 9 was automatic.

### Migration

If you are upgrading from 2.x:

1. **Delete old step labels** in each repo: `step: 6-completed`, `step: 7-committed`, `step: 9-released`
2. **Create new labels** in each repo: `step: 6-committed`, `step: 7-deployed-lowers`, `step: 9-deployed-prod`, `step: 10-completed` (note: `step: 8-merged` stays as-is)
3. **Update branch naming** in your adopted `CLAUDE.md`: replace all `todo/<num>-<repo>` with `todo/<num>-<slug>`
4. **Rewrite the step descriptions** (Steps 6-10) in your adopted `CLAUDE.md`. Copy from `template/CLAUDE.md`.
5. **Rewrite the checkpoint table** in your adopted `CLAUDE.md`. Copy from `template/CLAUDE.md`.
6. **Update the checklist template** in your adopted `CLAUDE.md` to show 10 steps instead of 9.
7. Update the step labels line to include all 10 labels.
8. Update the version comment in line 1 to `<!-- workflow-version: 3.0.0 -->`

---

## [2.1.0] - 2026-03-04

### Added

- **Repo Sync Rule (Step 1):** New dedicated section "Repo Sync Rule (Step 1 - MANDATORY)" making it explicit that every repo must run `git checkout main && git pull` before any work begins. Previously, Step 1 only said "Run `git pull`" without ensuring the repo was on the `main` branch first.
- **Error handling for sync:** The rule now specifies to STOP and ask the user if `git checkout main` or `git pull` fails (uncommitted changes, merge conflicts), instead of silently proceeding.
- **Checkpoint table update:** The 1->2 checkpoint now reads "all repos on `main` + pulled to latest" instead of just "git pulled".
- **This CHANGELOG file** so adopters can track what changed between versions and know where to focus when upgrading.

### Migration

If you are upgrading from 2.0.0:

1. In your adopted `CLAUDE.md`, find Step 1 and replace `Run git pull in all active repos` with `Sync all repos to latest main (see rule below)`
2. Add the new "Repo Sync Rule (Step 1 - MANDATORY)" section right before "Enforcement Rules (NEVER SKIP)". Copy it from `template/CLAUDE.md`.
3. In the Checkpoint Verification table, update the `1 -> 2` row to say `all repos on main + pulled to latest` instead of `git pulled`
4. Update the version comment in line 1 to `<!-- workflow-version: 2.1.0 -->`

---

## [2.0.0] - 2026-02-28

### Added

- 9-step workflow with feature-dev plugin integration
- Workgroup-based multi-agent coordination system
- GitHub Issues as task tracker with step labels
- Response header/footer convention
- Step enforcement system (audit trail in `_issues/`, pre-commit hook, issue evidence)
- Issue as Living Document pattern (Mermaid diagrams, structured comments)
- Checkpoint verification table
- Pre-commit hook enforcing Step 5 completion
- `.todo-workflow` config file for hub repo discovery

### Migration

Initial release. Follow `ADOPTION.md` for first-time setup.

---

## [1.2.0] - 2026-02-25

### Added

- Issue as living document: publish analysis at every step with Mermaid diagrams
- Priority label descriptions

---

## [1.1.0] - 2026-02-24

### Added

- Step enforcement system (audit trail, pre-commit hook, issue evidence)

---

## [1.0.0] - 2026-02-23

### Added

- Initial template with workgroup system and GitHub Issues workflow
