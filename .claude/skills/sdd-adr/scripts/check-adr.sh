#!/usr/bin/env bash
# Checks the ADRs in openspec/adr/: file names, numbering, required fields and sections, supersede links and the index.
# With --change, also checks that every ADR-NNNN cited by that change's design.md exists and is Accepted.
# Usage (from the repository root): bash .claude/skills/sdd-adr/scripts/check-adr.sh [--change <change-id>]
# Exit 0 = no errors (warnings may exist). Exit 1 = at least one error.
set -u

usage() { echo "usage: check-adr.sh [--change <change-id>] (run from the repository root; $1)" >&2; exit 2; }

change=""
if [ "${1:-}" = "--change" ]; then
  change="${2:-}"
  [ -n "$change" ] || usage "--change needs a change id"
  [ -d "openspec/changes/$change" ] || usage "'openspec/changes/$change' not found"
elif [ -n "${1:-}" ]; then
  usage "unknown argument '$1'"
fi

adr="openspec/adr"
index="$adr/README.md"
[ -d "$adr" ] || usage "'$adr' not found"

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }

areas=" backend frontend auth data infra process "
declare -A file status primary supersedes

field() { sed -n "s/^\*\*$1:\*\* *//p" <<< "$2" | head -1; }

for f in "$adr"/*.md; do
  [ -e "$f" ] || continue
  base=$(basename "$f")
  [ "$base" = README.md ] && continue
  if ! [[ $base =~ ^([0-9]{4})-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]]; then
    err "$base: file name must be NNNN-<kebab-title>.md"
    continue
  fi
  n=${BASH_REMATCH[1]}
  if [ -n "${file[$n]:-}" ]; then
    err "ADR-$n: number used twice (${file[$n]} and $base)"
    continue
  fi
  file[$n]=$base
  text=$(tr -d '\r' < "$f")

  [[ $(head -1 <<< "$text") =~ ^#\ ADR-$n:\ .+ ]] || err "$base: first line must be '# ADR-$n: <title>'"

  s=$(field Status "$text")
  status[$n]=$s
  [[ $s =~ ^(Proposed|Accepted|Rejected|Deprecated|Superseded\ by\ ADR-[0-9]{4})$ ]] ||
    err "$base: Status '$s' must be Proposed, Accepted, Rejected, Deprecated or 'Superseded by ADR-NNNN'"

  d=$(field Date "$text")
  [[ $d =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] || err "$base: Date '$d' must be YYYY-MM-DD"

  a=$(field Area "$text")
  [ -n "$a" ] || err "$base: has no '**Area:**' line"
  primary[$n]=""
  IFS=',' read -ra list <<< "$a"
  for one in "${list[@]}"; do
    one=$(echo $one)
    [ -z "${primary[$n]}" ] && primary[$n]=$one
    [[ $areas == *" $one "* ]] || err "$base: Area '$one' must be one of:$areas"
  done

  ch=$(field Change "$text")
  if [ -z "$ch" ]; then
    err "$base: has no '**Change:**' line (a change id or none)"
  elif [ "$ch" != none ] && [ ! -d "openspec/changes/$ch" ] && ! compgen -G "openspec/changes/archive/*-$ch" > /dev/null; then
    warn "$base: Change '$ch' is not in openspec/changes/ nor in its archive"
  fi

  supersedes[$n]=$(field Supersedes "$text" | grep -oE 'ADR-[0-9]{4}' | sed 's/ADR-//' | tr '\n' ' ')

  for h in Context Decision Alternatives Consequences; do
    grep -qx "## $h" <<< "$text" || err "$base: has no '## $h' section"
  done
done

# Numbering: 0001, 0002, ... with no gaps.
expected=1
for n in $(printf '%s\n' "${!file[@]}" | sort); do
  [ $((10#$n)) -eq "$expected" ] || err "numbering gap: expected ADR-$(printf '%04d' "$expected"), found ADR-$n"
  expected=$((10#$n + 1))
done

# Supersede links go both ways; the old ADR is marked only once the new one is Accepted.
for n in "${!file[@]}"; do
  for x in ${supersedes[$n]}; do
    if [ "$x" = "$n" ]; then
      err "ADR-$n supersedes itself"
    elif [ -z "${file[$x]:-}" ]; then
      err "ADR-$n supersedes ADR-$x, which does not exist"
    elif [ "${status[$n]}" = Accepted ] && [ "${status[$x]}" != "Superseded by ADR-$n" ]; then
      err "ADR-$n is Accepted and supersedes ADR-$x, but ADR-$x is not 'Superseded by ADR-$n'"
    fi
  done
  if [[ ${status[$n]} =~ ^Superseded\ by\ ADR-([0-9]{4})$ ]]; then
    y=${BASH_REMATCH[1]}
    if [ -z "${file[$y]:-}" ]; then
      err "ADR-$n is superseded by ADR-$y, which does not exist"
    elif [[ " ${supersedes[$y]} " != *" $n "* ]]; then
      err "ADR-$n is superseded by ADR-$y, but ADR-$y has no '**Supersedes:** ADR-$n'"
    elif [ "${status[$y]}" != Accepted ]; then
      err "ADR-$n is superseded by ADR-$y, which is not Accepted"
    fi
  fi
done

# Index: one row per ADR, under its first Area, with the same status.
declare -A rows
if [ ! -f "$index" ]; then
  err "$index is missing"
else
  heading=""
  while IFS= read -r line; do
    if [[ $line =~ ^###\ +(.+)$ ]]; then
      heading=$(echo ${BASH_REMATCH[1]})
      continue
    fi
    [[ $line =~ ^\|\ *\[ADR-([0-9]{4})\]\(([^\)]+)\)\ *\| ]] || continue
    n=${BASH_REMATCH[1]}
    target=${BASH_REMATCH[2]}
    rows[$n]=$(( ${rows[$n]:-0} + 1 ))
    if [ -z "${file[$n]:-}" ]; then
      err "README.md: row for ADR-$n, which has no file"
      continue
    fi
    [ "$target" = "${file[$n]}" ] || err "README.md: ADR-$n links '$target', expected '${file[$n]}'"
    [ "$heading" = "${primary[$n]}" ] || err "README.md: ADR-$n is under '### $heading', expected '### ${primary[$n]}'"
    IFS='|' read -ra col <<< "$line"
    row_status=$(echo ${col[3]:-})
    row_by=$(echo ${col[4]:-})
    if [[ ${status[$n]} =~ ^Superseded\ by\ (ADR-[0-9]{4})$ ]]; then
      [ "$row_status" = Superseded ] && [ "$row_by" = "${BASH_REMATCH[1]}" ] ||
        err "README.md: ADR-$n must show 'Superseded' and '${BASH_REMATCH[1]}', found '$row_status' and '$row_by'"
    else
      [ "$row_status" = "${status[$n]}" ] || err "README.md: ADR-$n shows status '$row_status', the file says '${status[$n]}'"
      [[ $row_by =~ ADR- ]] && err "README.md: ADR-$n shows superseded by '$row_by', but its file is not superseded"
    fi
  done < <(tr -d '\r' < "$index")
  for n in "${!file[@]}"; do
    case "${rows[$n]:-0}" in
      1) ;;
      0) err "README.md: ADR-$n has no row in the index" ;;
      *) err "README.md: ADR-$n has ${rows[$n]} rows in the index" ;;
    esac
  done
fi

# --change: every ADR the design links exists and is Accepted.
if [ -n "$change" ]; then
  design="openspec/changes/$change/design.md"
  if [ -f "$design" ]; then
    for n in $(tr -d '\r' < "$design" | grep -oE 'ADR-[0-9]{4}' | sed 's/ADR-//' | sort -u); do
      if [ -z "${file[$n]:-}" ]; then
        err "$change: design.md links ADR-$n, which does not exist"
      elif [ "${status[$n]}" != Accepted ]; then
        err "$change: design.md links ADR-$n, whose status is '${status[$n]}' (must be Accepted)"
      fi
    done
  fi
fi

echo "ADRs checked: ${#file[@]}"
echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
