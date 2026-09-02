#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
usage: bootstrap-gh.sh <owner/repo> [--dry-run] [--undo-labels] [--branch-protection]
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

quote_cmd() {
  printf '%q ' "$@"
  printf '\n'
}

owner_repo=""
dry_run=0
undo_labels=0
branch_protection=0

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

owner_repo="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --undo-labels)
      undo_labels=1
      shift
      ;;
    --branch-protection)
      branch_protection=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      die "unknown argument: $1"
      ;;
  esac
done

[[ "$owner_repo" == */* ]] || die "owner/repo must look like OWNER/REPO"
owner="${owner_repo%%/*}"
repo="${owner_repo#*/}"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
labels_file="$script_dir/repo/.github/labels.yml"
parser="$script_dir/lib/parse_labels.py"

[[ -f "$labels_file" ]] || die "missing labels file: $labels_file"
[[ -f "$parser" ]] || die "missing parser: $parser"

run_or_print() {
  if [[ "$dry_run" -eq 1 ]]; then
    quote_cmd "$@"
  else
    "$@"
  fi
}

if [[ "$dry_run" -eq 0 ]]; then
  require_cmd gh
  gh auth status >/dev/null
fi

if [[ "$undo_labels" -eq 1 ]]; then
  if [[ "$dry_run" -eq 1 ]]; then
    echo "dry-run: would list labels and delete only labels whose description starts with [gov] "
    echo "dry-run: gh label list --repo $(printf '%q' "$owner_repo") --json name,description --limit 1000"
  else
    labels_json="$(gh label list --repo "$owner_repo" --json name,description --limit 1000)"
    python3 - "$labels_json" <<'PY' | while IFS= read -r label; do
import json
import sys

for item in json.loads(sys.argv[1]):
    if item.get("description", "").startswith("[gov] "):
        print(item["name"])
PY
      gh label delete "$label" --repo "$owner_repo" --yes </dev/null
    done
  fi
  exit 0
fi

while IFS= read -r row; do
  [[ "$row" == count=* ]] && continue
  name="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["name"])' "$row")"
  color="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["color"])' "$row")"
  desc="$(python3 -c 'import json,sys; print(json.loads(sys.argv[1])["description"])' "$row")"
  run_or_print gh label create "$name" --repo "$owner_repo" --color "$color" --description "$desc" --force
done < <(python3 "$parser" "$labels_file")

run_or_print gh api -X PATCH "repos/$owner/$repo" -F has_discussions=true
run_or_print gh api -X PUT "repos/$owner/$repo/private-vulnerability-reporting"

if [[ "$branch_protection" -eq 1 ]]; then
  default_branch="${DEFAULT_BRANCH:-main}"
  checks="${REQUIRED_CHECKS:-}"
  json="$(python3 - "$checks" <<'PY'
import json
import sys

checks = [item.strip() for item in sys.argv[1].split(",") if item.strip()]
payload = {
    "required_pull_request_reviews": {
        "required_approving_review_count": 1,
        "dismiss_stale_reviews": True,
    },
    "enforce_admins": False,
    "restrictions": None,
    "allow_force_pushes": False,
    "allow_deletions": False,
}
if checks:
    payload["required_status_checks"] = {
        "strict": True,
        "contexts": checks,
    }
else:
    payload["required_status_checks"] = None
print(json.dumps(payload, indent=2, sort_keys=True))
PY
)"
  echo "$json"
  if [[ "$dry_run" -eq 1 ]]; then
    echo "gh api -X PUT repos/$owner/$repo/branches/$default_branch/protection --input -"
  else
    printf '%s\n' "$json" | gh api -X PUT "repos/$owner/$repo/branches/$default_branch/protection" --input -
  fi
fi
