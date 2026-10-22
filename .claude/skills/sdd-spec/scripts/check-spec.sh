#!/usr/bin/env bash
# Checks the project rules for the spec of one change that `openspec validate` does not enforce.
# Usage (from the repository root): bash .claude/skills/sdd-spec/scripts/check-spec.sh <change-id>
# Exit 0 = no errors (warnings may exist). Exit 1 = at least one error.
set -u

change="${1:-}"
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: check-spec.sh <change-id> (run from the repository root; '$dir' not found)" >&2
  exit 2
fi

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }

proposal="$dir/proposal.md"
if [ ! -f "$proposal" ]; then
  err "proposal.md is missing"
elif ! tr -d '\r' < "$proposal" | grep -qE '^\*\*Status:\*\* (Draft|Clarified|Approved)$'; then
  err "proposal.md needs a line '**Status:** Draft|Clarified|Approved'"
fi

specs=$(find "$dir/specs" -name spec.md 2>/dev/null | sort)
if [ -z "$specs" ]; then
  err "no spec.md under $dir/specs"
  echo "Result: $errors error(s), $warnings warning(s)"
  exit 1
fi

all_keys=""
for f in $specs; do
  out=$(tr -d '\r' < "$f" | awk -v file="$f" '
    function close_scenario() {
      if (name == "") return
      if (!when) printf "ERROR: %s: %s has no WHEN\n", file, name
      if (!then_) printf "ERROR: %s: %s has no THEN\n", file, name
      if (!side) printf "ERROR: %s: %s has no **Side:** line\n", file, name
      name = ""
    }
    /^#{1,3} Scenario:/ { printf "ERROR: %s: line %d: scenario heading must use exactly 4 #\n", file, NR }
    /^#### / {
      close_scenario()
      if ($0 ~ /^#### Scenario: /) {
        if ($0 !~ /^#### Scenario: AC-[0-9]+ [^ ]/) {
          printf "ERROR: %s: line %d: scenario must be titled \"AC-<n> <short title>\"\n", file, NR
        } else {
          name = $0; sub(/^#### Scenario: /, "", name)
          key = name; sub(/ .*/, "", key); print "KEY " key
          when = 0; then_ = 0; side = 0
        }
      }
      next
    }
    /^#{1,3} / { close_scenario() }
    name != "" && /^- \*\*WHEN\*\*/ { when = 1 }
    name != "" && /^- \*\*THEN\*\*/ { then_ = 1 }
    name != "" && /^\*\*Side:\*\* (BE|FE|BE \+ FE)$/ { side = 1 }
    /NEEDS CLARIFICATION/ { print "MARKER" }
    /403/ { print "DENIED" }
    END { close_scenario() }
  ')
  echo "$out" | grep -E '^ERROR' && errors=$((errors + $(echo "$out" | grep -cE '^ERROR')))
  all_keys="$all_keys
$(echo "$out" | grep -E '^KEY ' | sed 's/^KEY //')"
  markers_in_file=$(echo "$out" | grep -c '^MARKER')
  markers=$(( ${markers:-0} + markers_in_file ))
  denied=$(( ${denied:-0} + $(echo "$out" | grep -c '^DENIED') ))
done

all_keys=$(echo "$all_keys" | sed '/^$/d')
if [ -z "$all_keys" ]; then
  err "no scenarios found"
else
  dups=$(echo "$all_keys" | sort | uniq -d)
  [ -n "$dups" ] && err "duplicate AC numbers across the change: $(echo $dups)"
  first=$(echo "$all_keys" | sed 's/AC-//' | sort -n | head -1)
  [ "$first" != "1" ] && warn "AC numbering does not start at 1 (starts at $first); fine only if earlier ACs were dropped"
fi

[ "${markers:-0}" -gt 3 ] && err "${markers} [NEEDS CLARIFICATION] markers (max 3)"
[ "${markers:-0}" -gt 0 ] && warn "${markers} open [NEEDS CLARIFICATION] marker(s): run /sdd-clarify"
if [ "${denied:-0}" -eq 0 ] && grep -rqiE 'endpoint|route|API responds' $specs; then
  warn "the spec mentions an endpoint or route but no scenario covers a DENIED role (403)"
fi
if tr -d '\r' < "$proposal" 2>/dev/null | grep -q '^\*\*Status:\*\* Clarified$' && [ "${markers:-0}" -gt 0 ]; then
  err "Status is Clarified but $markers marker(s) remain"
fi

echo "ACs: $(echo "$all_keys" | sed '/^$/d' | wc -l | tr -d ' ')  markers: ${markers:-0}"
echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
