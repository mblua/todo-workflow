<!-- workflow-version: 2.0.0 -->

# Working on this Repository

This file contains instructions for AI agents working **on the todo-workflow repo itself** (not for target projects that adopt the template).

## What This Repo Is

**todo-workflow** is a template repository. It contains a parameterized `CLAUDE.md` template that any project can adopt to get:

1. Workgroup-based multi-agent coordination
2. GitHub Issues 9-step workflow (with feature-dev integration)
3. Response header/footer convention
4. Step enforcement (audit trail, pre-commit hooks, issue evidence)

The repo ships no runnable code. It is pure documentation and template files.

## Key Files

| File | Purpose |
|------|---------|
| `template/CLAUDE.md` | The core template. This is what gets copied to target projects. |
| `template/workgroups/.gitkeep` | Directory structure for workgroup lock files. |
| `template/_issues/.gitkeep` | Directory structure for issue checklists (audit trail). |
| `template/.todo-workflow` | Config template pointing workgroup repos to the hub. |
| `template/hooks/pre-commit` | Enforcement hook that validates Step 5 in checklist before commits. |
| `template/hooks/install.sh` | Helper script to install shim hooks in workgroup repos. |
| `ADOPTION.md` | Step-by-step instructions for AI agents performing adoption. |
| `README.md` | Project overview, installation, critical analysis. |
| `CONTRIBUTING.md` | Contribution guidelines, versioning rules, placeholder syntax. |
| `docs/WORKFLOW_DIAGRAM.md` | Mermaid diagrams of all four systems plus feature-dev internal flow. |
| `docs/EXAMPLES.md` | Real-world usage examples including feature-dev and enforcement examples. |

## Making Changes

### Template Changes (`template/CLAUDE.md`)

This is the most sensitive file. Changes here affect every project that adopts the workflow.

**Before modifying:**
1. Read the current template completely
2. Understand which placeholder variables are used and where
3. Check that your change works with all placeholder combinations

**After modifying:**
1. Increment the version in the `<!-- workflow-version: X.Y.Z -->` comment
2. Update this file's version comment to match
3. Run through the testing checklist below
4. Update `docs/WORKFLOW_DIAGRAM.md` if step flow changed
5. Update `docs/EXAMPLES.md` if behavior changed

### Version Management

Current version: **2.0.0**

Version is tracked in:
- `template/CLAUDE.md` line 1: `<!-- workflow-version: 2.0.0 -->`
- `CLAUDE.md` (this file) line 1: `<!-- workflow-version: 2.0.0 -->`

Both MUST always match. Versioning rules:
- **PATCH** (1.0.X): Typos, clarifications, formatting fixes
- **MINOR** (1.X.0): New sections, new labels, new enforcement rules
- **MAJOR** (X.0.0): Breaking changes (placeholder renames, step reordering, removed sections, plugin dependency changes)

### Testing Checklist

Before committing template changes:

- [ ] All `{PLACEHOLDER}` variables are documented in the Project Configuration section
- [ ] Step numbers are consistent (1-9) across the workflow section, checkpoint table, and labels
- [ ] Checkpoint table matches step descriptions
- [ ] Enforcement rules reference correct step numbers
- [ ] No hardcoded paths, org names, or repo names (everything uses placeholders)
- [ ] Mermaid diagrams in `docs/WORKFLOW_DIAGRAM.md` reflect current flow
- [ ] `docs/EXAMPLES.md` examples are consistent with current template
- [ ] Version incremented in both `template/CLAUDE.md` and `CLAUDE.md`
- [ ] Pre-commit hook (`template/hooks/pre-commit`) has no syntax errors (`bash -n`)
- [ ] Checklist format in template matches what the hook parses (grep pattern for Step 5)
- [ ] `_issues/` directory and `.todo-workflow` config are documented in adoption steps
- [ ] Plugin dependencies (feature-dev) are documented in template and ADOPTION.md

### Critical Analysis Section

The README.md contains a "Critical Analysis" section documenting honest shortcomings observed in production. **This section must be maintained honestly.** If a weakness is fixed, update it. If a new one is discovered, add it. Do not remove criticisms to make the project look better.

## Guidelines

- Use **Mermaid** for all diagrams (no ASCII art)
- Keep `template/CLAUDE.md` under 400 lines
- Placeholders use the format `{UPPER_SNAKE_CASE}`
- Test placeholder replacement manually before committing
- The 4 current placeholders are: `{WORKGROUP_BASE_PATH}`, `{WORKGROUP_HUB_REPO}`, `{WORKGROUP_REPOS}`, `{GITHUB_ORG}`
