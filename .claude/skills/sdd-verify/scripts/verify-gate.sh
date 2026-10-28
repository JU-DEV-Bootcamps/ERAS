#!/usr/bin/env bash
# Pre-flight gate of /sdd-verify (step 2): tasks ticked, spec and plan approved, manual validation logged.
# It does not map ACs to tests (check-impl.sh --final does), run the gates or judge drift.
# Usage (from the repository root): bash .claude/skills/sdd-verify/scripts/verify-gate.sh <change-id>
# Exit 0 = no errors (warnings may exist). Exit 1 = at least one error. Exit 2 = bad usage.
set -u

change="${1:-}"
dir="openspec/changes/$change"
if [ -z "$change" ] || [ ! -d "$dir" ]; then
  echo "usage: verify-gate.sh <change-id> (run from the repository root; '$dir' not found)" >&2
  exit 2
fi

errors=0
warnings=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }
warn() { echo "WARN:  $*"; warnings=$((warnings + 1)); }

tasks="$dir/tasks.md"
proposal="$dir/proposal.md"

# Tasks: every task [x]; struck-through (replaced) tasks never match this pattern.
if [ ! -f "$tasks" ]; then
  err "tasks.md is missing"
else
  open=$(tr -d '\r' < "$tasks" | grep -E '^- \[ \] [0-9]+\.[0-9]+ ' || true)
  if [ -n "$open" ]; then
    err "$(echo "$open" | wc -l | tr -d ' ') task(s) still unchecked:"
    echo "$open" | sed 's/^/         /'
  fi
fi

if [ ! -f "$proposal" ]; then
  err "proposal.md is missing"
else
  p=$(tr -d '\r' < "$proposal")

  # Status and Plan: only a human sets Approved. Changes with skip_specs carry neither line.
  for field in Status Plan; do
    line=$(echo "$p" | grep -m1 "^\*\*$field:\*\*" || true)
    if [ -z "$line" ]; then
      grep -q '^skip_specs: *true' "$dir/.openspec.yaml" 2>/dev/null || warn "proposal.md has no '**$field:**' line"
    elif [ "$line" != "**$field:** Approved" ]; then
      warn "$line (expected '**$field:** Approved' before verifying)"
    fi
  done

  # Validation log: needs an approval or an explicit skip.
  log=$(echo "$p" | awk '/^## Validation log/ { on = 1; next } /^## / { on = 0 } on')
  if [ -z "$(echo "$log" | tr -d '[:space:]')" ]; then
    warn "no '## Validation log' entries: run /sdd-validate-impl first if the change touched a BE controller or the FE"
  elif ! echo "$log" | grep -qE 'Approved by |Skipped:'; then
    warn "'## Validation log' has no 'Approved by ...' or 'Skipped: ...' line: run /sdd-validate-impl"
  fi

  if echo "$p" | grep -qE '^(- )?Verified [0-9]{4}-[0-9]{2}-[0-9]{2}:'; then
    echo "NOTE:  a 'Verified ...' line already exists; re-verifying will refresh it"
  fi
fi

echo "Result: $errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
