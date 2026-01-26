# Adoption Guide for AI Agents

**IMPORTANT:** This file contains instructions for AI agents to adopt the TODO workflow in a target project.

## When to Read This File

Read this file when a user says any of the following:
- "Adopt this workflow: https://github.com/mblua/todo-workflow"
- "Use the todo-workflow from mblua"
- "Set up TODO workflow from this repo"
- "Install todo-workflow in this project"

## Adoption Steps

### Step 1: Check for Existing AGENTS.md

```
Read the target project's AGENTS.md (if it exists)
```

- If **exists**: You will MERGE the TODO section into it (Step 3a)
- If **does not exist**: You will CREATE a new one (Step 3b)

### Step 2: Create TO-DOs Directory Structure

Create the following structure in the target project:

```
TO-DOs/
  AGENTS.md      # Copy from template/TO-DOs/AGENTS.md
  NEXT_ID.txt    # Create with content "001\n"
  DONE/
    .gitkeep     # Empty file to preserve directory
```

### Step 3a: Merge into Existing AGENTS.md

If the project already has an AGENTS.md, ADD this section to it:

```markdown
## TO-DOs Directory

**MANDATORY:** When the user mentions "TODO", "TODOs", "TO-DO", or "pendientes", you MUST read `TO-DOs/AGENTS.md` first. That file contains all instructions for working with tasks.

**Language note:** In Spanish, "todo/todos" also means "all/everything". Use context:
- "que TODOs tenes" / "pendientes" / "pending" - refers to `TO-DOs/` directory
- "todos los archivos" / "todo el codigo" - Spanish word meaning "all"
```

Also ADD this exception to any existing git commit rules:

```markdown
**Exception:** When executing Step 9 (Commit) of the TO-DOs workflow, commit directly without asking. However, ALWAYS notify the user immediately after the commit with: commit hash, number of files changed, and a summary of changes.
```

### Step 3b: Create New AGENTS.md

If no AGENTS.md exists, copy `template/AGENTS.md` to the project root.

### Step 4: Verify Installation

After adoption, verify these files exist:

| File | Purpose |
|------|---------|
| `AGENTS.md` | Contains TO-DOs section |
| `TO-DOs/AGENTS.md` | Complete workflow instructions |
| `TO-DOs/NEXT_ID.txt` | Contains "001" |
| `TO-DOs/DONE/.gitkeep` | Empty file |

### Step 5: Inform the User

After successful adoption, tell the user:

```
TODO workflow adopted successfully.

Created:
- TO-DOs/AGENTS.md (workflow instructions)
- TO-DOs/NEXT_ID.txt (initialized to 001)
- TO-DOs/DONE/ (for completed tasks)

Updated:
- AGENTS.md (added TODO section)

You can now say "create a TODO for X" and I will follow the 9-step workflow.
```

## Files to Copy

### template/TO-DOs/AGENTS.md

This is the complete workflow file. Copy it verbatim to `TO-DOs/AGENTS.md` in the target project.

### template/TO-DOs/NEXT_ID.txt

Create this file with a single line containing `001`.

### template/AGENTS.md

Use this as a reference for the AGENTS.md in the project root. If the project has no AGENTS.md, copy this file. If it has one, merge the relevant sections.

## Do NOT Copy

- This file (ADOPTION.md)
- README.md
- LICENSE
- docs/ directory
- Any .git files

## Post-Adoption Behavior

After adoption, when the user mentions TODOs:

1. **ALWAYS** read `TO-DOs/AGENTS.md` first
2. Follow the 9-step workflow exactly
3. Never skip steps
4. Never assume approval
5. The only automatic action is running tests in Step 5

## Troubleshooting

### "AGENTS.md already has TODO section"

If the project already has a TO-DOs section in AGENTS.md, verify it points to `TO-DOs/AGENTS.md`. If so, adoption may already be complete - just verify the files exist.

### "TO-DOs directory already exists"

Check if it contains the required files. If `AGENTS.md` is missing or outdated, update it. If `NEXT_ID.txt` exists with a value > 001, do NOT overwrite it.

### "Project uses different task system"

Ask the user if they want to:
1. Replace the existing system with TODO workflow
2. Keep both systems
3. Cancel adoption
