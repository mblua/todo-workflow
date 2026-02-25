# Contributing to todo-workflow

## How to Contribute

### Reporting Issues

- Use GitHub Issues for bugs and feature requests
- Include steps to reproduce for bugs
- Describe the expected vs actual behavior

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Run through the testing checklist in CLAUDE.md
5. Submit a Pull Request

### Code Style

- Use Markdown for all documentation
- Keep lines under 120 characters when possible
- Use consistent heading levels (# for title, ## for sections)

### Hook Changes

When modifying `template/hooks/pre-commit`:

1. Ensure the script works in both Git Bash (Windows) and bash (Linux/Mac)
2. Run `bash -n template/hooks/pre-commit` to verify no syntax errors
3. Test that the checklist parsing matches the format documented in `template/CLAUDE.md`
4. The hook must exit 0 for non-`todo/*` branches (no enforcement outside the workflow)
5. The hook checks Step 5 (Verified) only - ensure the grep pattern matches the checklist format

### Template Changes

When modifying `template/CLAUDE.md`:

1. Ensure all placeholder variables use `{UPPER_SNAKE_CASE}` format
2. Verify no hardcoded paths, org names, or repo names remain
3. Check that step numbers are consistent (1-9) across:
   - The 9-Step Workflow section
   - The Checkpoint Verification table
   - The step labels (`step: 1-workgroup` through `step: 9-released`)
4. **MANDATORY: Increment `workflow-version`** in:
   - `template/CLAUDE.md`
   - `CLAUDE.md`

### Plugin Dependencies

The workflow depends on the `feature-dev` plugin for Step 3. When making changes:

- Do not remove or bypass the feature-dev integration
- If adding new plugin dependencies, document them in the Plugin Dependencies section of the template
- Test that the workflow still functions if feature-dev produces unexpected output

### Parameterization

The template uses 4 placeholder variables that get replaced during adoption:

| Placeholder | Purpose |
|-------------|---------|
| `{WORKGROUP_BASE_PATH}` | Base directory containing all repos |
| `{WORKGROUP_HUB_REPO}` | Name of the coordination hub repo |
| `{WORKGROUP_REPOS}` | Comma-separated list of repos in each workgroup |
| `{GITHUB_ORG}` | GitHub organization or username |

**Rules for adding new placeholders:**
- Use `{UPPER_SNAKE_CASE}` format
- Document the new variable in the Project Configuration section of `template/CLAUDE.md`
- Add the variable to ADOPTION.md Step 1 (Gather Configuration)
- Add the variable to CLAUDE.md Guidelines section
- This constitutes a MAJOR version bump (breaking change for existing adopters)

### Validation

Before submitting a PR, verify that `template/CLAUDE.md` contains no literal values that should be placeholders. Quick check:

```bash
# Should find ONLY the placeholder definitions, not literal values
grep -n "{" template/CLAUDE.md
```

### Versioning

The workflow uses semantic versioning (`MAJOR.MINOR.PATCH`) in the `<!-- workflow-version: X.Y.Z -->` comment at the top of template files.

**Rules:**
- **PATCH** (1.0.X): Bug fixes, typo corrections, clarifications
- **MINOR** (1.X.0): New features, new enforcements, new sections, new labels
- **MAJOR** (X.0.0): Breaking changes that require adopters to re-run adoption (placeholder renames, step reordering, removed sections, plugin dependency changes)

**CRITICAL:** Every change to `template/CLAUDE.md` MUST increment the version. Both `template/CLAUDE.md` and `CLAUDE.md` MUST always have the same version number.

## Development Setup

```bash
git clone https://github.com/mblua/todo-workflow.git
cd todo-workflow
git checkout -b feat/my-feature
```

## Questions?

Open an issue with the "question" label.
