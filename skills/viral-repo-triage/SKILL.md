---
name: viral-repo-triage
description: Use when open PRs or untriaged issues exceed roughly ten, or when one human CODEOWNER is the review bottleneck for a fast-growing repository.
---

# Viral Repo Triage

## Purpose

Keep a suddenly popular repository from turning maintainer attention into the
critical path for every low-level decision.

The maintainer's scarce job is merge and close authority. Everything upstream of
that decision can be made mechanical, labelled, and auditable: first-pass issue
triage, duplicate linking, claim arbitration, stale handling, first-pass review,
security redirection, and weekly digesting.

## The failure it prevents

A repo can go from calm to flooded before its process exists. One human
CODEOWNER becomes the only reviewer, issues arrive with no labels, contributors
open duplicate PRs for the same fix, and a security-flavoured issue sits in a
public thread because nobody routed it.

This wheel prevents the quiet failure where everyone is active but no state
machine exists, so duplicate work ships or nothing ships.

## Trigger

Use this skill when any of these are true:

- Open PRs are above roughly ten.
- Untriaged issues are above roughly ten.
- CODEOWNERS resolves to one human for most paths.

## Roles

**Human maintainer:** merge authority and close authority. The maintainer
decides what enters the project and what is rejected.

**Agent triager:** labels, links duplicates, requests missing information,
performs first-pass review, drafts digests, and keeps receipts. The agent:

- NEVER merges.
- NEVER closes without a stated reason and the right label.
- NEVER edits CODEOWNERS, LICENSE, or the security policy.
- NEVER turns a policy question into repeated per-PR maintainer interruptions.

## Issue State Machine

Every new issue starts at `status/needs-triage`, then moves to exactly one of:

| State | Meaning |
|---|---|
| `status/needs-info` | The report is missing reproduction, expected behavior, environment, logs, or a minimal example. |
| `status/accepted` | The maintainer accepts the problem or request as in scope. |
| `status/duplicate` | The issue duplicates an existing issue; link the canonical thread. |
| `status/wontfix` | The maintainer has rejected it, with a short reason. |
| `kind/security` | Possible vulnerability or secret exposure. Move to a private vulnerability report within 24h. |

For `kind/security`, do not discuss exploit details in public. The agent posts
only this redirect template:

```md
Thanks — if this involves a vulnerability, please use the private report form at
`https://github.com/OWNER/REPO/security/advisories/new`. Please don't post
exploit details here. A maintainer will acknowledge within 24h.
```

## PR State Machine

Every new PR starts at `status/needs-triage`, then moves to one of:

| State | Meaning |
|---|---|
| `status/claimed` | Work is linked to a first-wins claim on an issue. |
| `status/needs-changes` | First-pass review found concrete gaps. |
| `status/ready-for-maintainer` | Scope, verification, tests/docs, and policy checks are ready for a human decision. |
| `status/superseded` | Another open PR is preferred for the same issue or same file-level fix. |
| `status/needs-policy` | The PR changes project scope before policy exists, such as a new integration or provider. |

## Claim Rule

A `/claim` comment on an issue is first-wins. The agent labels the issue
`status/claimed` and records who claimed it and when.

If no linked PR exists after 72h, the agent removes `status/claimed` and comments
that the issue is free again. This prevents three contributors from racing on
the same fix while keeping abandoned claims from blocking useful work.

## Duplicate PR Arbitration

When two open PRs reference the same issue or touch the same files, the agent
comments on BOTH PRs with links to the other work.

Default rule: prefer the earlier PR. Prefer the later PR only when it is
strictly more complete, meaning tests and docs are present and the earlier PR is
materially behind. Label the other PR `status/superseded` and ask its author to
review or co-author the preferred PR.

Never close either PR automatically.

## Scope Policy For Integrations

Provider, runtime, integration, and plugin PRs are `status/needs-policy` until
the maintainer publishes a policy.

Default policy text:

```md
Core integrations are maintained by the maintainer team and covered by CI.
Community integrations live in a `community/` or plugin namespace, carry the
`kind/community` label, and name the integration author as CODEOWNER for that
path. Community ownership means the maintainer can review project fit while the
path owner handles implementation details and breakage.
```

## SLAs

| Item | SLA |
|---|---|
| `status/needs-triage` | First pass within 48h. |
| `status/needs-info` | Auto-close after 14d of silence, with a comment and reopen path. |
| `kind/security` | Acknowledge within 24h and move details to private reporting. |

## First-Pass Review Checklist

The agent posts one sticky comment with this checklist:

| Check | Required Evidence |
|---|---|
| Scope matches title | PR title and diff describe the same change. |
| Links an issue | PR body references the issue it fixes, or explains why none is needed. |
| Verification section filled | Follow the repo's PR template when present. |
| Tests added or updated | New behavior has tests, or the comment explains why tests do not apply. |
| Docs updated | User-visible behavior has docs, examples, or release-note coverage. |
| No secrets or keys in diff | Diff contains no tokens, credentials, private endpoints, or generated secrets. |
| Workflow changes acknowledged | First-time contributors do not change CI/workflows without maintainer ack. |

## Weekly Digest

The human should read a digest, not every event. Use this Markdown table:

```md
| Area | Count / Links | Notes |
|---|---:|---|
| New issues |  |  |
| Closed issues |  |  |
| Merged PRs |  |  |
| Top-5 issues by reactions |  |  |
| PRs ready for maintainer |  |  |
| Stale claims |  |  |
| Security items |  |  |
```

## Receipts

Every triage run posts or updates one sticky comment, or one Discussion post for
batch work, listing what it labelled and why. The receipt should fit in one
scroll and let the maintainer audit the agent without reconstructing events from
notifications.

## Anti-Patterns

You have regressed if any of these appear:

- Labelling without deciding what state the issue or PR is in.
- Letting a stale bot close accepted issues.
- Giving an AI reviewer write, execute, or unrestricted shell permissions on
  fork PRs.
- Asking the maintainer per-PR questions that the policy already answers.
- Re-triaging on every push instead of reviewing at meaningful state changes.

## Kit

The mechanical layer is in `kit/github-governance/README.md`. It installs
labels, path labelling, size labelling, duplicate-fix detection, claim expiry,
stale handling, and gated comment-only AI workflows.
