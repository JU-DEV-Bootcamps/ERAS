#!/usr/bin/env bash
# Checks design.md and tasks.md of one change against the project rules that `openspec validate` does not enforce.
# Usage (from the repository root): bash .claude/skills/sdd-plan/scripts/check-plan.sh <change-id>
# Exit 0 = no errors (warnings may exist). Exit 1 = at least one error.
set -u

change="${1:-}"
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: check-plan.sh <change-id> (run from the repository root; '$dir' not found)" >&2
  exit 2
fi

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }

design="$dir/design.md"
tasks="$dir/tasks.md"
proposal="$dir/proposal.md"
skip_specs=0
grep -q '^skip_specs: *true' "$dir/.openspec.yaml" 2>/dev/null && skip_specs=1

[ -f "$design" ] || [ "$skip_specs" -eq 1 ] || err "design.md is missing"
[ -f "$tasks" ] || err "tasks.md is missing"
if { [ ! -f "$design" ] && [ "$skip_specs" -eq 0 ]; } || [ ! -f "$tasks" ]; then
  echo "Result: $errors error(s), $warnings warning(s)"
  exit 1
fi

if [ -f "$proposal" ] && ! tr -d '\r' < "$proposal" | grep -qE '^\*\*Plan:\*\* (Draft|Approved)$'; then
  warn "proposal.md has no '**Plan:** Draft|Approved' line"
fi

if [ -f "$design" ]; then
  for h in 'Decisions' 'Changes by layer' 'Test strategy'; do
    tr -d '\r' < "$design" | grep -q "^## $h" || err "design.md has no '## $h' section"
  done
  last_design=$(tr -d '\r' < "$design" | grep '^## ' | tail -1)
  [ "$last_design" = "## Follow-ups" ] || err "design.md must end with '## Follow-ups' (last section is '$last_design')"
fi

expected=""
if [ "$skip_specs" -eq 0 ]; then
  specs=$(find "$dir/specs" -name spec.md 2>/dev/null | sort)
  [ -z "$specs" ] && err "no spec.md under $dir/specs (set skip_specs: true if the change has no spec)"
  for f in $specs; do
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
fi

rows=$(tr -d '\r' < "$tasks" | awk '
  /^## / { in_trace = ($0 ~ /^## Traceability/) }
  in_trace && /^\| AC-[0-9]+ / {
    n = split($0, c, "|")
    ac = c[2]; side = c[4]
    gsub(/^ +| +$/, "", ac); gsub(/^ +| +$/, "", side)
    print ac "|" side
  }' | sort)

if [ "$skip_specs" -eq 0 ]; then
  tr -d '\r' < "$tasks" | grep -q '^## Traceability' || err "tasks.md has no '## Traceability' section"
  last_tasks=$(tr -d '\r' < "$tasks" | grep '^## ' | tail -1)
  [ "$last_tasks" = "## Traceability" ] || err "tasks.md must end with '## Traceability' (last section is '$last_tasks')"
  dup_rows=$(echo "$rows" | uniq -d)
  [ -n "$dup_rows" ] && err "duplicate Traceability rows: $(echo $dup_rows)"
  for e in $expected; do
    echo "$rows" | grep -qxF "$e" || err "Traceability has no row for ${e%|*} on side ${e#*|}"
  done
  for r in $(echo "$rows" | sort -u); do
    echo "$expected" | grep -qxF "$r" || err "Traceability row ${r%|*} / ${r#*|} is not declared by a **Side:** line in the specs"
  done
fi

bad=$(tr -d '\r' < "$tasks" | grep -nE '^- \[' | grep -vE '^[0-9]+:- \[[ xX]\] [0-9]+\.[0-9]+ ' || true)
[ -n "$bad" ] && err "malformed task line(s), expected '- [ ] <group>.<n> <description>': $(echo "$bad" | head -3 | tr '\n' ' ')"
untracked=$(tr -d '\r' < "$tasks" | grep -nE '^\s*[-*] [0-9]+\.[0-9]+ ' || true)
[ -n "$untracked" ] && err "task line without a checkbox is not tracked: $(echo "$untracked" | head -3 | tr '\n' ' ')"

groups=$(tr -d '\r' < "$tasks" | grep -E '^## [0-9]+\.' || true)
[ -z "$groups" ] && err "tasks.md has no numbered task group"
echo "$groups" | grep -qE 'BE|FE|Infra' || warn "no task group is named by side (BE, FE or Infra)"
last_group=$(echo "$groups" | tail -1)
echo "$last_group" | grep -qi 'verif' || err "the last task group must be the verification group (it is '$last_group')"
verif_text=$(tr -d '\r' < "$tasks" | awk '/^## [0-9]+\./ { g = $0 } g ~ /[Vv]erif/ { print }')
if ! echo "$verif_text" | grep -q '8\.7'; then
  if [ "$skip_specs" -eq 1 ]; then
    warn "the verification group does not cite the AGENTS.md section 8.7 gates (fine when no BE/FE code changes)"
  else
    err "the verification group must run the AGENTS.md section 8.7 gates (cite 8.7)"
  fi
fi

tr -d '\r' < "$tasks" | grep -E '^- \[[ xX]\] ' | grep -viE 'verif|pass|fail|builds|shows|exist' | head -3 | while read -r line; do
  echo "WARN:  task does not say how to verify it: ${line:0:90}"
done

order=$(tr -d '\r' < "$tasks" | awk '
  /^## [0-9]+\./ { group = $2; verification = ($0 ~ /[Vv]erif/); next }
  /^- \[[ xX]\] [0-9]+\.[0-9]+ / && !verification {
    line = $0
    desc = line; sub(/^- \[[ xX]\] [0-9]+\.[0-9]+ /, "", desc)
    is_test = (desc ~ /^[Ww]rite /)
    while (match(line, /\(AC-[0-9]+\)/)) {
      ac = substr(line, RSTART + 1, RLENGTH - 2)
      key = group "|" ac
      if (!(key in seen)) {
        seen[key] = 1
        if (!is_test) print "ERROR: group " group ": the first task for " ac " is not a test task (a test task starts with \"Write\")"
      }
      line = substr(line, RSTART + RLENGTH)
    }
  }')
if [ -n "$order" ]; then
  echo "$order"
  errors=$((errors + $(echo "$order" | grep -c '^ERROR')))
fi

if [ "$skip_specs" -eq 0 ]; then
  for e in $expected; do
    ac="${e%|*}"
    grep -q "($ac)" "$tasks" || err "no task cites ($ac)"
  done
fi

echo "ACs: $(echo "$expected" | sed '/^$/d' | cut -d'|' -f1 | sort -u | wc -l | tr -d ' ')  tasks: $(tr -d '\r' < "$tasks" | grep -cE '^- \[[ xX]\] ')  done: $(tr -d '\r' < "$tasks" | grep -cE '^- \[[xX]\] ')"
echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
