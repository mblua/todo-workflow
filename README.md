# todo-workflow

A production-proven template for multi-agent coordination with Claude Code. Four systems that work together: workgroup locking, GitHub Issues workflow, visual task identification, and step enforcement.

## Why Use This

**Problem:** Multiple Claude Code sessions working on related repos step on each other. Tasks tracked informally get lost. Terminal sessions are indistinguishable.

**Solution:** A single CLAUDE.md template that any project can adopt, bringing:

1. **Workgroup System** - Lock-based multi-agent coordination. Agents claim numbered workgroups before touching code. Lock files prevent conflicts. Stale locks auto-expire after 4 hours.

2. **GitHub Issues Workflow** - 10-step mandatory sequence from issue creation through merge. Labels track priority, type, and workflow step. Plans live as issue comments. Branches follow `todo/<num>-<repo>` convention.

3. **Response Header/Footer** - Every agent response identifies the active issue, repo, workgroup, and branch. When running 3 terminals, you instantly know which is doing what.

4. **Step Enforcement** - Audit trail (`_issues/` checklists), pre-commit hooks that block commits unless tests were run (or explicitly skipped with reason), and test evidence posted as GitHub issue comments. Silent skipping is no longer possible.

## Quick Start

Point Claude Code at this repo and say:

```
Adopt the workflow from https://github.com/mblua/todo-workflow into my project.
Read the ADOPTION.md file for instructions.
```

Or manually: copy `template/CLAUDE.md` to your project root, replace the 4 placeholders, create a `workgroups/` directory, and set up GitHub labels.

## Prerequisites

- [Claude Code](https://claude.ai/code) CLI installed
- [GitHub CLI](https://cli.github.com/) (`gh`) authenticated
- Git repos cloned locally

## Installation

### Automated (Recommended)

1. Open Claude Code in this repo
2. Say: "Adopt this workflow into my project at `<path>`"
3. The agent reads ADOPTION.md and walks you through configuration

### Manual

1. Copy `template/CLAUDE.md` to your target project root as `CLAUDE.md`
2. Replace these placeholders:

| Placeholder | Description | Example |
|-------------|-------------|---------|
| `{WORKGROUP_BASE_PATH}` | Base directory containing all repos | `C:\Users\dev\projects` |
| `{WORKGROUP_HUB_REPO}` | Coordination hub repo name | `my-developer` |
| `{WORKGROUP_REPOS}` | Comma-separated repo list | `my-backend, my-frontend, my-portal` |
| `{GITHUB_ORG}` | GitHub org or username | `myorg` |

3. Create `workgroups/` directory in your hub repo:
   ```bash
   mkdir -p workgroups
   touch workgroups/.gitkeep
   ```

4. Add to `.gitignore`:
   ```
   workgroups/*.lock
   ```

5. Create GitHub labels in each repo:
   ```bash
   # Priority labels
   gh label create "priority: critical" --color D73A4A --description "Blocker, system down or data corruption" --repo <org>/<repo>
   gh label create "priority: high" --color FF6B35 --description "Core functionality broken, no workaround" --repo <org>/<repo>
   gh label create "priority: medium" --color FFC107 --description "Important bug or feature but with workaround" --repo <org>/<repo>
   gh label create "priority: low" --color 0E8A16 --description "Minor improvement, cosmetic, nice-to-have" --repo <org>/<repo>


   # Step labels
   gh label create "step: 1-created" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 2-planned" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 3-reviewed" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 4-improvements" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 5-tests" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 6-implementing" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 7-verified" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 8-completed" --color C5DEF5 --repo <org>/<repo>
   gh label create "step: 9-committed" --color C5DEF5 --repo <org>/<repo>

   # Type labels
   gh label create "type: feature" --color 1D76DB --repo <org>/<repo>
   gh label create "type: bug" --color D73A4A --repo <org>/<repo>
   gh label create "type: security" --color B60205 --repo <org>/<repo>
   gh label create "type: ux" --color 5319E7 --repo <org>/<repo>
   gh label create "type: infra" --color 006B75 --repo <org>/<repo>
   ```

## File Structure After Adoption

```
your-hub-repo/
  CLAUDE.md              <-- Generated from template/CLAUDE.md
  .todo-workflow         <-- Hub config (hub=<name>)
  workgroups/
    .gitkeep
    workgroup-1.lock     <-- Created at runtime (gitignored)
    workgroup-2.lock     <-- Created at runtime (gitignored)
  _issues/
    .gitkeep
    14.md                <-- Checklist for issue #14 (committed)
    15.md                <-- Checklist for issue #15 (committed)
  hooks/
    pre-commit           <-- Enforcement hook (committed)
    install.sh           <-- Hook installer (committed)

your-workgroup-repo/
  .todo-workflow         <-- Points to hub repo (hub=<hub-name>)
  .git/hooks/pre-commit  <-- Shim hook (not committed, installed via install.sh)
```

## Example Configuration

For a project called "acme" with backend, frontend, and docs repos:

```
WORKGROUP_BASE_PATH = /home/dev/projects
WORKGROUP_HUB_REPO  = acme-hub
WORKGROUP_REPOS     = acme-backend, acme-frontend, acme-docs
GITHUB_ORG          = acme-org
```

This creates workgroups like:
- Group 1: `acme-backend`, `acme-frontend`, `acme-docs`
- Group 2: `acme-backend2`, `acme-frontend2`, `acme-docs2`

## Critical Analysis

This workflow was battle-tested on the [amplifyme.ai](https://amplifyme.ai) project. Here is an honest assessment of what it does and does not do:

**What works well:**
- Workgroup locking eliminates multi-agent file conflicts entirely
- The 10-step workflow prevents agents from racing ahead without approval
- Issue-linked branches create clean, traceable history
- Headers/footers make multi-terminal sessions manageable

**What this template cannot enforce:**

- **Test skipping now requires evidence.** Step 5 mandates TDD. In practice, tests were often skipped with user approval. The enforcement system (v1.1.0) now requires skipped steps to be recorded with a reason in the `_issues/` checklist, and the pre-commit hook blocks silent skipping. This does not guarantee tests are written, but it guarantees the skip is visible in the audit trail.
- **Deploy is 100% manual.** Step 10 merges to main. Deployment to production is a separate manual process (SCP, systemctl restart). This template has no deployment automation.
- **No staging environment.** Code goes from branch to main to production. There is no intermediate validation.
- **CI/CD was designed but never built.** The label system was meant to trigger GitHub Actions. That integration does not exist yet.
- **Critical config is not in git.** Runtime configuration (API keys, ports, paths) lives in config files on servers, not in version control.

**The lesson:** This template provides structure and guardrails. It cannot enforce discipline. The 10-step workflow is as useful as the team's commitment to following it.

## Documentation

- [ADOPTION.md](ADOPTION.md) - Automated adoption process for AI agents
- [CONTRIBUTING.md](CONTRIBUTING.md) - How to contribute to this template
- [docs/WORKFLOW_DIAGRAM.md](docs/WORKFLOW_DIAGRAM.md) - Visual diagrams of all systems
- [docs/EXAMPLES.md](docs/EXAMPLES.md) - Real-world usage examples

## License

MIT
