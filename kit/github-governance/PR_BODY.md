## What This Adds

This pull request adds a small governance kit for high-inbound maintenance:

- A label taxonomy for issue, pull request, priority, size, and area state.
- Path labelling and pull request size labelling.
- Duplicate-fix detection for pull requests referencing the same issue.
- `/claim` handling with 72-hour expiry when no linked pull request appears.
- Stale handling only for `status/needs-info`.
- A proposed CODEOWNERS template, maintainer policy notes, and security policy.
- Optional AI triage and review workflows that are off until enabled by repo variables.

## Immediate Behavior After Merge

The non-AI workflows can label new issues and pull requests, detect duplicate
pull request candidates, handle `/claim`, expire stale claims, and close
`status/needs-info` threads after the configured silence window.

## Off Until Explicitly Enabled

The AI workflows do nothing until repository variables are set:

```sh
gh variable set CLAUDE_TRIAGE_ENABLED --body true --repo OWNER/REPO
gh variable set CLAUDE_REVIEW_ENABLED --body true --repo OWNER/REPO
gh variable set CLAUDE_MENTION_ENABLED --body true --repo OWNER/REPO
```

Use `/install-github-app` from Claude Code or add `ANTHROPIC_API_KEY` as a repo
secret before enabling the AI layer.

## Checklist

- [ ] Replace placeholder CODEOWNERS teams in `.github/CODEOWNERS.proposed`.
- [ ] Edit `SECURITY.md` and replace SECURITY_CONTACT_EMAIL.
- [ ] Review `.github/labeler.yml` paths for this repository.
- [ ] Decide whether to enable private vulnerability reporting and Discussions with `bootstrap-gh.sh`.
- [ ] Decide whether to enable the optional AI workflows.

## Rollback

Revert this single pull request. To remove labels created by the bootstrap step,
run:

```sh
kit/github-governance/bootstrap-gh.sh OWNER/REPO --undo-labels
```
