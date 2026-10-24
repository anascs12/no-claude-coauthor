#!/usr/bin/env sh
# Rewrite the CURRENT repo's history to remove AI co-author / "Generated with"
# lines from past commits. This CHANGES commit hashes and requires a force-push.
# Run only on a repo you control. Shows affected commits first and asks to confirm.
set -e
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || { echo "Not a git repo."; exit 1; }

echo "Commits containing AI attribution:"
git log --format='%h %s' --grep='co-authored-by:.*claude\|generated with .*claude\|noreply@anthropic' -iE || true
N="$(git log --format='%H' --grep='co-authored-by:.*claude\|generated with .*claude\|noreply@anthropic' -iE | wc -l | tr -d ' ')"
echo
echo "$N commit(s) would be rewritten. This rewrites history and needs a force-push."
printf "Type 'yes' to proceed: "
read ans
[ "$ans" = "yes" ] || { echo "Aborted."; exit 1; }

FILTER='grep -ivE "co-authored-by:.*(claude|anthropic)|generated with .*claude( code)?|🤖[[:space:]]*generated with|noreply@anthropic\.com"'
if command -v git-filter-repo >/dev/null 2>&1; then
    git filter-repo --force --message-callback '
import re
msg = message.decode("utf-8", "replace")
msg = "\n".join(l for l in msg.splitlines() if not re.search(
    r"co-authored-by:.*(claude|anthropic)|generated with .*claude|generated with.*claude code|noreply@anthropic\.com",
    l, re.I))
return msg.encode("utf-8")
'
else
    echo "git-filter-repo not found; using filter-branch (slower)."
    FILTER_BRANCH_SQUELCH_WARNING=1 git filter-branch -f --msg-filter \
        "$FILTER" -- --all
fi
echo
echo "Done. Review with: git log"
echo "Then push with:   git push --force-with-lease origin <branch>"
