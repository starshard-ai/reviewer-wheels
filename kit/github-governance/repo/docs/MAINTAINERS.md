# Maintainer Governance Notes

This document explains the labels and workflows in the governance kit. It is a
starting policy, not a permanent constitution.

## Triage States

Issues begin as `status/needs-triage`, then move to `status/needs-info`,
`status/accepted`, `status/duplicate`, `status/wontfix`, or `kind/security`.

Pull requests begin as `status/needs-triage`, then move to `status/claimed`,
`status/needs-changes`, `status/ready-for-maintainer`, `status/superseded`, or
`status/needs-policy`.

Targets:

| Item | Target |
|---|---|
| First triage | Within 48 hours |
| Needs-info closure | 14 days after request if silent |
| Security acknowledgement | Within 24 hours |

## Claim Rule

Comment `/claim` on an issue to reserve it. The first claim wins. A claim
expires after 72 hours unless there is an open pull request referencing the
issue.

Claims prevent duplicate work; expiry prevents abandoned reservations.

## Duplicate Arbitration

When multiple open pull requests reference the same issue or touch the same
files, prefer the earlier pull request unless a later one is strictly more
complete with tests and docs. Label the other `status/superseded` and ask the
author to review or co-author the preferred pull request.

Do not close superseded pull requests automatically.

## Merge Policy

`status/ready-for-maintainer` means the pull request is ready for a human merge
or close decision. Before applying it, check:

- Scope matches title.
- Linked issue exists or the exception is explained.
- Verification section is filled.
- Tests are added or updated when applicable.
- Docs are updated for user-visible behavior.
- Diff contains no secrets, keys, or credential material.
- Workflow changes from first-time contributors have explicit maintainer ack.

## Integration And Provider Policy

Integration, provider, runtime, and plugin pull requests are
`status/needs-policy` until the maintainer chooses how that surface is owned.

Default policy:

Core integrations are maintained by the maintainer team and covered by CI.
Community integrations live in a `community/` or plugin namespace, carry the
`kind/community` label, and name the integration author as CODEOWNER for that
path.

## Release Cadence

When inbound is hot, consider a weekly tag. The goal is to ship accepted fixes
predictably while avoiding per-PR urgency.

## Weekly Digest

Use this digest shape:

| Area | Count / Links | Notes |
|---|---:|---|
| New issues |  |  |
| Closed issues |  |  |
| Merged pull requests |  |  |
| Top-5 issues by reactions |  |  |
| Pull requests ready for maintainer |  |  |
| Stale claims |  |  |
| Security items |  |  |

## Becoming A Triager

Grant the GitHub triage role first, not write access. A triager can label,
de-duplicate, request information, route security reports, and prepare digests.
They cannot merge, close without stated policy, edit CODEOWNERS, or change the
security policy.

## AI Layer

The optional AI workflows are comment-only helpers. They classify issues, search
for duplicates, post first-pass review checklists, and summarize discussion.
They do not approve, request changes, merge, close, or execute untrusted fork
code.
