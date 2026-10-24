# No Claude Co-Author

Stop Claude — or any AI assistant — from showing up as a **contributor** on your
GitHub repos.

GitHub counts anyone listed in a `Co-Authored-By:` trailer as a contributor. AI
coding tools often append lines like:

```
Co-Authored-By: Claude <noreply@anthropic.com>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

…to every commit, so the assistant quietly becomes a contributor on each repo.
This tool removes those lines and keeps them out — **your real co-authors are
never touched.**

## Install (prevent it going forward)

```bash
git clone https://github.com/<you>/no-claude-coauthor
sh no-claude-coauthor/scripts/install.sh
```

That sets up a global `prepare-commit-msg` git hook. From then on, every commit
on the machine is cleaned automatically — from Claude Code, any other tool, or a
plain `git commit`. It chains safely to any hook you already have.

Undo with `sh no-claude-coauthor/scripts/uninstall.sh`.

## Clean commits you already pushed

History already written still credits the assistant. Inside the repo you want to
fix:

```bash
sh no-claude-coauthor/scripts/clean-history.sh
```

It shows the affected commits, confirms, rewrites them, and prints the
force-push command. **This rewrites history** (hashes change) and needs
`git push --force-with-lease`. Use it only on repos you control.

## Use it as a Claude Code skill / plugin

- **Skill:** `cp -r no-claude-coauthor/skills/no-claude-coauthor ~/.claude/skills/`
  then ask Claude Code to "stop adding Claude as a co-author".
- **Plugin:** this repo ships `.claude-plugin/plugin.json`; install it from a
  marketplace or locally.

## How it works

A `prepare-commit-msg` hook filters the commit message before the commit is
created, dropping only lines that match AI/Anthropic attribution:

- `Co-Authored-By: … Claude …` or `… Anthropic …`
- `Generated with Claude Code` (with or without the link)
- any line containing `noreply@anthropic.com`

It's a standard git hook, so it works outside Claude Code too.

## License

MIT
