#!/usr/bin/env bash
# Runs the AGENTS.md section 8.7 gates of the sides a change touches and prints ONE line per gate, so the
# full build and test output never reaches the model. A failing gate adds its first error lines and the
# path of its full log. Gates: openspec validate, then the gates of each side as openspec/sides.conf lists them
# (ADR-0011): its gate.<name> commands in file order, run inside its submodule, and its coverage minimum.
# Sides come from the **Side:** lines of the change's specs, or from --side <name> (repeatable), --be or --fe,
# which override them. A side's "clean" folders are deleted first (generated output, as CI does).
# Usage (from the repository root): bash .claude/skills/sdd-verify/scripts/run-gates.sh <change-id> [--side <name>]... [--be] [--fe] [--logs <dir>]
# Exit 0 = every gate passed. Exit 1 = at least one gate failed. Exit 3 = none failed but one could not run
# (tool or submodule missing, or a file locked: stop Eras.Api or Visual Studio). Exit 2 = bad usage.
# It can take several minutes on Windows: run it in the background and wait for it to finish.
set -u

. "$(dirname "$0")/../../sdd-shared/sides.sh"

change="${1:-}"
[ $# -gt 0 ] && shift
dir="openspec/changes/$change"
usage="usage: run-gates.sh <change-id> [--side <name>]... [--be] [--fe] [--logs <dir>] (run from the repository root"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "$usage; '$dir' not found)" >&2
  exit 2
fi
if ! sides_ok; then
  echo "$usage; $SIDES_CONF not found)" >&2
  exit 2
fi

wanted=""
explicit=0
logs=""
want() {
  if ! sides_has "$1"; then echo "unknown side '$1' (sides: $(sides_list | paste -sd' ' -))" >&2; exit 2; fi
  wanted="$wanted $1"
  explicit=1
}
while [ $# -gt 0 ]; do
  case "$1" in
    --be) want BE ;;
    --fe) want FE ;;
    --side) shift; want "${1:-}" ;;
    --logs) shift; logs="${1:-}" ;;
    *) echo "unknown option '$1'" >&2; exit 2 ;;
  esac
  shift
done

if [ "$explicit" -eq 0 ]; then
  wanted=$(sides_of_specs $(find "$dir/specs" -name spec.md 2>/dev/null | sort) | cut -d'|' -f2 | sort -u | paste -sd' ' -)
  [ -z "$wanted" ] && echo "NOTE:  no **Side:** line in the specs, so only openspec validate runs (pass --side <name>, --be or --fe to add a side)"
fi

[ -n "$logs" ] || logs="$(mktemp -d)"
mkdir -p "$logs"

passed=0
failed=0
unrunnable=0

# gate <name> <dir> <command line>
gate() {
  local name="$1" wd="$2" cmd="$3"
  local log="$logs/$(echo "$name" | tr -c 'A-Za-z0-9\n' '_').log" start end code tool
  tool="${cmd%% *}"
  if ! command -v "$tool" > /dev/null 2>&1; then
    echo "UNRUNNABLE  $name: '$tool' not found"
    unrunnable=$((unrunnable + 1))
    return 1
  fi
  start=$(date +%s)
  ( cd "$wd" && eval "$cmd" ) < /dev/null > "$log" 2>&1
  code=$?
  end=$(date +%s)
  if [ "$code" -eq 0 ]; then
    echo "PASS        $name ($((end - start))s)"
    passed=$((passed + 1))
    return 0
  fi
  if grep -qE 'being used by another process|MSB3021|MSB3027' "$log"; then
    echo "UNRUNNABLE  $name: a file is locked (stop a running Eras.Api or Visual Studio and rerun). Log: $log"
    unrunnable=$((unrunnable + 1))
    return 1
  fi
  echo "FAIL        $name (exit $code). Log: $log"
  { tr -d '\r' < "$log" | grep -E 'error|Failed|FAIL|ERROR' | head -12; } | sed 's/^/            /'
  failed=$((failed + 1))
  return 1
}

# coverage <side> <dir> <minimum>: line coverage from the Cobertura files that gate.test wrote
coverage() {
  local side="$1" wd="$2" min="$3" pct
  if ! command -v reportgenerator > /dev/null 2>&1; then
    echo "UNRUNNABLE  $side coverage: 'reportgenerator' not found (dotnet tool install --global dotnet-reportgenerator-globaltool)"
    unrunnable=$((unrunnable + 1))
    return
  fi
  ( cd "$wd" && reportgenerator "-reports:TestResults/**/coverage.cobertura.xml" -targetdir:CoverletReport -reporttypes:TextSummary ) > "$logs/${side}_coverage.log" 2>&1
  pct=$(tr -d '\r' < "$wd/CoverletReport/Summary.txt" 2> /dev/null | grep -oE 'Line coverage: *[0-9.]+' | grep -oE '[0-9.]+$' | head -1)
  if [ -z "$pct" ]; then
    echo "UNRUNNABLE  $side coverage: no line coverage in $wd/CoverletReport/Summary.txt. Log: $logs/${side}_coverage.log"
    unrunnable=$((unrunnable + 1))
  elif awk -v p="$pct" -v m="$min" 'BEGIN { exit !(p >= m + 0.0) }'; then
    echo "PASS        $side coverage ($pct% >= $min%)"
    passed=$((passed + 1))
  else
    echo "FAIL        $side coverage ($pct% < $min%)"
    failed=$((failed + 1))
  fi
}

gate "openspec validate" . "openspec validate \"$change\" --strict"

for side in $(sides_list); do
  case " $wanted " in *" $side "*) ;; *) continue ;; esac
  wd=$(sides_get "$side" submodule)
  if [ ! -d "$wd" ]; then
    echo "UNRUNNABLE  $side gates: the submodule '$wd' is not checked out (git submodule update --init)"
    unrunnable=$((unrunnable + 1))
    continue
  fi
  for d in $(sides_get "$side" clean); do rm -rf "${wd:?}/$d"; done
  min=$(sides_get "$side" coverage)
  while IFS="$(printf '\t')" read -r name cmd; do
    [ -n "$name" ] || continue
    if gate "$side $name" "$wd" "$cmd"; then
      [ "$name" = test ] && [ -n "$min" ] && coverage "$side" "$wd" "$min"
    elif [ "$name" = test ] && [ -n "$min" ]; then
      echo "SKIPPED     $side coverage: the $side test gate did not pass"
    fi
  done <<< "$(sides_gates "$side")"
done

echo "Result: $passed passed, $failed failed, $unrunnable unrunnable. Logs: $logs"
[ "$failed" -eq 0 ] || exit 1
[ "$unrunnable" -eq 0 ] || exit 3
exit 0
