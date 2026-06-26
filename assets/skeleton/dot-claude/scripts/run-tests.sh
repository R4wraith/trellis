#!/usr/bin/env bash
set -uo pipefail
s=0
[ -f Cargo.toml ]   && command -v cargo >/dev/null && { echo "==> cargo test"; cargo test --all || s=1; }
[ -f go.mod ]       && command -v go    >/dev/null && { echo "==> go test";    go test ./...   || s=1; }
[ -f package.json ] && command -v npm   >/dev/null && { echo "==> npm test";   npm test --silent || s=1; }
[ "$s" -eq 0 ] && echo "tests: PASS" || echo "tests: FAIL"
exit $s
