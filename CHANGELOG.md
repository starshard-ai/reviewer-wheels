# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

## [0.3.0] - 2026-09-02

### Added
- `viral-repo-triage` skill — triage protocol for the failure mode where a repo
  goes from quiet to thousands of stars in days with one human CODEOWNER, zero
  labels, and duplicate PRs competing for the same fix.
- GitHub governance kit — drop-in labels, path labelling, size labelling,
  duplicate-fix detection, claim expiry, stale handling, security routing,
  maintainer policy docs, and gated comment-only AI workflows.

## [0.2.0] - 2026-07-26

### Added
- `delegation-bound-gate` skill — launch-time bound (hard cap + partial-report
  contract) for subagent delegation, plus the measured procedure for judging a
  silent worker. Distilled from a real incident: an unbounded research subagent
  hung inside a web fetch with zero open sockets while the network was healthy,
  and ~2h were lost to blocking on it, guessing its state from file mtime, and
  hedging with a duplicate agent.
- Opt-in `PreToolUse` hook (`hook/delegation-bound-gate.py`) — advisory-only and
  fail-open. Shipped as a hook rather than guidance because the underlying rule
  had already been written in always-loaded instructions and violated four times;
  prose in context is not a control.

## [0.1.0] - 2026-06-13

### Added
- Initial public release of the `reviewer-wheels` plugin.
- `mirror-pair` skill — provider-neutral k=1 observer/executor loop with a
  closed-loop review receipt.
- `adversarial-reviewer-panel` skill — constraint-driven multi-persona review.
- `meta-pipeline-compiler` skill — reuse-check and capability promotion to stop
  rebuilding known wheels.
- `frontend-smoke-gate` skill — build/lint + real-page smoke + screenshot gate
  for user-facing UI, with a staged release guard.
- Plugin manifest, marketplace manifest, README, MIT license.
