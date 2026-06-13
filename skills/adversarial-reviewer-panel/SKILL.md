---
name: adversarial-reviewer-panel
description: Use when you want to call AI reviewers, internal reviewers, famous-persona cross-checks, or want a theory/architecture/strategy examined from several constraint classes before implementation.
---

# Adversarial Reviewer Panel

## Purpose

Turn "ask reviewers" into a constraint-driven review loop, not a chorus of
interesting opinions.

Use reviewers to find what a theory, design, or decision **forbids, predicts,
breaks, or operationally changes**.

## Default Execution Model

The valuable unit is the **reviewer persona prompt bound to a constraint**, not
a specific model provider. Use any strong models (GPT / Claude / Gemini / local
models) as interchangeable executors. If a given reviewer bridge is unstable, do
not block the mainline; create a local copy-pasteable reviewer packet and run a
deterministic synthesis, or queue the packet for any available strong executor.

Default order:

1. Design 3-5 persona reviewers from constraint classes.
2. Write each persona as an operational prompt: what it forbids, what it tests,
   what concrete action it would change.
3. Launch model reviewers only when the bridge is healthy or the risk class
   justifies waiting.
4. If bridge launch fails or is slow, record `Review sanity-check:
   unavailable/pending`, keep reversible implementation moving, and preserve
   the persona packet as the review artifact.

## Default Panel

Pick 3-5 reviewers by constraint class, not by vibe:

- **Physics / measurement / falsifiability**: overclaim check; operational tests.
- **Practice / ethics / relationships**: concrete behavior, role boundaries, ritual, trust.
- **Public reality / social legitimacy**: how others can reject, misunderstand, exit, or audit.
- **Control systems / safety**: feedback loops, brakes, error amplification, rollback.
- **HCI / product**: what the user actually perceives, what reduces friction.
- **Embodied / contemplative / apophatic**: for consciousness, interface,
  spirituality-adjacent, or body-insight questions, check whether the agent is
  mistaking language, logic, or model-compressed concepts for direct realization
  or lived reality.
- **Physics / metaphysics bridge**: when a topic compares physics with
  metaphysics, do not use "metaphysics" as a dismissal. Treat them as
  potentially different epistemic interfaces: third-person
  measurement/reproducibility vs. first-person embodied realization. The task is
  to map correspondences and boundaries without borrowing authority across
  domains.

Named personas are encouraged as mnemonic handles, but each must carry a
constraint. Examples: Planck = measurement/falsifiability, Confucius = lived
conduct/ritual, Arendt = plurality/public reality, Dijkstra = complexity and
invariant discipline, Shannon = channel/noise/coding limits, Grace Hopper =
operational debuggability and user tooling.

## Reviewer Prompt Contract

Every reviewer receives a compact packet with:

- decision question or theory claim,
- source facts/artifact paths,
- the constraint class they own,
- explicit instruction to avoid generic praise.

Require this output:

1. Strongest insight.
2. Main overclaim / self-delusion / failure mode.
3. One concrete design or action implication.
4. One disconfirming observation or anti-signal.
5. How the reviewer process itself should be improved.

## Integration Contract

The synthesizing agent must synthesize, not paste reviewer chatter. Surface only:

- the shared conclusion,
- material disagreements,
- action/design implication,
- falsifiable test or anti-signal,
- next owner gate if any.

If reviewers agree too easily, add a hostile constraint reviewer or ask:

```text
What would make this beautiful theory false, harmful, or useless tomorrow?
```

For embodied/contemplative topics, also ask:

```text
What is being lost because this review is made of language? Where might the
model be confusing a sayable map for the lived territory?
```

For physics/metaphysics bridge topics, also ask:

```text
Which claim belongs to third-person measurement, which belongs to first-person
transformation, and what would make them two projections of one underlying
structure rather than a category error?
```

## Meta-Optimization Loop

After each important review, update the panel recipe:

- Which reviewer caught a real risk?
- Which reviewer produced decorative language?
- Which missing constraint would have changed the action?
- Did the review produce an implementation constraint, not just ontology?
- Did it reduce effort or merely add discourse?

Promote durable reviewer lessons to your persistent memory when they affect
future routing.

## Hard Boundaries

- Do not outsource the critical path to reviewers when deterministic low-risk
  implementation can continue.
- Do not let reviewers replace owner gates for money, identity, public
  commitment, privacy, account auth, or irreversible actions.
- Do not present reviewer personas as authorities; present their constraints.
