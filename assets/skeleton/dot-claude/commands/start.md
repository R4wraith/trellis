---
description: Set up and start the autonomous build in one go.
---
First-time setup (idempotent — safe to re-run):
1. If this isn't a git repo yet, run `git init` (recommended). Then wire the optional git-layer safety hooks: `git config core.hooksPath .claude/githooks` and `chmod +x .claude/githooks/* .claude/hooks/*.sh .claude/scripts/*.sh`. (The Claude Code hooks in .claude/settings.json are already active regardless.)
2. Note the environment (OS, language toolchain present) and anything the project needs to run locally.
3. Confirm or change the language in .claude/DECISIONS.md (D2) before any keystone code is generated — ask me if unsure.

Then build:
4. Lock the mission (run the steps in `/goal`) and enter the autonomous loop (run `/loop`). Start with the **keystone** — the first scope in the build order, the one contract everything else binds to. Don't stop between slices; pause only for an irreversible action, a real fork, or a genuine blocker.

You're the lead engineer + PM: dispatch the specialist subagents in .claude/agents/, keep changes simple and surgical, verify before merging, keep commits clean, and prove each slice works in the actual build. Build something worth running.

$ARGUMENTS
