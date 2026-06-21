---
name: frontend-smoke-gate
description: Use when changing a user-facing frontend, dashboard, chat, mobile/web channel, notification surface, or any UI that a person is expected to personally try. Run build/lint plus a real-page smoke and screenshot/visual check before handoff.
---

# Frontend Smoke Gate

## Purpose

Prevent "code changed, user finds the obvious UI bug" loops. User-facing UI is
not ready until the agent has exercised the page and inspected the resulting
interface artifact.

## Required Gate

For non-trivial user-facing UI changes:

1. Run the repo's static gates: build/typecheck and lint when available.
2. Run or add a focused smoke script that opens the actual route, checks the
   relevant backend/API endpoints, and creates a screenshot artifact.
3. Inspect the screenshot yourself before reporting success.
4. Check for the common user-facing failures:
   - stale/test data leaking into the main UI,
   - old receipts shown as current replies,
   - cards or panels overlapping,
   - text clipping or unreadable density,
   - missing acknowledgement/result receipt,
   - layout broken on the primary target surface.
5. If the screenshot shows an obvious issue, patch and rerun the gate.

## Public/Live Release Guard

For public links, collaborator-facing pages, shared mobile pages, or any surface
another person may already be using:

1. Do not serve directly from the active worktree unless the service is explicitly
   marked local-only or experimental-private.
2. Create a staged release candidate first, run static checks, run a local
   staging server, and smoke the exact public route plus at least one backend
   receipt path.
3. Switch public traffic only after the staged release passes. Prefer a symlink,
   blue-green slot, named release directory, or equivalent atomic pointer
   change; keep the previous release for rollback.
4. If a live public link is down, first restore the last known-good release or
   transport, then continue development behind staging.
5. Report release status as: current public URL, release id/path, smoke result,
   rollback path, and remaining transport risk.

## Fallbacks

- If Playwright or a browser automation layer exists, prefer DOM assertions plus
  screenshot comparison.
- If it does not exist, use the platform browser plus a screen-capture tool; keep
  the screenshot path in the report and state any remaining manual/visual gap.
- Do not ask the user to inspect the UI first when the agent can open and inspect
  it locally.

## Output Contract

Report:

- user-visible change,
- validation commands and pass/fail,
- screenshot path for audit,
- remaining anti-signal or missing automation, if any.

<!-- skill-provenance:begin -->
provenance:
  maker:    Starshard
  homepage: https://github.com/starshard-ai
  source:   https://github.com/starshard-ai/reviewer-wheels
  license:  MIT
  version:  0.1.0
  contact:  https://github.com/starshard-ai/reviewer-wheels/issues
<!-- skill-provenance:end -->

---
*About the maker:* Starshard builds open agent skills; you can find the source and report issues at https://github.com/starshard-ai. License: MIT.
