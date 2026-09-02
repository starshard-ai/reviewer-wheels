# GitHub Governance Kit

This is a drop-in governance kit for repositories that suddenly have more
issues, pull requests, and duplicate fixes than one maintainer can route by
hand. It installs mechanical triage first and keeps optional AI review off until
you explicitly enable it.

## Apply In Three Steps

```sh
gh auth status
./apply.sh owner/repo --dry-run
./apply.sh owner/repo
./bootstrap-gh.sh owner/repo
```

Requirements: `git`, `gh` (logged in), `python3` (stdlib only, used to read
`labels.yml`).

`apply.sh` opens a kit pull request using your own GitHub credentials.
`bootstrap-gh.sh` creates labels, enables Discussions, and enables private
vulnerability reporting.

## Files

| File | What it does | Needs AI? | Permission or secret |
|---|---|---:|---|
| `repo/.github/labels.yml` | Label taxonomy for status, kind, priority, size, and area. | No | `bootstrap-gh.sh` uses your `gh` auth. |
| `repo/.github/labeler.yml` | Generic path-to-area labelling. | No | Pull request write permission in workflow. |
| `repo/.github/workflows/governance-triage.yml` | New issue labels, security redirect, PR size labels, duplicate-fix detection, `/claim`, claim expiry. | No | Issues and pull request permissions in workflow. |
| `repo/.github/workflows/governance-stale.yml` | Closes only `status/needs-info` issues/PRs after the silence window. | No | Issues and pull request permissions in workflow. |
| `repo/.github/workflows/claude-issue-triage.yml` | Optional issue classification, duplicate search, needs-info comments, security redirect. | Yes | `ANTHROPIC_API_KEY` or installed GitHub app plus repo variable. |
| `repo/.github/workflows/claude-pr-review.yml` | Optional comment-only first-pass PR checklist. | Yes | `ANTHROPIC_API_KEY` or installed GitHub app plus repo variable. |
| `repo/.github/workflows/claude-mention.yml` | Optional on-demand maintainer assistant when mentioned. | Yes | `ANTHROPIC_API_KEY` or installed GitHub app plus repo variable. |
| `repo/.github/CODEOWNERS.proposed` | Suggested team-based CODEOWNERS template; never overwrites CODEOWNERS. | No | Human review. |
| `repo/SECURITY.md` | Private vulnerability reporting policy; written as `SECURITY.md.proposed` if one already exists. | No | Human edit for security email. |
| `repo/docs/MAINTAINERS.md` | Human-readable policy behind the labels and workflows. | No | Human review. |
| `repo/.github/ISSUE_TEMPLATE/config.yml` | Disables blank issues and routes security/questions to the right place. | No | Human review. |

## Enable The AI Layer

First install credentials. From Claude Code, run:

```sh
/install-github-app
```

Direct API users can instead add a repository secret:

```sh
gh secret set ANTHROPIC_API_KEY --repo owner/repo
```

Then enable the workflows you want:

```sh
gh variable set CLAUDE_TRIAGE_ENABLED --body true --repo owner/repo
gh variable set CLAUDE_REVIEW_ENABLED --body true --repo owner/repo
gh variable set CLAUDE_MENTION_ENABLED --body true --repo owner/repo
```

Until these variables are set, the AI workflows are no-ops.

Cost and noise are bounded by design: the PR review runs once per PR (on
`opened` / `ready_for_review`, not on every push), the issue triage runs once per
new issue, and `@claude` mentions are only honoured from accounts with write
access, so drive-by commenters cannot spend your API budget.

## Fork PR Security

Fork pull requests are common when a repo goes viral. The AI PR review workflow
uses `pull_request_target` so it can comment on fork PRs, but it checks out only
the base branch and never the contributor's head ref. Its tools are restricted
to read, diff, and comment operations. This follows the upstream security model:
`https://github.com/anthropics/claude-code-action/blob/main/docs/security.md`.

The trade-off is deliberate: the reviewer can inspect PR metadata and diffs, but
must not execute untrusted fork code or receive write tools.

## Customise

Edit `repo/.github/labels.yml` if you want different labels, colors, or
descriptions. Keep the `[gov] ` description prefix if you want
`bootstrap-gh.sh --undo-labels` to remove only labels created by this kit.

Edit `repo/.github/labeler.yml` to match your repository tree. During apply, you
can pass a replacement file:

```sh
./apply.sh owner/repo --labeler ./my-labeler.yml
```

`CODEOWNERS` is delivered as `.github/CODEOWNERS.proposed` and never overwrites
an existing CODEOWNERS file. Replace placeholder teams like `@ORG/core-maintainers`
before using it.

## Rollback

Revert the single governance-kit pull request.

For labels created by the bootstrap step, run:

```sh
./bootstrap-gh.sh owner/repo --undo-labels
```

The undo mode deletes only labels whose description starts with `[gov] `.
