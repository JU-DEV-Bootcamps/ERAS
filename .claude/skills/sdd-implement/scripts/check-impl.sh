#!/usr/bin/env bash
# Checks the implementation state of one change: tasks checked off and exactly one tagged test per AC per side.
# It does not run the tests; run them yourself and report the real output.
# Usage (from the repository root): bash .claude/skills/sdd-implement/scripts/check-impl.sh <change-id> [--final]
#   default : unchecked tasks and missing tests are warnings (work in progress)
#   --final : they are errors (use before reporting the change as done)
# Exit 0 = no errors. Exit 1 = at least one error.
set -u

change="${1:-}"
final=0
[ "${2:-}" = "--final" ] && final=1
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: check-impl.sh <change-id> [--final] (run from the repository root; '$dir' not found)" >&2
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

expected=""
for f in $(find "$dir/specs" -name spec.md 2>/dev/null | sort); do
  expected="$expected
$(tr -d '\r' < "$f" | awk '
    /^#### Scenario: AC-[0-9]+ / { key = $3 }
    /^\*\*Side:\*\* / {
      side = $0; sub(/^\*\*Side:\*\* /, "", side)
      if (side ~ /BE/) print key "|BE"
      if (side ~ /FE/) print key "|FE"
    }')"
done
expected=$(echo "$expected" | sed '/^$/d' | sort -u)

count_be() { grep -rF "[Trait(\"AC\", \"$change/$1\")]" ERAS-BE/test --include=*.cs 2>/dev/null | wc -l | tr -d ' '; }
count_fe() { grep -rF "[$change/$1]" ERAS-FE/src/app --include=*.spec.ts 2>/dev/null | grep -cF "it(" || true; }

for e in $expected; do
  ac="${e%|*}"; side="${e#*|}"
  if [ "$side" = "BE" ]; then n=$(count_be "$ac"); else n=$(count_fe "$ac"); fi
  if [ "$n" -eq 0 ]; then
    pending "$change/$ac on $side has no tagged test"
  elif [ "$n" -gt 1 ]; then
    err "$change/$ac on $side has $n tagged tests (exactly 1 allowed)"
  fi
done

be_tags=$(grep -rhoE "Trait\(\"AC\", \"$change/AC-[0-9]+\"\)" ERAS-BE/test --include=*.cs 2>/dev/null | sort -u | sed -E 's/.*\/(AC-[0-9]+)".*/\1/' || true)
for ac in $be_tags; do
  echo "$expected" | grep -qxF "$ac|BE" || err "a BE test is tagged $change/$ac but the spec does not declare it for BE"
done
fe_tags=$(grep -rhoE "it\(['\"\`]\[$change/AC-[0-9]+\]" ERAS-FE/src/app --include=*.spec.ts 2>/dev/null | sort -u | sed -E 's/.*\/(AC-[0-9]+)\]$/\1/' || true)
for ac in $fe_tags; do
  echo "$expected" | grep -qxF "$ac|FE" || err "an FE test is tagged $change/$ac but the spec does not declare it for FE"
done

tagged_files=$( { grep -rlF "$change/AC-" ERAS-BE/test --include=*.cs; grep -rlF "[$change/AC-" ERAS-FE/src/app --include=*.spec.ts; } 2>/dev/null || true)
skipped=$(for f in $tagged_files; do
  case "$f" in
    *.spec.ts) grep -nE '(^|[^A-Za-z_])(fit|xit|fdescribe|xdescribe)\(' "$f" | head -2 | sed "s|^|ERROR: focused or skipped test in $f: |" ;;
    *.cs) grep -nE '\[(Fact|Theory)\(Skip' "$f" | head -2 | sed "s|^|ERROR: skipped test in $f: |" ;;
  esac
done)
if [ -n "$skipped" ]; then
  echo "$skipped"
  errors=$((errors + $(echo "$skipped" | grep -c '^ERROR')))
fi

echo "ACs x sides: $(echo "$expected" | sed '/^$/d' | wc -l | tr -d ' ')  tasks done: ${done_count:-0}  open: ${open:-0}"
echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
