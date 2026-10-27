#!/usr/bin/env bash
# Checks that a change may be archived as the last commit of its ship PR (AGENTS.md section 8.3, step 6):
# every task ticked, a Verified line in proposal.md, linked ADRs Accepted, bumped submodule pointers merged.
# Usage (from the repository root): bash .claude/skills/sdd-archive/scripts/check-archive.sh <change-id>
# Exit 0 = ready to archive (warnings may exist). Exit 1 = at least one error.
set -u

change="${1:-}"
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: check-archive.sh <change-id> (run from the repository root; '$dir' not found)" >&2
  exit 2
fi

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }

tasks="$dir/tasks.md"
proposal="$dir/proposal.md"

if [ ! -f "$tasks" ]; then
  err "tasks.md is missing"
else
  open=$(tr -d '\r' < "$tasks" | grep -E '^- \[ \] ' | grep -v '~~')
  if [ -n "$open" ]; then
    err "tasks.md has $(echo "$open" | wc -l | tr -d ' ') unchecked task(s); finish them with /sdd-implement:"
    echo "$open" | sed 's/^/    /'
  fi
fi

if [ ! -f "$proposal" ]; then
  err "proposal.md is missing"
elif [ -z "$(tr -d '\r' < "$proposal" | awk '/^## Validation log/ { v = 1; next } /^## / { v = 0 } v && /Verified [0-9]{4}-[0-9]{2}-[0-9]{2}/')" ]; then
  err "proposal.md has no 'Verified <date>' line under '## Validation log'; run /sdd-verify first"
fi

if [ -d openspec/adr ]; then
  adr_out=$(bash "$(dirname "$0")/../../sdd-adr/scripts/check-adr.sh" --change "$change" 2>&1)
  adr_code=$?
  while IFS= read -r line; do
    case "$line" in
      ERROR:*) err "check-adr: ${line#ERROR: }" ;;
      WARN:*) warn "check-adr: ${line#WARN:  }" ;;
    esac
  done <<< "$adr_out"
  [ "$adr_code" -le 1 ] || err "check-adr.sh could not run (exit $adr_code)"
fi

# Submodule pointers: a bump must point at a commit already merged into that submodule's origin/develop,
# and a side with ACs must be bumped by this branch.
sides=$(cat "$dir"/specs/*/spec.md 2>/dev/null | tr -d '\r' | sed -n 's/^\*\*Side:\*\* *//p')
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  warn "not a git work tree: submodule pointers not checked"
elif ! base=$(git merge-base HEAD origin/develop 2>/dev/null); then
  warn "no origin/develop: run 'git fetch' to check the submodule pointers"
else
  for sm in ERAS-BE ERAS-FE; do
    side=${sm#ERAS-}
    new=$(git ls-tree HEAD "$sm" 2>/dev/null | awk '$2 == "commit" { print $3 }')
    [ -n "$new" ] || continue
    old=$(git ls-tree "$base" "$sm" 2>/dev/null | awk '$2 == "commit" { print $3 }')
    if [ "$new" != "$old" ]; then
      if ! git -C "$sm" rev-parse --verify -q origin/develop > /dev/null; then
        warn "$sm: no origin/develop; run 'git -C $sm fetch' to check its pointer"
      elif ! git -C "$sm" merge-base --is-ancestor "$new" origin/develop 2> /dev/null; then
        err "$sm: the pointer ($new) is not on $sm origin/develop; merge the submodule PR and bump to the merged commit"
      fi
    elif echo "$sides" | grep -qw "$side"; then
      err "the spec has $side ACs but this branch does not bump the $sm pointer"
    fi
  done
fi

echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
