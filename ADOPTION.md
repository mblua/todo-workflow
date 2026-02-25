# Adoption Process

Instructions for an AI agent to adopt the todo-workflow template into a target project.

## Prerequisites

- Target project is a git repository
- GitHub CLI (`gh`) is authenticated
- You know the GitHub org/username and repo names
- **Claude Code `feature-dev` plugin is installed** - Run `/feature-dev` to verify. This plugin is required for Step 3 of the workflow.

## Adoption Steps

### Step 1: Gather Configuration

Ask the user for 4 values:

| Variable | Question | Example |
|----------|----------|---------|
| `{WORKGROUP_BASE_PATH}` | What is the base directory containing all your repos? | `C:\Users\dev\projects` |
| `{WORKGROUP_HUB_REPO}` | Which repo is the coordination hub (where CLAUDE.md and workgroups/ will live)? | `my-developer` |
| `{WORKGROUP_REPOS}` | What repos should be part of each workgroup? (comma-separated) | `my-backend, my-frontend, my-portal` |
| `{GITHUB_ORG}` | What is your GitHub org or username? | `myorg` |

### Step 2: Check for Existing CLAUDE.md

Check if the target project already has a `CLAUDE.md`:

- **If it exists:** Read it. Warn the user that adoption will **append** the workflow sections. Existing content will be preserved above the workflow sections. Ask for confirmation before proceeding.
- **If it does not exist:** Proceed to Step 3.

### Step 3: Create Parameterized CLAUDE.md

1. Read `template/CLAUDE.md` from this repo
2. Replace all placeholders with the user's values:
   - `{WORKGROUP_BASE_PATH}` -> user's base path
   - `{WORKGROUP_HUB_REPO}` -> user's hub repo name
   - `{WORKGROUP_REPOS}` -> user's repo list
   - `{GITHUB_ORG}` -> user's org/username
3. Write the result to `CLAUDE.md` in the target hub repo root
   - If an existing CLAUDE.md was found in Step 2, append the workflow content after the existing content with a clear separator (`---`)

### Step 4: Create workgroups/ Directory

In the target hub repo:

```bash
mkdir -p workgroups
touch workgroups/.gitkeep
```

If the hub repo has a `.gitignore`, add:
```
workgroups/*.lock
```

If there is no `.gitignore`, create one with:
```
workgroups/*.lock
```

### Step 5: Verify Workgroup Repo Clones

For each repo in `{WORKGROUP_REPOS}`:
1. Check if the directory exists at `{WORKGROUP_BASE_PATH}/<repo-name>`
2. If missing, inform the user: "Repo `<repo-name>` not found at `<path>`. Clone it or skip?"
3. Do NOT clone automatically without user approval

### Step 6: Set Up GitHub Labels

For each repo in `{WORKGROUP_REPOS}` and the hub repo itself, create the required labels:

```bash
# Run for EACH repo
REPO="{GITHUB_ORG}/<repo-name>"

# Priority labels
gh label create "priority: critical" --color D73A4A --description "Blocker, system down or data corruption" --repo $REPO 2>/dev/null || true
gh label create "priority: high" --color FF6B35 --description "Core functionality broken, no workaround" --repo $REPO 2>/dev/null || true
gh label create "priority: medium" --color FFC107 --description "Important bug or feature but with workaround" --repo $REPO 2>/dev/null || true
gh label create "priority: low" --color 0E8A16 --description "Minor improvement, cosmetic, nice-to-have" --repo $REPO 2>/dev/null || true

# Step labels (9-step workflow)
gh label create "step: 1-workgroup" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 2-created" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 3-developing" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 4-documented" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 5-verified" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 6-completed" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 7-committed" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 8-merged" --color C5DEF5 --repo $REPO 2>/dev/null || true
gh label create "step: 9-released" --color C5DEF5 --repo $REPO 2>/dev/null || true

# Type labels
gh label create "type: feature" --color 1D76DB --repo $REPO 2>/dev/null || true
gh label create "type: bug" --color D73A4A --repo $REPO 2>/dev/null || true
gh label create "type: security" --color B60205 --repo $REPO 2>/dev/null || true
gh label create "type: ux" --color 5319E7 --repo $REPO 2>/dev/null || true
gh label create "type: infra" --color 006B75 --repo $REPO 2>/dev/null || true
```

