---
name: delegation-bound-gate
description: Use when launching a subagent / background worker, or when one has gone quiet. Enforces a hard cap plus a partial-report contract at launch, and gives the measured procedure for deciding whether a silent worker is hung — instead of guessing from file mtime, blocking on it, or hedging with a second agent.
---

# Delegation Bound Gate

## Purpose

Stop the quietest and most expensive multi-agent failure: a subagent that hangs,
a parent that waits, and hours that vanish with no error anywhere.

Nothing crashes. No exception is raised. The worker's transcript simply stops
growing, and the parent — with no signal to act on — waits, then guesses, then
often launches a second worker to hedge. The task was never hard; the delegation
was never bounded.

## The incident this is distilled from

A research subagent was launched to survey a topic — roughly ten lookups of
work. It was given no deadline, no tool-call cap, and no instruction about what
to do if it got stuck. It hung inside a web fetch and never came back. About two
hours were lost.

Measured afterwards, the diagnosis was not what it looked like:

| Check | Result |
|---|---|
| Fetch the same URL directly | HTTP 200 in ~5s |
| Fetch it through the same proxy the agent used | HTTP 200 in ~3s |
| Open TCP connections to that host | **zero** |

**The network was healthy and there was no connection open at all.** The tool
call was hung inside the harness, not waiting on the wire. It had no timeout and
would never have recovered.

Four independent failures had to line up, and each one is separately fixable:

1. **Unbounded delegation.** No stop condition, and no "if you get stuck, return
   what you have" contract. A worker with neither can only succeed or hang.
2. **The rescue path did not exist.** Sending the worker a message does not help:
   messages are delivered at the worker's *next tool round*, and a hung worker
   never has one. There is no in-band way to interrupt it.
3. **The parent blocked on a non-critical path.** The stalled sub-deliverable was
   not required by the final output. Waiting on it gated everything for nothing.
4. **The stall verdict was guessed.** "It's dead" was inferred from an unchanged
   file mtime — no socket check, no probe. The cheap measurement that would have
   revealed the true state took under a minute and was never run.

## Why this ships as a hook, not as advice

The rule "verify a blocker before you declare it" was already written in the
operator's always-loaded instructions, and already annotated as a *third*
recurrence. It was violated again anyway — a fourth time — by an agent that had
that text in its context the entire time.

That is the finding worth generalizing: **prose in context is not a control.**
Guidance an agent has already read and already broken does not get fixed by
adding another paragraph. It needs an intervention at the moment of the mistake.
So the durable artifact here is a hook that fires when a subagent is launched,
and the prose exists to explain it — not the other way round.

## The rules

**At launch — every delegation carries two things:**

- **A hard cap** the worker can evaluate itself: a tool-call budget, a minute
  budget, or both. "Be efficient" is not a cap.
- **A partial-report contract**: *"partial-but-honest beats stalled — report what
  you have."* This converts the hang failure mode into a degraded-answer failure
  mode, which is recoverable.

**Before delegating at all** — ask whether the task is too small to delegate. A
task of roughly ten lookups is usually faster done inline than shipped to a
worker, and it carries none of this risk.

**While waiting — never block.** Timebox, then continue on the critical path.
Ask explicitly: *does the final deliverable actually depend on this?* If not, it
must not gate anything. Note in your output that the sub-deliverable is
outstanding and move on.

**When a worker goes quiet — measure, do not guess.** An unchanged mtime is not
evidence of anything. The measurement is cheap:

```sh
# 1. Is there an open connection to the host it claimed to be fetching?
lsof -nP -iTCP | grep -i <host>          # a hung tool call shows ZERO

# 2. Is the target actually reachable, on a bounded timer?
curl -sS -o /dev/null -m 15 -w 'http=%{http_code} total=%{time_total}s\n' <url>

# 3. Only now form a verdict.
```

If the host is reachable and there are no sockets, the worker is hung in the
harness — it will not recover, and no message will reach it. Abandon it and
proceed; do not wait, and do not launch a replacement on the same topic while
the first is still nominally alive.

**Never hedge a stalled worker with a second worker on the same topic.** It
doubles the failure surface, competes for the same rate limits and quotas, and
does not make the first one finish. Either do the work inline or stop the first.

## The hook

`hook/delegation-bound-gate.py` implements the launch-time half. It is
**advisory only** — it never blocks a delegation, and it fails **open** on any
error, because a broken gate that prevents you from delegating is worse than the
problem it solves.

It fires on `Agent` tool calls and warns when:

- the prompt has **no hard cap** (no time / tool-call budget),
- the prompt has **no partial-report contract**,
- the same topic was **re-launched within 45 minutes** — the hedging signature.

Every warning also carries the wait-time rules above, because the launch moment
is the last point at which they are cheap to apply.

### Install

The hook is opt-in — installing this plugin does not activate it. Copy it
somewhere on your machine, make it executable, and register it as a
`PreToolUse` hook matching `Agent` in `~/.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Agent",
        "hooks": [
          {
            "type": "command",
            "command": "/absolute/path/to/delegation-bound-gate.py",
            "timeout": 5,
            "statusMessage": "Delegation-bound gate"
          }
        ]
      }
    ]
  }
}
```

Verify it before trusting it:

```sh
# non-Agent tool -> silent
echo '{"tool_name":"Bash","tool_input":{}}' | ./delegation-bound-gate.py

# unbounded delegation -> warns
echo '{"tool_name":"Agent","tool_input":{"description":"research","prompt":"Research X thoroughly."}}' \
  | ./delegation-bound-gate.py

# bounded + partial contract -> silent
echo '{"tool_name":"Agent","tool_input":{"description":"x","prompt":"Cap yourself at ~12 searches and 8 minutes. Partial is fine — report what you have."}}' \
  | ./delegation-bound-gate.py

# malformed input -> must exit 0 and print nothing
echo 'not json' | ./delegation-bound-gate.py; echo "exit=$?"
```

## Anti-signals

You have regressed if any of these appear:

- A subagent is launched with neither a cap nor a partial-report contract and
  nothing says so.
- A second worker is launched on a topic where the first is still unfinished.
- A worker is declared dead or alive on the strength of file size or mtime, with
  no socket check and no probe.
- A parent blocks for more than ~15 minutes on a sub-deliverable that the final
  output does not depend on.
