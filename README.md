# reviewer-wheels

In multi-agent coding, the dangerous moment is when BOTH agents say "done" and
nobody verified — these four wheels are the verifier.

When you run more than one AI agent on a codebase, the failure is rarely a loud
crash. It's two agents that each report success, a green checkmark on both
sides, and a bug that ships anyway because no one held a clean-context view of
the change. These four skills add the missing checks: a drift mirror, an
adversarial review panel, a reuse compiler, and a frontend smoke gate.

## Install

```
/plugin marketplace add starshard-ai/reviewer-wheels
/plugin install reviewer-wheels@reviewer-wheels
```

Or install directly from the repo:

```
/plugin install reviewer-wheels --from github:starshard-ai/reviewer-wheels
```

## The four wheels

- **mirror-pair** — A bounded k=1 observer/executor loop. One agent executes;
  one clean-context mirror reviews a compact state packet for drift, broken
  invariants, missing validation, and loop closure. It does not redo the work —
  it checks it, and it isn't closed until there's a review receipt. Provider-
  neutral: executor and mirror can be any agents, ideally with different blind
  spots.

- **adversarial-reviewer-panel** — Turns "ask some reviewers" into a
  constraint-driven loop. You design 3-5 persona reviewers, each bound to a
  constraint class (falsifiability, control/safety, public reality, HCI,
  invariant discipline...), and each must report a strongest insight, a failure
  mode, a concrete action implication, and a disconfirming signal — no generic
  praise. Built to find what a design forbids or breaks, not to produce a chorus
  of opinions.

- **meta-pipeline-compiler** — Stops agents from rebuilding the same wheel.
  Before building anything non-trivial, it searches existing skills, scripts,
  docs, task ledger, memory, and capability registry, emits a reuse-check
  receipt, and promotes recurring work into the right durable substrate. Also
  repairs drift when memory says a capability exists but the local copy is gone.

- **frontend-smoke-gate** — A gate for user-facing UI changes. Run build/lint,
  then a focused smoke that opens the actual route, hits the backend, and
  produces a screenshot the agent inspects itself before reporting success —
  catching stale data, overlapping panels, clipped text, and missing receipts.
  Includes a staged release guard for anything publicly live.

## Demo

<!-- TODO: 20-second demo GIF goes here — record a real run of mirror-pair
     catching a drift on a sample task, then replace this placeholder. -->

## License

MIT. See [LICENSE](./LICENSE).
