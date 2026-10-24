#!/usr/bin/env sh
# Install the no-claude-coauthor hook globally (all repos on this machine).
set -e
SRC="$(CDPATH= cd -- "$(dirname "$0")/.." && pwd)/hooks/prepare-commit-msg"
[ -f "$SRC" ] || { echo "Cannot find hook at $SRC"; exit 1; }

EXISTING="$(git config --global core.hooksPath || true)"
if [ -n "$EXISTING" ]; then
    DEST="$(eval echo "$EXISTING")"       # expand ~ if present
    mkdir -p "$DEST"
    # Preserve a pre-existing global hook so our hook can chain to it.
    if [ -e "$DEST/prepare-commit-msg" ] \
       && ! grep -q 'no-claude-coauthor' "$DEST/prepare-commit-msg" 2>/dev/null; then
        mv "$DEST/prepare-commit-msg" "$DEST/prepare-commit-msg.local"
        echo "Preserved your existing hook as prepare-commit-msg.local"
    fi
else
    DEST="${XDG_CONFIG_HOME:-$HOME/.config}/git/hooks"
    mkdir -p "$DEST"
    git config --global core.hooksPath "$DEST"
    echo "Set global core.hooksPath -> $DEST"
fi

cp "$SRC" "$DEST/prepare-commit-msg"
chmod +x "$DEST/prepare-commit-msg"
echo "Installed. Claude will no longer be added as a contributor on new commits."
echo "To clean commits you already pushed, see scripts/clean-history.sh (per repo)."
