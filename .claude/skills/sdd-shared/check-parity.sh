#!/usr/bin/env bash
# Parity report of the clients of one product (ADR-0011). For every parity group of openspec/sides.conf (sides with
# the same "group"), it lists the scenarios whose **Side:** line names some sides of the group but not the others,
# in the living specs (openspec/specs/) and the active changes (openspec/changes/, not the archive).
# Informative only: it always exits 0, so it never blocks a change or a pull request.
# Usage (from the repository root): bash .claude/skills/sdd-shared/check-parity.sh [--summary]
#   --summary : only the count per group and per file, not one line per scenario
set -u

. "$(dirname "$0")/sides.sh"

summary=0
[ "${1:-}" = "--summary" ] && summary=1

if ! sides_ok; then
  echo "NOTE:  $SIDES_CONF not found: no side to compare"
  exit 0
fi

groups=$(for s in $(sides_list); do sides_get "$s" group; done | sed '/^$/d' | sort -u)
if [ -z "$groups" ]; then
  echo "NOTE:  no side of $SIDES_CONF has a group: nothing to compare"
  exit 0
fi

files=$( { find openspec/specs -name spec.md 2>/dev/null; find openspec/changes -path openspec/changes/archive -prune -o -name spec.md -print 2>/dev/null; } | sort)

for g in $groups; do
  members=$(for s in $(sides_list); do [ "$(sides_get "$s" group)" = "$g" ] && echo "$s"; done | paste -sd' ' -)
  echo "== group $g: $(echo "$members" | sed 's/ / and /g')"
  if [ "$(echo "$members" | wc -w)" -lt 2 ]; then
    echo "   only one side in the group: nothing to compare"
    continue
  fi
  gaps=0
  for f in $files; do
    out=$(tr -d '\r' < "$f" | awk -v members="$members" -v file="$f" '
      BEGIN { n = split(members, m, " ") }
      /^#### Scenario: / { title = $0; sub(/^#### Scenario: /, "", title) }
      /^\*\*Side:\*\* / {
        side = $0; sub(/^\*\*Side:\*\* /, "", side)
        k = split(side, p, / \+ /)
        split("", has)
        for (i = 1; i <= k; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", p[i]); has[p[i]] = 1 }
        got = ""; miss = ""
        for (i = 1; i <= n; i++) {
          if (m[i] in has) got = got (got == "" ? "" : ", ") m[i]
          else miss = miss (miss == "" ? "" : ", ") m[i]
        }
        if (got != "" && miss != "") printf "%s: %s: has %s, missing %s\n", file, title, got, miss
      }')
    [ -z "$out" ] && continue
    count=$(echo "$out" | wc -l | tr -d ' ')
    gaps=$((gaps + count))
    if [ "$summary" -eq 1 ]; then echo "   $f: $count"; else echo "$out" | sed 's/^/   /'; fi
  done
  echo "   scenarios without parity in group $g: $gaps"
done
echo "Informative only: this report never fails."
exit 0
