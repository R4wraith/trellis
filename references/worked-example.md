# Worked example — the AgentBox project

This is the canonical run of the process end-to-end. Use it as a template for how the interview, architecture pass, roster, and filled files fit together.

## Step 1 — The idea
- **One-sentence what:** runtime guardrails for AI coding agents — a single binary that watches what an agent does at the system level and stops the dangerous stuff.
- **Keystone:** a normalized **event schema** that both kernel events (exec/file/net) and agent events (tool/LLM calls) bind to, with a correlation field linking a syscall to the agent action that caused it.
- **Language:** Rust (parses hostile input at volume; memory safety matters; the YARA engine is Rust-native).
- **Components:** the schema; the kernel sensor + normalizer; the detection multiplexer; the periodic forensic reviewer.
- **Wrap:** Tetragon (eBPF + kernel enforcement) — don't write eBPF.
- **Scope:** localhost/Linux first; cloud + hosted-agent surfaces later.

## Step 2 — Architecture pass
- **Keystone first:** build the schema before anything emits or reads events; version it; make it codegen-friendly. Everything else binds to it.
- **Wrap > build:** Tetragon already does eBPF + kernel enforcement; the value is *above* the sensor (schema, correlation, detection, review). Decision D1.
- **Build order:** schema → tamper-evident log + regex/YARA → Sigma → forensic review → polish.
- **Scope + seam:** defer cloud/hosted; the **schema is the seam** that makes them cheap to add later.

## Step 3 — Roster
Spine (reviewer, test-engineer, integrator, release-manager, performance-engineer) + four component-owners:

- **schema-architect** (keystone) — envelope + typed bodies + correlation (exact/lineage/temporal/none) + hash-chain + semver; small but keeps every detection engine pluggable.
- **sensor-integrator** — wraps Tetragon; normalizer fills correlation by process lineage; detect-only fallback on old kernels; the normalizer is a hostile-input parser (bound, validate, no panics).
- **detection-engineer** — multiplexer routing by input type: regex (inline strings), YARA/yara-x (blobs), Sigma (event sequences); ML is a stub; heavy lanes async.
- **forensic-reviewer-engineer** — periodic LLM pass over the hash-chained log; sandboxed; no tools; treats log content as untrusted data; reports, never acts.

## Step 4 — Filled files (excerpts)

`DESIGN.md` centered on the keystone and build order. `DECISIONS.md` seeded with D1 (wrap Tetragon), D2 (Rust), D3 (claude-mem optional). `CLAUDE.md` carries the generic principles + the AgentBox-specific "what we're building" line, the roster, Rust as the hot-path language, and the build order. `STATE.md` first scope = the schema. `GOAL.md` = build a working, localhost-testable AgentBox, schema first, wrap Tetragon, detections on top, forensic review.

## The lesson
Notice what was *reused verbatim* (hooks, scripts, git hooks, commands, spine agents, the principles) versus what was *generated for this project* (the one-line what, the keystone, the build order, the four component-owners, the decisions). That split is exactly what the skill automates: copy the reusable harness, think hard about the project-specific parts.
