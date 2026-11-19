#!/usr/bin/env bash
# Stop hook, OBSERVE MODE (change 0005-add-agent-harness-observe-mode).
# When a side's submodule has uncommitted changes and its branch maps to one change that has Plan: Approved, is not
# skip_specs and was created on or after HARNESS_SINCE, it runs check-impl.sh <id> (work in progress, not --final)
# and shows the user a one-line summary when there are warnings or errors, once per result and session.
# It NEVER keeps the agent working: no exit 2, no "decision", no additionalContext. ERAS_HOOKS=off silences it.

main() {
  hook_off && return 0
  local input fields session cwd active root side sub branch ids id seen=" " out summary
  input=$(cat)
  fields=$(hook_fields "$input" session_id cwd stop_hook_active) || return 0
  { read -r session; read -r cwd; read -r active; } <<< "$fields"
  [ "$active" = true ] && return 0
  root=$(hook_root "$cwd") || return 0
  cd "$root" || return 0
  . .claude/skills/sdd-shared/sides.sh || return 0

  for side in $(sides_list); do
    sub=$(sides_get "$side" submodule)
    [ -n "$sub" ] && [ -d "$sub" ] || continue
    [ -n "$(git -C "$sub" status --porcelain 2> /dev/null | head -1)" ] || continue
    branch=$(git -C "$sub" branch --show-current 2> /dev/null)
    [ -n "$branch" ] || continue
    ids=$(hook_changes_of_branch "$branch")
    [ "$(printf '%s' "$ids" | grep -c . || true)" -eq 1 ] || continue
    id="$ids"
    case "$seen" in *" $id "*) continue ;; esac
    seen="$seen$id "
    hook_skip_specs "$id" && continue
    hook_approved "$id" || continue
    [[ "$(hook_created "$id")" < "$HARNESS_SINCE" ]] && continue

    out=$(bash .claude/skills/sdd-implement/scripts/check-impl.sh "$id" 2>&1)
    summary=$(printf '%s\n' "$out" | tr -d '\r' | sed -n 's/^Result: \([0-9]*\) error(s), \([0-9]*\) warning(s).*/\1 error(s), \2 warning(s)/p' | tail -1)
    [ -n "$summary" ] || continue
    [ "$summary" = "0 error(s), 0 warning(s)" ] && continue
    hook_once "$session" "H2|$id|$summary" || continue
    hook_emit Stop "ERAS harness (observe mode): check-impl.sh $id reports $summary. Details: bash .claude/skills/sdd-implement/scripts/check-impl.sh $id. Set ERAS_HOOKS=off to silence."
    return 0
  done
  return 0
}

. "$(dirname "$0")/hook-lib.sh" 2> /dev/null || exit 0
main 2> /dev/null
exit 0
