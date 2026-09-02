#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
usage: apply.sh <owner/repo> [--checkout DIR] [--branch NAME] [--labeler FILE] [--dry-run] [--no-pr]
USAGE
}

die() {
  echo "error: $*" >&2
  exit 1
}

require_cmd() {
  command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

quote() {
  printf '%q' "$1"
}

owner_repo=""
checkout=""
branch="governance-kit"
labeler=""
dry_run=0
no_pr=0

if [[ $# -lt 1 ]]; then
  usage
  exit 2
fi

owner_repo="$1"
shift

while [[ $# -gt 0 ]]; do
  case "$1" in
    --checkout)
      [[ $# -ge 2 ]] || die "--checkout requires a directory"
      checkout="$2"
      shift 2
      ;;
    --branch)
      [[ $# -ge 2 ]] || die "--branch requires a name"
      branch="$2"
      shift 2
      ;;
    --labeler)
      [[ $# -ge 2 ]] || die "--labeler requires a file"
      labeler="$2"
      shift 2
      ;;
    --dry-run)
      dry_run=1
      shift
      ;;
    --no-pr)
      no_pr=1
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

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_src="$script_dir/repo"
owner="${owner_repo%%/*}"
repo="${owner_repo#*/}"

require_cmd git
[[ -d "$repo_src" ]] || die "missing kit repo source: $repo_src"
if [[ -n "$labeler" && ! -f "$labeler" ]]; then
  die "labeler file not found: $labeler"
fi

print_plan() {
  local target="${checkout:-<temporary clone>}"
  echo "dry-run: target repository: $owner_repo"
  if [[ -n "$checkout" ]]; then
    echo "dry-run: checkout: $checkout"
  else
    echo "dry-run: would run: gh repo clone $(quote "$owner_repo") <temp-dir>"
  fi
  echo "dry-run: would refuse if branch exists locally or on origin: $branch"
  echo "dry-run: would create branch: $branch"
  while IFS= read -r -d '' src; do
    rel="${src#"$repo_src"/}"
    case "$rel" in
      SECURITY.md)
        if [[ -n "$checkout" && -e "$checkout/SECURITY.md" ]]; then
          echo "dry-run: would write SECURITY.md.proposed from repo/SECURITY.md"
        else
          echo "dry-run: would write SECURITY.md from repo/SECURITY.md"
        fi
        ;;
      .github/labeler.yml)
        if [[ -n "$labeler" ]]; then
          echo "dry-run: would write .github/labeler.yml from $(quote "$labeler")"
        else
          echo "dry-run: would write .github/labeler.yml from repo/.github/labeler.yml"
        fi
        ;;
      *)
        echo "dry-run: would write $rel from repo/$rel"
        ;;
    esac
  done < <(find "$repo_src" -type f -print0 | sort -z)
  echo "dry-run: would substitute OWNER/REPO in SECURITY.md or SECURITY.md.proposed and .github/ISSUE_TEMPLATE/config.yml"
  echo "dry-run: would commit: chore(governance): add triage labels, labeler, stale, claim rules, optional AI triage"
  echo "dry-run: would push: git push -u origin $(quote "$branch")"
  if [[ "$no_pr" -eq 0 ]]; then
    echo "dry-run: would create PR with body: $script_dir/PR_BODY.md"
  else
    echo "dry-run: --no-pr set; would stop after push"
  fi
}

if [[ "$dry_run" -eq 1 ]]; then
  print_plan
  exit 0
fi

if [[ -z "$checkout" || "$no_pr" -eq 0 ]]; then
  require_cmd gh
  gh auth status >/dev/null
fi

tmpdir=""
if [[ -z "$checkout" ]]; then
  tmpdir="$(mktemp -d)"
  checkout="$tmpdir/${repo}"
  gh repo clone "$owner_repo" "$checkout"
fi

[[ -d "$checkout/.git" ]] || die "checkout is not a git repository: $checkout"
cd "$checkout"

if git show-ref --verify --quiet "refs/heads/$branch"; then
  die "local branch already exists: $branch"
fi
if git ls-remote --exit-code --heads origin "$branch" >/dev/null 2>&1; then
  die "origin branch already exists: $branch"
fi

git switch -c "$branch"

changed_files=()

install_file() {
  local src="$1"
  local dest="$2"
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  changed_files+=("$dest")
}

while IFS= read -r -d '' src; do
  rel="${src#"$repo_src"/}"
  case "$rel" in
    SECURITY.md)
      if [[ -e SECURITY.md ]]; then
        install_file "$src" SECURITY.md.proposed
      else
        install_file "$src" SECURITY.md
      fi
      ;;
    .github/labeler.yml)
      if [[ -n "$labeler" ]]; then
        install_file "$labeler" .github/labeler.yml
      else
        install_file "$src" .github/labeler.yml
      fi
      ;;
    *)
      install_file "$src" "$rel"
      ;;
  esac
done < <(find "$repo_src" -type f -print0 | sort -z)

if [[ -f SECURITY.md ]]; then
  sed -i.bak "s#OWNER/REPO#$owner_repo#g" SECURITY.md
  rm -f SECURITY.md.bak
fi
if [[ -f SECURITY.md.proposed ]]; then
  sed -i.bak "s#OWNER/REPO#$owner_repo#g" SECURITY.md.proposed
  rm -f SECURITY.md.proposed.bak
fi
if [[ -f .github/ISSUE_TEMPLATE/config.yml ]]; then
  sed -i.bak "s#OWNER/REPO#$owner_repo#g" .github/ISSUE_TEMPLATE/config.yml
  rm -f .github/ISSUE_TEMPLATE/config.yml.bak
fi

for path in "${changed_files[@]}"; do
  git add "$path"
done

commit_body="Files added by the governance kit:
$(printf -- '- %s\n' "${changed_files[@]}")"

git -c user.name=governance-kit -c user.email=governance-kit@example.invalid \
  commit \
  -m "chore(governance): add triage labels, labeler, stale, claim rules, optional AI triage" \
  -m "$commit_body"

git push -u origin "$branch"

if [[ "$no_pr" -eq 1 ]]; then
  echo "pushed branch: $branch"
  exit 0
fi

body_file="$(mktemp)"
sed "s#OWNER/REPO#$owner_repo#g" "$script_dir/PR_BODY.md" > "$body_file"
pr_url="$(gh pr create --fill-first --body-file "$body_file")"
rm -f "$body_file"
echo "PR URL: $pr_url"

if [[ -n "$tmpdir" ]]; then
  echo "checkout left at: $checkout"
fi