Note: `2>/dev/null || true` suppresses errors if labels already exist.

### Step 7: Create `_issues/` Directory

In the target hub repo:

```bash
mkdir -p _issues
touch _issues/.gitkeep
```

This directory will contain one checklist file per issue, serving as an audit trail for the 9-step workflow.

### Step 8: Create `.todo-workflow` in Each Workgroup Repo

For each repo in `{WORKGROUP_REPOS}`, create a `.todo-workflow` file in the repo root:

```
hub={WORKGROUP_HUB_REPO}
```

This file tells the pre-commit hook where to find the hub repo. Replace `{WORKGROUP_HUB_REPO}` with the actual hub repo name. Commit this file.

### Step 9: Install Pre-Commit Hooks

Copy `hooks/pre-commit` and `hooks/install.sh` from this template repo into the hub repo:

```bash
mkdir -p hooks
# Copy hooks/pre-commit and hooks/install.sh from the template
```

Then run the installer from the hub repo root:

```bash
bash hooks/install.sh repo1 repo2 ...
```

Replace `repo1 repo2 ...` with the actual repo names from `{WORKGROUP_REPOS}`. This installs a shim hook in each repo's `.git/hooks/pre-commit` that delegates to the hub's enforcement script.

**Note:** The shim hooks live in `.git/hooks/` (not committed to git). They must be reinstalled after a fresh clone.

### Step 10: Verify Installation

Run these checks and report results:

1. `CLAUDE.md` exists in hub repo root and contains no remaining `{...}` placeholders
2. `workgroups/` directory exists with `.gitkeep`
3. `.gitignore` contains `workgroups/*.lock`
4. GitHub labels exist in all repos (spot-check: `gh label list --repo {GITHUB_ORG}/<repo> --json name --jq '.[].name' | grep "step:"`)
5. `_issues/` directory exists with `.gitkeep`
6. `.todo-workflow` exists in each workgroup repo with correct hub name
7. `hooks/pre-commit` exists in the hub repo
8. Pre-commit shim installed in each workgroup repo (check `.git/hooks/pre-commit` exists)
9. `feature-dev` plugin is available (run `/feature-dev` to verify)

### Step 11: Inform User

Display a summary:

```
Workflow adopted successfully.

Hub repo:    {WORKGROUP_HUB_REPO}
Repos:       {WORKGROUP_REPOS}
GitHub org:  {GITHUB_ORG}
Base path:   {WORKGROUP_BASE_PATH}

Files created/modified:
  - {WORKGROUP_HUB_REPO}/CLAUDE.md (workflow template)
  - {WORKGROUP_HUB_REPO}/workgroups/.gitkeep
  - {WORKGROUP_HUB_REPO}/.gitignore (updated)
  - {WORKGROUP_HUB_REPO}/_issues/.gitkeep (audit trail)
  - {WORKGROUP_HUB_REPO}/hooks/pre-commit (enforcement hook)
  - {WORKGROUP_HUB_REPO}/hooks/install.sh (hook installer)
  - GitHub labels created in all repos
  - .todo-workflow created in each workgroup repo
  - Pre-commit hooks installed in each workgroup repo

Plugin dependency: feature-dev (required for Step 3)

Next: Open Claude Code in your hub repo. It will read CLAUDE.md
and start the workflow with Step 1 (Claim Workgroup).
```

## Troubleshooting

**Labels already exist:** The `2>/dev/null || true` in the label creation commands suppresses "already exists" errors. This is intentional - adoption is idempotent.

**Existing CLAUDE.md:** The adoption process appends workflow content. If the merge looks wrong, the user can manually reorganize sections.

**Single-repo projects:** Set `{WORKGROUP_HUB_REPO}` and `{WORKGROUP_REPOS}` to the same repo name. The workgroup system still works - it just manages one repo per group instead of many.

**feature-dev not found:** The `feature-dev` plugin must be installed in Claude Code. Check that the skill is available by running `/feature-dev` in a Claude Code session. If missing, install it following the Claude Code plugin documentation.
