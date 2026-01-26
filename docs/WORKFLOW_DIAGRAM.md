# TODO Workflow Diagram

Visual representation of the 9-step TODO workflow.

## Flowchart

```mermaid
flowchart TD
    subgraph STEP1["Step 1: Create TODO"]
        S1A[Read NEXT_ID.txt] --> S1B[Create ###-description.md]
        S1B --> S1C[Add YAML frontmatter]
        S1C --> S1D[Increment NEXT_ID.txt]
        S1D --> S1E{{"STOP: Wait for approval"}}
    end

    subgraph STEP2["Step 2: Generate Plan"]
        S2A[Create ###_PLAN_NAME.md] --> S2B[Document approach]
        S2B --> S2C{{"STOP: Wait for plan mode approval"}}
    end

    subgraph STEP3["Step 3: Review Plan in Plan Mode"]
        S3A[Call EnterPlanMode] --> S3B[Explore codebase]
        S3B --> S3C[Validate assumptions]
        S3C --> S3D[Identify pending decisions]
        S3D --> S3E[Update plan file]
        S3E --> S3F[Call ExitPlanMode]
        S3F --> S3G{{"STOP: Wait for plan approval"}}
    end

    subgraph STEP4["Step 4: Analyze Improvements"]
        S4A[Review potential improvements] --> S4B[Document without scope creep]
        S4B --> S4C{{"STOP: Wait for improvements approval"}}
    end

    subgraph STEP5["Step 5: Generate Tests"]
        S5A[Write TDD tests] --> S5B[Execute tests]
        S5B --> S5C{Tests fail?}
        S5C -->|Yes| S5D[Correct - TDD working]
        S5C -->|No| S5E[Error - tests not validating new feature]
        S5D --> S5F{{"STOP: Wait for 'implement'"}}
    end

    subgraph STEP6["Step 6: Implement"]
        S6A[Change status to in_progress] --> S6B[Execute approved plan]
        S6B --> S6C{{"STOP: Wait for approval to run tests"}}
    end

    subgraph STEP7["Step 7: Run Tests"]
        S7A[Execute tests] --> S7B{Tests pass?}
        S7B -->|No| S7C[Fix implementation]
        S7C --> S7A
        S7B -->|Yes| S7D{{"STOP: Wait for approval to complete"}}
    end

    subgraph STEP8["Step 8: Complete Task"]
        S8A[Change status to completed] --> S8B[Move files to DONE/]
        S8B --> S8C{{"STOP: Wait for 'commit'"}}
    end

    subgraph STEP9["Step 9: Commit"]
        S9A[Stage related files] --> S9B[Commit with ###-todo-name message]
        S9B --> S9C[Inform user with hash and summary]
    end

    STEP1 -->|User approves| STEP2
    STEP2 -->|User approves plan mode| STEP3
    STEP3 -->|User approves plan| STEP4
    STEP4 -->|User approves improvements| STEP5
    STEP5 -->|User says 'implement'| STEP6
    STEP6 -->|User approves running tests| STEP7
    STEP7 -->|User approves completing| STEP8
    STEP8 -->|User says 'commit'| STEP9

    style S1E fill:#ffcccc
    style S2C fill:#ffcccc
    style S3G fill:#ffcccc
    style S4C fill:#ffcccc
    style S5F fill:#ffcccc
    style S6C fill:#ffcccc
    style S7D fill:#ffcccc
    style S8C fill:#ffcccc
    style S5B fill:#ccffcc
```

## Legend

| Color | Meaning |
|-------|---------|
| Red nodes | BLOCKER - Requires user approval to proceed |
| Green node | AUTOMATIC - Only action that runs without asking |

## Step Summary

| Step | Action | Blocker |
|------|--------|---------|
| 1 | Create TODO file | User must approve |
| 2 | Create plan file | User must approve plan mode |
| 3 | Validate plan in plan mode | User must approve plan |
| 4 | Analyze improvements | User must approve |
| 5 | Generate and run tests | User must say "implement" |
| 6 | Implement the plan | User must approve test run |
| 7 | Run tests | User must approve completion |
| 8 | Move files to DONE/ | User must say "commit" |
| 9 | Commit changes | None (final step) |

## Key Rules

1. **Never skip steps** - Each step must complete before the next
2. **Never combine steps** - Each step is atomic
3. **Never assume approval** - Wait for explicit user confirmation
4. **Only one auto-action** - Test execution in Step 5 is the only automatic action
