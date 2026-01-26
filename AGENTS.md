# Agent Instructions for todo-workflow Repository

**CRITICAL:** This file contains instructions for working ON this repository (todo-workflow). This is NOT the file that gets copied to other projects.

## Repository Purpose

This repository provides a TODO workflow template for AI agents. The main deliverables are in the `template/` directory.

## Key Files

| File | Purpose |
|------|---------|
| `README.md` | User-facing documentation |
| `ADOPTION.md` | Instructions for agents adopting the workflow |
| `template/` | Files to copy to target projects |
| `docs/` | Additional documentation |

## When Making Changes

1. **Workflow logic changes** - Edit `template/TO-DOs/AGENTS.md`
2. **Root AGENTS.md changes** - Edit `template/AGENTS.md`
3. **Adoption process changes** - Edit `ADOPTION.md`
4. **Documentation changes** - Edit `README.md` or files in `docs/`

## TO-DOs Directory

**MANDATORY:** When the user mentions "TODO", "TODOs", "TO-DO", or "pendientes", you MUST read `TO-DOs/AGENTS.md` first. That file contains all instructions for working with tasks.

This repository uses its own TODO workflow for tracking development tasks.

## Testing Changes

Before committing changes to the template:

1. Verify YAML frontmatter examples are valid
2. Verify step numbers are consistent (1-9)
3. Verify checkpoint table matches step descriptions
4. Verify file paths are relative (no absolute paths)

## Commit Guidelines

- Use conventional commits: `feat:`, `fix:`, `docs:`, `chore:`
- Reference issues if applicable
- Keep template files self-contained (no external dependencies)
