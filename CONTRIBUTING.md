# Contributing to TODO Workflow

Thank you for your interest in contributing!

## How to Contribute

### Reporting Issues

- Use GitHub Issues for bugs and feature requests
- Include steps to reproduce for bugs
- Describe the expected vs actual behavior

### Submitting Changes

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/my-feature`
3. Make your changes
4. Test the template files work correctly
5. Submit a Pull Request

### Code Style

- Use Markdown for all documentation
- Keep lines under 120 characters when possible
- Use consistent heading levels (# for title, ## for sections)

### Template Changes

When modifying files in `template/`:

1. Ensure all file paths are relative
2. Verify YAML frontmatter examples are valid
3. Test the workflow steps are consistent
4. **MANDATORY: Increment `workflow-version`** in ALL template files:
   - `template/AGENTS.md`
   - `template/TO-DOs/AGENTS.md`

### Versioning

The workflow uses semantic versioning (`MAJOR.MINOR.PATCH`) in the `<!-- workflow-version: X.Y.Z -->` comment at the top of template files.

**Rules:**
- **PATCH** (0.0.X): Bug fixes, typo corrections, clarifications
- **MINOR** (0.X.0): New features, new enforcements, new sections
- **MAJOR** (X.0.0): Breaking changes that require user action to adopt

**CRITICAL:** Every change to template files MUST increment the version. Both template files (`template/AGENTS.md` and `template/TO-DOs/AGENTS.md`) MUST always have the same version number.

## Development Setup

```bash
git clone https://github.com/mblua/todo-workflow.git
cd todo-workflow
git checkout -b feat/my-feature
```

## Questions?

Open an issue with the "question" label.
