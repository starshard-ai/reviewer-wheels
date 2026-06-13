---
name: mirror-pair
description: Use when you want a bounded k=1 observer/executor Mirror Pair — one executor advances a task, one clean-context mirror checks drift/invariants/validation/closure. Provider-neutral: executor and mirror can each be any coding agent, in any mix. Use for "mirror pair", "observer/executor", "k=1 review", or bootstrapping a new line with a clean reviewer instead of acting alone.
metadata:
  short-description: Run a provider-neutral k=1 Mirror Pair (executor + clean-context mirror) with a closed-loop receipt.
---

# Mirror Pair (provider-neutral)

A Mirror Pair is the practical k=1 form of the observer/executor loop. It is NOT
session cloning: it is a bounded relation between one working **executor** and
one clean-context **mirror** that reviews compact state — it does not redo the
task.

## Topologies

Executor and mirror are each any coding agent you have available. Supported
mixes: same-provider executor + same-provider mirror, or any cross-provider
combination. Pick the mirror provider for a **different blind spot** than the
executor where possible (diversity > redundancy).

## 1. Create the state packet

Assemble a compact state packet for the mirror containing:

- `task-id` and a short title
- `goal` — the externally-visible goal
- `acceptance` — acceptance criteria
- `validation` — how to validate
- which agent is executor, which is mirror
- the expected artifact path and a source ref

The packet is deliberately smaller than full context — the mirror requests one
specific artifact if it needs more, never a raw transcript. Hold three files:
`state-packet.md`, `mirror-checklist.md`, `receipt.json`.

## 2. Run / ingest the mirror review

The mirror returns exactly five fields (strongest part · main drift/scope-creep
risk · missing closed-loop field · ready verdict · inspected/changed paths) and
ends with `VERDICT: <pass|prompt_adjust|pause_or_confirm|missing_receipt|scope_creep>`.

- **Headless dispatch** (bounded, preferred): dispatch the packet + checklist +
  artifacts to a clean-context agent in print mode, parse the verdict, and write
  the `mirror_review_receipt`. For interactive review instead, open a second
  agent terminal with the packet.
- **Cross-provider mirror**: when the mirror is a different provider that you
  cannot drive headlessly from the executor, write a `mirror-review-request.md`
  and hand it off; that session picks it up. Do NOT fake-execute another
  provider's session.
- **Ingest an already-written review** (deterministic): feed the written review
  back in to record the receipt.
- Override the verdict explicitly when you have a justified reason.

The `mirror_review_receipt` is the loop closure. A mirror comment without a
receipt is only a note.

## 3. Closure gate

A pilot closes only when: the executor artifact exists (or the blocker is
explicit), a mirror review receipt exists (or `observer_unavailable` /
`handoff_required` is recorded), validation passed/failed-with-reason/n-a, state
changed somewhere durable, the next expected event is clear, and the owner is
not asked to inspect raw execution detail. `closed_loop_complete` is true only
on `VERDICT: pass`.

## Anti-signals (abort / re-pair)

- Executor and mirror share the same blind spot and reinforce each other (use a
  cross-provider mix to break this).
- Mirror starts implementing instead of reviewing.
- Owner sees more provider/terminal detail instead of less.
- Task expands because the mirror introduced interesting-but-non-required work.
- Final report lacks validation or a next expected event.
