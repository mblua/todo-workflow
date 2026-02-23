#!/usr/bin/env bash
# todo-workflow hook installer
# Installs a shim pre-commit hook in each specified repo that delegates
# to the hub repo's hooks/pre-commit script.
#
# Usage: bash hooks/install.sh repo1 repo2 ...
# Run from the hub repo root directory.

set -euo pipefail

HUB_DIR=$(cd "$(dirname "$0")/.." && pwd)
PARENT_DIR=$(dirname "$HUB_DIR")
HUB_NAME=$(basename "$HUB_DIR")

if [[ $# -eq 0 ]]; then
    echo "Usage: bash hooks/install.sh repo1 repo2 ..."
    echo "Run from the hub repo root directory."
    echo ""
    echo "This installs a pre-commit hook shim in each repo that delegates"
    echo "to $HUB_NAME/hooks/pre-commit for enforcement."
    exit 1
fi

INSTALLED=0
FAILED=0

for REPO in "$@"; do
    REPO_PATH="$PARENT_DIR/$REPO"
    HOOKS_DIR="$REPO_PATH/.git/hooks"

    if [[ ! -d "$REPO_PATH/.git" ]]; then
        echo "SKIP: $REPO - not a git repo at $REPO_PATH"
        FAILED=$((FAILED + 1))
        continue
    fi

    mkdir -p "$HOOKS_DIR"

    # Write shim that delegates to hub's pre-commit hook
    cat > "$HOOKS_DIR/pre-commit" << SHIM
#!/usr/bin/env bash
# Auto-generated shim - delegates to hub repo's pre-commit hook
# Hub: $HUB_NAME
# Installed: $(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")

HUB_HOOK="\$(git rev-parse --show-toplevel)/../$HUB_NAME/hooks/pre-commit"

if [[ -f "\$HUB_HOOK" ]]; then
    exec bash "\$HUB_HOOK"
else
    echo "WARNING: Hub pre-commit hook not found at \$HUB_HOOK"
    echo "Skipping enforcement checks."
    exit 0
fi
SHIM

    chmod +x "$HOOKS_DIR/pre-commit"
    echo "OK: $REPO - hook installed"
    INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Done. Installed: $INSTALLED, Skipped: $FAILED"
