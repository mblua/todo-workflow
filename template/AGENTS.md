# Agent Instructions
<!-- workflow-version: 0.0.1 -->

**CRITICAL:** ALWAYS read `README.md` first before starting any work. This file contains essential context about the project structure and how it works.

**CRITICAL:** Before executing `git commit`, ALWAYS ask the user for confirmation with a clear message showing: files to be committed, proposed commit message, and any other relevant details. **Exception:** When executing Step 9 (Commit) of the TO-DOs workflow, commit directly without asking. However, ALWAYS notify the user immediately after the commit with: commit hash, number of files changed, and a summary of changes.

**CRITICAL:** NEVER add API keys, passwords, tokens, or secrets in any file tracked by git. Secrets are ONLY allowed in files excluded by `.gitignore` (e.g., `.env`).

**CRITICAL:** NEVER run tests (`pytest`, `python -m pytest`, `npm test`, etc.) without explicit user instruction. If you believe tests should be run, ASK the user first before executing them.

## TO-DOs Directory

**MANDATORY:** When the user mentions "TODO", "TODOs", "TO-DO", or "pendientes", you MUST read `TO-DOs/AGENTS.md` first. That file contains all instructions for working with tasks.

**Language note:** In Spanish, "todo/todos" also means "all/everything". Use context:
- "que TODOs tenes" / "pendientes" / "pending" - refers to `TO-DOs/` directory
- "todos los archivos" / "todo el codigo" - Spanish word meaning "all"
