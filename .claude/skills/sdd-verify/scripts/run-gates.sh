#!/usr/bin/env bash
# Runs the AGENTS.md section 8.7 gates of the sides a change touches and prints ONE line per gate, so the
# full build and test output never reaches the model. A failing gate adds its first error lines and the
# path of its full log. Gates: openspec validate; BE build, format, test, coverage >= 25%; FE lint, test
# (karma enforces the 15% threshold itself), build.
# Sides come from the **Side:** lines of the change's specs, or from --be / --fe (which override them).
# The BE gate deletes ERAS-BE/TestResults and ERAS-BE/CoverletReport first (generated output, as CI does).
# Usage (from the repository root): bash .claude/skills/sdd-verify/scripts/run-gates.sh <change-id> [--be] [--fe] [--logs <dir>]
# Exit 0 = every gate passed. Exit 1 = at least one gate failed. Exit 3 = none failed but one could not run
# (tool missing or a file locked: stop Eras.Api or Visual Studio). Exit 2 = bad usage.
# It can take several minutes on Windows: run it in the background and wait for it to finish.
set -u

change="${1:-}"
[ $# -gt 0 ] && shift
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: run-gates.sh <change-id> [--be] [--fe] [--logs <dir>] (run from the repository root; '$dir' not found)" >&2
  exit 2
fi

want_be=0
want_fe=0
explicit=0
logs=""
while [ $# -gt 0 ]; do
  case "$1" in
    --be) want_be=1; explicit=1 ;;
    --fe) want_fe=1; explicit=1 ;;
    --logs) shift; logs="${1:-}" ;;
    *) echo "unknown option '$1'" >&2; exit 2 ;;
  esac
  shift
done

if [ "$explicit" -eq 0 ]; then
  sides=""
  for f in $(find "$dir/specs" -name spec.md 2>/dev/null | sort); do
    sides="$sides
$(tr -d '\r' < "$f" | grep '^\*\*Side:\*\*' || true)"
  done
  echo "$sides" | grep -q 'BE' && want_be=1
  echo "$sides" | grep -q 'FE' && want_fe=1
  [ "$want_be" -eq 0 ] && [ "$want_fe" -eq 0 ] && echo "NOTE:  no **Side:** line in the specs, so only openspec validate runs (pass --be / --fe to add a side)"
fi

[ -n "$logs" ] || logs="$(mktemp -d)"
mkdir -p "$logs"

passed=0
failed=0
unrunnable=0

# gate <name> <dir> <command...>
gate() {
  local name="$1" wd="$2"
  shift 2
  local log="$logs/$(echo "$name" | tr -c 'A-Za-z0-9\n' '_').log" start end code
  if ! command -v "$1" > /dev/null 2>&1; then
    echo "UNRUNNABLE  $name: '$1' not found"
    unrunnable=$((unrunnable + 1))
    return 1
  fi
  start=$(date +%s)
  ( cd "$wd" && "$@" ) > "$log" 2>&1
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

gate "openspec validate" . openspec validate "$change" --strict

if [ "$want_be" -eq 1 ]; then
  rm -rf ERAS-BE/TestResults ERAS-BE/CoverletReport
  gate "BE build" ERAS-BE dotnet build Eras.sln -warnaserror
  gate "BE format" ERAS-BE dotnet format Eras.sln --verify-no-changes
  if gate "BE test" ERAS-BE dotnet test Eras.sln --collect:"XPlat Code Coverage" --results-directory ./TestResults --settings coverlet.runsettings; then
    if ! command -v reportgenerator > /dev/null 2>&1; then
      echo "UNRUNNABLE  BE coverage: 'reportgenerator' not found (dotnet tool install --global dotnet-reportgenerator-globaltool)"
      unrunnable=$((unrunnable + 1))
    else
      ( cd ERAS-BE && reportgenerator "-reports:TestResults/**/coverage.cobertura.xml" -targetdir:CoverletReport -reporttypes:TextSummary ) > "$logs/BE_coverage.log" 2>&1
      pct=$(tr -d '\r' < ERAS-BE/CoverletReport/Summary.txt 2> /dev/null | grep -oE 'Line coverage: *[0-9.]+' | grep -oE '[0-9.]+$' | head -1)
      if [ -z "$pct" ]; then
        echo "UNRUNNABLE  BE coverage: no line coverage in ERAS-BE/CoverletReport/Summary.txt. Log: $logs/BE_coverage.log"
        unrunnable=$((unrunnable + 1))
      elif awk -v p="$pct" 'BEGIN { exit !(p >= 25.0) }'; then
        echo "PASS        BE coverage ($pct% >= 25%)"
        passed=$((passed + 1))
      else
        echo "FAIL        BE coverage ($pct% < 25%)"
        failed=$((failed + 1))
      fi
    fi
  else
    echo "SKIPPED     BE coverage: the BE test gate did not pass"
  fi
fi

if [ "$want_fe" -eq 1 ]; then
  gate "FE lint" ERAS-FE npm run lint
  gate "FE test" ERAS-FE npm test -- --watch=false --browsers=ChromeHeadless --code-coverage
  gate "FE build" ERAS-FE npm run build
fi

echo "Result: $passed passed, $failed failed, $unrunnable unrunnable. Logs: $logs"
[ "$failed" -eq 0 ] || exit 1
[ "$unrunnable" -eq 0 ] || exit 3
exit 0
