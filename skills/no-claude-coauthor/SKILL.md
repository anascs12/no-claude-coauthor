---
name: no-claude-coauthor
description: >-
  Stop Claude or any AI assistant from appearing as a GitHub contributor. Use
  when the user wants to remove "Co-Authored-By: Claude", "Generated with Claude
  Code", or AI co-author trailers from commits, or prevent them going forward.
  Installs a global git prepare-commit-msg hook; includes an opt-in history cleaner.
---

# No Claude Co-Author

GitHub lists anyone named in a `Co-Authored-By:` trailer as a contributor. When
commits carry `Co-Authored-By: Claude <noreply@anthropic.com>` or a "Generated
with Claude Code" line, Claude becomes a contributor on the repo. This removes
those lines and keeps them out going forward, in every repo on the machine.

Real human co-authors are never touched — only AI/Anthropic trailers.

## Prevent it going forward (recommended)

```bash
sh scripts/install.sh
```

Installs a global `prepare-commit-msg` hook (via `git config --global
core.hooksPath`). It runs on every commit, chains to any existing global or
repo-local hook, and strips AI attribution lines last. Works no matter what
makes the commit — Claude Code, another tool, or a manual `git commit`.

Undo any time:

```bash
sh scripts/uninstall.sh
```

## Clean commits you already pushed (opt-in, per repo)

Past commits keep attributing Claude until history is rewritten. From inside the
repo you want to clean:

```bash
sh scripts/clean-history.sh
```

It lists the affected commits, asks you to type `yes`, rewrites messages (using
`git filter-repo` if present, else `filter-branch`), and prints the force-push
command. **This changes commit hashes** and needs
`git push --force-with-lease`. Only run it on repos you control, and coordinate
with collaborators first.

## What gets stripped

Lines matching any of:
- `Co-Authored-By: ... Claude ...` / `... Anthropic ...`
- `Generated with Claude Code` (with or without the markdown link)
- a line containing `noreply@anthropic.com`
- the `🤖 Generated with` line

## Notes

- This is a plain git hook, so it also protects commits made outside Claude Code.
- It does not edit PR descriptions on GitHub; to keep those clean, don't add the
  "Generated with Claude Code" line when opening PRs.
