#!/usr/bin/env python3
"""Parse the governance kit's strict labels.yml subset."""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


HEX_RE = re.compile(r"^[0-9A-Fa-f]{6}$")
KEY_RE = re.compile(r"^\s{2}(name|color|description):\s*(.*)$")


def parse_labels(path: str) -> list[dict[str, str]]:
    labels: list[dict[str, str]] = []
    current: dict[str, str] | None = None

    for lineno, raw in enumerate(Path(path).read_text(encoding="utf-8").splitlines(), 1):
        if not raw.strip() or raw.lstrip().startswith("#"):
            continue
        if raw == "-":
            if current is not None:
                labels.append(_validate(current, lineno - 1))
            current = {}
            continue
        match = KEY_RE.match(raw)
        if not match or current is None:
            raise SystemExit(f"{path}:{lineno}: unsupported labels.yml format")
        key, value = match.groups()
        current[key] = _unquote(value.strip())

    if current is not None:
        labels.append(_validate(current, len(Path(path).read_text(encoding="utf-8").splitlines())))
    if not labels:
        raise SystemExit(f"{path}: no labels found")
    return labels


def _unquote(value: str) -> str:
    if len(value) >= 2 and value[0] == value[-1] and value[0] in {"'", '"'}:
        return value[1:-1]
    return value


def _validate(label: dict[str, str], lineno: int) -> dict[str, str]:
    missing = {"name", "color", "description"} - label.keys()
    if missing:
        raise SystemExit(f"labels.yml:{lineno}: missing {', '.join(sorted(missing))}")
    if not HEX_RE.match(label["color"]):
        raise SystemExit(f"labels.yml:{lineno}: color must be 6-hex: {label['name']}")
    if not label["description"].startswith("[gov] "):
        raise SystemExit(f"labels.yml:{lineno}: description must start with [gov]: {label['name']}")
    return {key: label[key] for key in ("name", "color", "description")}


def main() -> int:
    if len(sys.argv) != 2:
        print("usage: parse_labels.py <labels.yml>", file=sys.stderr)
        return 2
    labels = parse_labels(sys.argv[1])
    for label in labels:
        print(json.dumps(label, sort_keys=True))
    print(f"count={len(labels)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
