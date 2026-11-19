#!/usr/bin/env bash
# Checks the implementation state of one change: tasks checked off and exactly one tagged test per AC per side.
# The sides, their test folders and how a test carries the AC key come from openspec/sides.conf (ADR-0011).
# It does not run the tests; run them yourself and report the real output.
# Usage (from the repository root): bash .claude/skills/sdd-implement/scripts/check-impl.sh <change-id> [--final]
#   default : unchecked tasks and missing tests are warnings (work in progress)
#   --final : they are errors (use before reporting the change as done)
# Exit 0 = no errors. Exit 1 = at least one error.
set -u

. "$(dirname "$0")/../../sdd-shared/sides.sh"

change="${1:-}"
final=0
[ "${2:-}" = "--final" ] && final=1
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: check-impl.sh <change-id> [--final] (run from the repository root; '$dir' not found)" >&2
  exit 2
fi
if ! sides_ok; then
  echo "check-impl.sh: $SIDES_CONF not found (run from the repository root)" >&2
  exit 2
fi

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }
pending() { if [ "$final" -eq 1 ]; then err "$*"; else warn "$*"; fi; }

tasks="$dir/tasks.md"
if [ ! -f "$tasks" ]; then
  err "tasks.md is missing"
else
  open=$(tr -d '\r' < "$tasks" | grep -cE '^- \[ \] [0-9]+\.[0-9]+ ' || true)
  done_count=$(tr -d '\r' < "$tasks" | grep -cE '^- \[[xX]\] [0-9]+\.[0-9]+ ' || true)
  [ "$open" -gt 0 ] && pending "$open task(s) still unchecked ($done_count done)"
fi

expected=$(sides_of_specs $(find "$dir/specs" -name spec.md 2>/dev/null | sort) | sed '/^$/d' | sort -u)
sides=$(sides_list)

for e in $expected; do
  ac="${e%|*}"; side="${e#*|}"
  if ! sides_has "$side"; then
    err "$change/$ac names side '$side', which is not in $SIDES_CONF"
    continue
  fi
  n=$(sides_count "$side" "$change/$ac")
  if [ "$n" -eq 0 ]; then
    pending "$change/$ac on $side has no tagged test"
  elif [ "$n" -gt 1 ]; then
    err "$change/$ac on $side has $n tagged tests (exactly 1 allowed)"
  fi
done

for side in $sides; do
  for ac in $(sides_tags "$side" "$change"); do
    echo "$expected" | grep -qxF "$ac|$side" || err "$(sides_article "$side") $side test is tagged $change/$ac but the spec does not declare it for $side"
  done
done

skipped=$(for side in $sides; do
  re=$(sides_get "$side" skip)
  [ -n "$re" ] || continue
  label=$(sides_skip_label "$side")
  for f in $(sides_tagged_files "$side" "$change"); do
    grep -nE "$re" "$f" | head -2 | sed "s|^|ERROR: $label in $f: |"
  done
done)
if [ -n "$skipped" ]; then
  echo "$skipped"
  errors=$((errors + $(echo "$skipped" | grep -c '^ERROR')))
fi

echo "ACs x sides: $(echo "$expected" | sed '/^$/d' | wc -l | tr -d ' ')  tasks done: ${done_count:-0}  open: ${open:-0}"
echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
