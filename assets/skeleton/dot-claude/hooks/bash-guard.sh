#!/usr/bin/env bash
# Blocks destructive / pipe-to-shell / history-rewrite bash. Exit 2 = hard block (Claude sees stderr).
set -uo pipefail
input="$(cat)"
cmd="$(printf '%s' "$input" | python3 -c 'import sys,json; print(json.load(sys.stdin).get("tool_input",{}).get("command",""))' 2>/dev/null || true)"
[ -z "${cmd:-}" ] && exit 0
low="$(printf '%s' "$cmd" | tr "[:upper:]" "[:lower:]")"
block() { echo "guard BLOCKED: $1" >&2; echo "command: $cmd" >&2; exit 2; }

echo "$low" | grep -Eq 'rm[[:space:]]+(-[a-z]*r[a-z]*f|-[a-z]*f[a-z]*r)[[:space:]]+(/|/\*|~|\$home|/etc|/usr|/var|/boot|\.\.)' && block "recursive force-delete of a protected path"
echo "$low" | grep -Eq 'mkfs|dd[[:space:]]+[^|]*of=/dev/|>[[:space:]]*/dev/sd|:\(\)[[:space:]]*\{[[:space:]]*:[[:space:]]*\|[[:space:]]*:' && block "disk-destructive or forkbomb"
echo "$low" | grep -Eq '(curl|wget|fetch)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba)?sh([[:space:]]|$)' && block "piping remote content into a shell"
echo "$low" | grep -Eq 'git[[:space:]]+push[[:space:]]+[^&|;]*(--force([[:space:]]|=|$)|[[:space:]]-f([[:space:]]|$))' && block "git force-push"
echo "$low" | grep -Eq 'git[[:space:]]+(rebase|reset[[:space:]]+--hard|filter-branch|filter-repo|reflog[[:space:]]+expire)' && block "git history rewrite"
exit 0
