# Changelog

All notable changes to this project are documented here. Format loosely follows
[Keep a Changelog](https://keepachangelog.com/); versions follow
[Semantic Versioning](https://semver.org/).

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
