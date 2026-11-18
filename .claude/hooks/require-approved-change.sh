#!/usr/bin/env bash
# PreToolUse hook (Edit|Write|MultiEdit|NotebookEdit), OBSERVE MODE (change 0005-add-agent-harness-observe-mode).
# When the edited file is inside the submodule of a side of openspec/sides.conf, it finds the change from that
# submodule's current branch and warns when there is none, more than one, or it is not approved (AGENTS.md 8.1).
# It ALWAYS lets the edit through: exit 0 every time, also on its own errors. ERAS_HOOKS=off silences it.

main() {
  hook_off && return 0
  local input fields session cwd file nb root rel side sub hit="" branch ids count id msg=""
  input=$(cat)
  fields=$(hook_fields "$input" session_id cwd tool_input.file_path tool_input.notebook_path) || return 0
  { read -r session; read -r cwd; read -r file; read -r nb; } <<< "$fields"
  [ -n "$file" ] || file="$nb"
  [ -n "$file" ] || return 0
  root=$(hook_root "$cwd") || return 0
  cd "$root" || return 0
  . .claude/skills/sdd-shared/sides.sh || return 0

  rel=$(hook_norm "$file")
  local nroot
  nroot=$(hook_norm "$root")
  case "$rel" in "$nroot"/*) rel="${rel#"$nroot"/}" ;; *) return 0 ;; esac

  for side in $(sides_list); do
    sub=$(sides_get "$side" submodule)
    [ -n "$sub" ] || continue
    case "$rel" in "$(hook_norm "$sub")"/*) hit="$sub"; break ;; esac
  done
  [ -n "$hit" ] || return 0

  branch=$(git -C "$hit" branch --show-current 2> /dev/null)
  if [ -z "$branch" ]; then
    msg="$hit is on a detached HEAD, so no change can be found for this edit. Create the change branch first (<prefix>/<n>/<title>, AGENTS.md 5.1)."
  else
    ids=$(hook_changes_of_branch "$branch")
    count=$(printf '%s' "$ids" | grep -c . || true)
    if ! printf '%s' "$branch" | grep -qE '[0-9]'; then
      msg="branch '$branch' of $hit names no change number, so no change can be found for this edit (AGENTS.md 8.1)."
    elif [ "$count" -eq 0 ]; then
      msg="branch '$branch' of $hit maps to no change in openspec/changes/ (AGENTS.md 8.1: no code without an approved change)."
    elif [ "$count" -gt 1 ]; then
      msg="branch '$branch' of $hit maps to several changes: $(printf '%s' "$ids" | paste -sd, - | sed 's/,/, /g'). Rename the branch or the change."
    else
      id="$ids"
      if ! hook_approved "$id"; then
        if hook_skip_specs "$id"; then
          msg="change $id is not approved yet (proposal.md needs '**Status:** Approved'); $hit is being edited."
        else
          msg="change $id is not approved yet (proposal.md needs '**Plan:** Approved'); $hit is being edited."
        fi
      fi
    fi
  fi
  [ -n "$msg" ] || return 0
  hook_once "$session" "H1|$msg" || return 0
  hook_emit PreToolUse "ERAS harness (observe mode, the edit is applied): $msg Set ERAS_HOOKS=off to silence." agent
}

. "$(dirname "$0")/hook-lib.sh" 2> /dev/null || exit 0
main 2> /dev/null
exit 0
