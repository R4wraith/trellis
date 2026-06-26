#!/usr/bin/env bash
# After Edit/Write: block (exit 2) if the touched file contains a secret.
set -uo pipefail
PROJ="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PATTERNS="$PROJ/.claude/hooks/secret-patterns.txt"
input="$(cat)"
file="$(printf '%s' "$input" | python3 -c 'import sys,json
d=json.load(sys.stdin); ti=d.get("tool_input",{}) or {}
print(ti.get("file_path") or ti.get("path") or "")' 2>/dev/null || true)"
[ -z "${file:-}" ] && exit 0
[ -f "$file" ] || exit 0
if [ -f "$PATTERNS" ] && grep -EnH -f "$PATTERNS" "$file" >&2; then
  echo "guard: possible secret in $file — use env/secret store, don't commit it." >&2
  exit 2
fi
exit 0
