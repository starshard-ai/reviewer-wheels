#!/usr/bin/env python3
"""delegation-bound-gate — PreToolUse advisory on subagent (`Agent`) launches.

THE FAILURE THIS EXISTS FOR
---------------------------
A research subagent was launched with no deadline, no tool-call cap, and no
partial-report contract. It hung inside a web fetch and never returned. The
parent burned ~2 hours: first blocking on it, then declaring it "dead" from file
mtime alone, then launching a SECOND agent on the same topic to hedge.

Every part of that was avoidable, and none of it was exotic:

1. The network was FINE. Measured after the fact: the same URL returned HTTP 200
   in 3-5s, and there were ZERO open sockets to that host. The tool call was hung
   in the harness, not waiting on the wire. A hung tool call has no timeout and
   will not self-recover.
2. `SendMessage` cannot rescue a hung worker. It is delivered at the worker's
   next tool round — which, for a hung worker, never arrives.
3. The stalled sub-deliverable was NOT on the critical path. Blocking on it
   gated the entire task for nothing.
4. The "it's dead" verdict was GUESSED from file mtime, not measured.

Root cause was not the network and not task difficulty. It was an unbounded
delegation with no partial-result contract, plus a parent that waited instead of
timeboxing.

WHY A HOOK AND NOT A WRITTEN RULE
---------------------------------
"Verify a blocker before declaring it" was already written in the operator's
always-loaded instructions, flagged as a third recurrence. It was violated again
anyway — a fourth time. Prose in context is not a control. A rule that has been
broken repeatedly needs an intervention at the moment of the mistake, not
another paragraph. That is the whole thesis of this wheel.

CONTRACT (deliberately weak by design)
--------------------------------------
- ADVISORY ONLY. Never blocks, never sets permissionDecision. Always exit 0.
- Fail-OPEN on every error. A broken gate must never stop you delegating.
- Writes at most a few lines, addressed to the AGENT, never to the user.

stdin : JSON {session_id, tool_name, tool_input, ...}
state : ~/.claude/delegation-bound-gate/recent.json
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import time
from pathlib import Path

STATE_DIR = Path.home() / ".claude" / "delegation-bound-gate"
STATE_FILE = STATE_DIR / "recent.json"
DUP_WINDOW_S = 45 * 60      # same topic re-launched this soon == probably a hedge
STATE_KEEP_S = 6 * 60 * 60

# A bound is a HARD stop condition the worker can evaluate on its own.
_BOUND_CUES = re.compile(
    r"(cap\s+yourself|bounded|time-?box|deadline|"
    r"at\s+most|no\s+more\s+than|do\s+not\s+exceed|don'?t\s+exceed|"
    r"max(?:imum)?\s+of\s+\d|"
    r"\b\d+\s*(?:min|mins|minutes)\b|"
    r"~?\s*\d+\s*(?:searches|search\s+calls|lookups|queries|tool\s+calls))",
    re.I,
)
# A partial-report contract: the worker must return SOMETHING rather than stall.
_PARTIAL_CUES = re.compile(
    r"(partial[\s-]*(?:result|report|findings|is\s+fine|ok)|"
    r"report\s+what\s+you\s+have|deliver\s+what\s+you\s+have|"
    r"incomplete[^.]{0,30}(?:fine|better|beats|ok)|"
    r"even\s+if\s+(?:you'?re\s+)?not\s+done)",
    re.I,
)


def _norm_topic(desc: str, prompt: str) -> str:
    """Cheap topic fingerprint for duplicate-launch detection."""
    base = (desc or "")[:80] + "||" + (prompt or "")[:400]
    return hashlib.sha256(
        re.sub(r"\s+", " ", base.lower()).strip().encode("utf-8", "replace")
    ).hexdigest()[:16]


def _load_state() -> dict:
    try:
        return json.loads(STATE_FILE.read_text())
    except Exception:
        return {}


def _save_state(state: dict) -> None:
    try:
        STATE_DIR.mkdir(parents=True, exist_ok=True)
        tmp = STATE_FILE.with_suffix(".tmp")
        tmp.write_text(json.dumps(state))
        tmp.replace(STATE_FILE)
    except Exception:
        pass


def main() -> int:
    try:
        raw = sys.stdin.read()
        hook = json.loads(raw) if raw.strip() else {}
    except Exception:
        return 0

    if (hook.get("tool_name") or "") != "Agent":
        return 0

    ti = hook.get("tool_input") or {}
    prompt = str(ti.get("prompt") or "")
    desc = str(ti.get("description") or "")
    blob = desc + "\n" + prompt

    has_bound = bool(_BOUND_CUES.search(blob))
    has_partial = bool(_PARTIAL_CUES.search(blob))

    warns: list[str] = []
    if not has_bound and not has_partial:
        warns.append(
            "UNBOUNDED delegation: no time/tool-call cap AND no partial-report "
            'contract. Add both, e.g. "cap yourself at ~N tool calls / M '
            'minutes" + "partial-but-honest beats stalled — report what you have".'
        )
    elif not has_bound:
        warns.append(
            "No hard cap: the worker may return partial results but has no stop "
            "condition. Add a tool-call or minute cap."
        )
    elif not has_partial:
        warns.append(
            "No partial-report contract: the worker is capped but can still "
            'return nothing if it stalls. Add "report what you have; partial is fine".'
        )

    now = int(time.time())
    topic = _norm_topic(desc, prompt)
    state = {
        k: v for k, v in _load_state().items()
        if isinstance(v, int) and now - v < STATE_KEEP_S
    }
    prev = state.get(topic)
    if isinstance(prev, int) and now - prev < DUP_WINDOW_S:
        warns.append(
            f"DUPLICATE topic re-launched {(now - prev) // 60}min after the last "
            "one. Hedging a stalled agent with a second agent doubles the failure "
            "surface — prefer doing the work inline, or stop the first."
        )
    state[topic] = now
    _save_state(state)

    if not warns:
        return 0

    msg = (
        "delegation-bound-gate (advisory, not blocking)\n- "
        + "\n- ".join(warns)
        + "\n\nBefore you wait on this worker:"
        "\n- Is it too small to delegate? A task of ~10 lookups is usually "
        "faster inline than delegated."
        "\n- Do NOT block on it. Timebox, then continue on the critical path. A "
        "non-critical sub-deliverable must never gate the whole task."
        "\n- A stall verdict must be MEASURED, not guessed from file mtime: check "
        "open sockets (`lsof -nP -iTCP | grep <host>`) and probe the URL with a "
        "bounded `curl -m 15`. A hung tool call shows ZERO open sockets."
        "\n- SendMessage cannot rescue a hung worker: it is delivered at the "
        "worker's next tool round, which never comes."
    )
    try:
        sys.stdout.write(json.dumps({"systemMessage": msg}))
    except Exception:
        pass
    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception:
        sys.exit(0)  # fail-OPEN, always
