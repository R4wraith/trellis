#!/usr/bin/env bash
# Copy the harness skeleton into a target project's .claude/ folder.
# Usage: bash scripts/new-harness.sh /path/to/target-project
set -euo pipefail
here="$(cd "$(dirname "$0")/.." && pwd)"          # skill root
src="$here/assets/skeleton/dot-claude"
target="${1:?usage: new-harness.sh <target-project-dir>}"
mkdir -p "$target/.claude"
cp -r "$src/." "$target/.claude/"
chmod +x "$target/.claude/hooks/"*.sh "$target/.claude/scripts/"*.sh "$target/.claude/githooks/"* 2>/dev/null || true
echo "Skeleton copied to $target/.claude/"
echo "Next: fill the {{PLACEHOLDERS}} in CLAUDE.md, DESIGN.md, GOAL.md, STATE.md, PROGRESS.md, DECISIONS.md, README.md,"
echo "and generate one agents/<name>.md per component-owner (see the skill's references/agent-roster.md)."
echo "Check nothing was missed:  grep -rn '{{' \"$target/.claude\""
