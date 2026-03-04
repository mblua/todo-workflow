# Changelog

All notable changes to the todo-workflow template are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/). Versioning follows [Semantic Versioning](https://semver.org/).

**For adopters upgrading:** Each version entry lists exactly what changed in `template/CLAUDE.md`. Review the "Migration" note in each entry to know what to update in your adopted copy.

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
