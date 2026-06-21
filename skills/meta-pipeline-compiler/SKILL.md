---
name: meta-pipeline-compiler
description: Use when a workflow, script, repo, skill, hook, prompt, memory, or capability should have become reusable already; when an agent repeatedly rebuilds a standard wheel; when persistent and local skill state has drifted; or when a new recurring toolchain should be discovered, registered, promoted, and kept in sync.
---

# Meta Pipeline Compiler

## Purpose

Convert recurring friction and repeated agent work into durable system machinery.

The failure mode to prevent: an agent handles a task once, writes a note, then
future agents rediscover or rebuild the same script, repo, skill, or workflow.

## Trigger Examples

- "Why didn't this become a reusable skill?"
- "We have done this kind of setup before."
- "Scan the filesystem and register existing tools."
- "Several scripts can chain into a toolchain."
- "Persistent memory says a skill exists but the local skills dir does not."
- "This should be documented well enough that every agent knows it exists."

## Substrate Decision

Choose the substrate first:

- Persistent memory store: authority, provenance, durable decision, or registry receipt.
- Skill: repeatable procedure, checklist, routing policy, or trigger language.
- Always-on rules file (e.g. an AGENTS/CLAUDE config): invariant that must apply before skill loading.
- Capability registry: reusable capability, provider, toolchain, health contract,
  freshness requirement, permissions, fallback, or drift-repair route.
- Task / dashboard: inventory, migration, repair, sync, or watcher work remains.
- Code/tool: deterministic repeated action should become an executable circuit.

Prefer compact "memory + skill + registry/task" over a long prose rule when the
behavior must survive provider or host changes.

## Workflow

1. Capture the source friction in one sentence.
2. Search before building:
   - local skill directories,
   - personal `bin`/scripts,
   - relevant project READMEs/docs,
   - the task ledger,
   - the persistent memory store,
   - the capability registry.
3. Classify existing artifacts:
   - ready to use,
   - usable but undocumented/unregistered,
   - duplicated,
   - drifted or missing locally,
   - secret/private and not shareable,
   - one-off and not worth promoting.
4. Emit a reuse-check receipt:
   - `searched`: locations checked,
   - `candidates`: artifacts considered,
   - `decision`: `reuse`, `extend`, `repair_drift`, `register`, `create_new`,
   - `justification`: why this is not rebuilding a known wheel,
   - `receipt_path`: file, memory entry, registry entry, or task id.
5. Register the reusable capability with a clear trigger, owner, substrate,
   health/freshness signal, safety boundary, fallback, and receipt path.
6. Promote recurring procedure into a skill or update an existing skill. Do not
   create near-duplicates.
7. If deterministic, add or point to a script/tool and a smoke check.
8. If work remains, create or reopen a task with owner, stage, next expected
   event, reminder policy, and anti-signals.
9. Write a memory receipt for non-trivial system mutations.

## Drift Repair Contract

When the persistent memory store, local skills, docs, and registry disagree:

1. Treat the disagreement as a real capability loss.
2. Reconstruct from the best surviving artifact when safe.
3. Register the restored artifact in the capability registry or task ledger.
4. Add validation so the next session can detect the drift without rereading
   raw transcripts.

## Toolchain Discovery Contract

When several existing tools can chain together, document the chain as a
capability, not just as separate scripts:

- intent it satisfies,
- ordered tools,
- inputs/outputs,
- authority and owner gates,
- health checks,
- failure/degradation behavior,
- where receipts land.

## Acceptance Trace

For important promotions, add a short trace artifact showing:

```yaml
need: "capability or friction"
searched:
  - local skills
  - bin/scripts
  - docs
  - task ledger
  - persistent memory store
  - capability registry
candidates_considered:
  - id_or_path: "..."
    result: "used | extended | drifted | rejected"
decision: "reuse | extend | repair_drift | register | create_new"
receipt: "memory id or path"
anti_signals:
  - "future agent rebuilds without citing a reuse-check receipt"
```

## Reporting

Surface only:

- what reusable mechanism was found or created,
- where it now lives,
- what triggers it,
- validation,
- remaining blocker or owner gate.

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
