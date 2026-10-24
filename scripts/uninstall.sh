#!/usr/bin/env sh
set -e
HP="$(git config --global core.hooksPath || true)"
[ -n "$HP" ] || { echo "No global core.hooksPath set; nothing to do."; exit 0; }
DEST="$(eval echo "$HP")"
if grep -q 'no-claude-coauthor' "$DEST/prepare-commit-msg" 2>/dev/null; then
    rm -f "$DEST/prepare-commit-msg"
    if [ -e "$DEST/prepare-commit-msg.local" ]; then
        mv "$DEST/prepare-commit-msg.local" "$DEST/prepare-commit-msg"
        echo "Restored your previous prepare-commit-msg hook."
    fi
fi
# Only unset hooksPath if we created an otherwise-empty dir for it.
if [ -z "$(ls -A "$DEST" 2>/dev/null)" ]; then
    git config --global --unset core.hooksPath
    echo "Removed global core.hooksPath."
fi
echo "Uninstalled."
