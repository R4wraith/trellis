#!/usr/bin/env bash
# Lint + dependency audit + secret sweep. Run at review time and pre-push.
set -uo pipefail
s=0; run(){ echo "--> $*"; "$@" || s=1; }
if [ -f Cargo.toml ] && command -v cargo >/dev/null; then
  run cargo fmt --all -- --check
  run cargo clippy --all-targets --all-features -- -D warnings
  command -v cargo-audit >/dev/null && run cargo audit || echo "    (cargo-audit not installed)"
fi
if [ -f go.mod ] && command -v go >/dev/null; then run go vet ./...; fi
if [ -f package.json ] && command -v npm >/dev/null; then run npm audit --audit-level=high; fi
command -v semgrep >/dev/null && run semgrep --error --config auto . || true
if command -v git >/dev/null && git rev-parse --git-dir >/dev/null 2>&1; then
  git grep -nIE -f .claude/hooks/secret-patterns.txt -- . >/dev/null 2>&1 && { echo "FAIL: secret-shaped string in tracked files"; s=1; }
fi
[ "$s" -eq 0 ] && echo "check: PASS" || echo "check: FAIL"
exit $s
