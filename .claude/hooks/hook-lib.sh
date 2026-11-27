# Shared by the ERAS Claude Code hooks (change 0005-add-agent-harness-observe-mode). Sourced, never run alone.
# The hooks are in OBSERVE MODE: they only warn and always exit 0. Every helper here fails open, so a problem in a
# hook (missing tool, unexpected input) never blocks a tool call or the end of a turn.
# ERAS_HOOKS: unset or "warn" = warn, "off" = do nothing.

# Changes created (created: in .openspec.yaml) before this date are not reported by report-traceability.sh.
# Keep it equal to HARNESS_SINCE in .github/workflows/sdd-checks.yml.
HARNESS_SINCE="2026-11-18"

hook_off() { [ "${ERAS_HOOKS:-warn}" = off ]; }

# hook_fields <json> <field>...: one line per field (dotted path, "" when missing); returns 1 on broken JSON or no Node
hook_fields() {
  local json="$1"
  shift
  command -v node > /dev/null 2>&1 || return 1
  printf '%s' "$json" | node -e '
let s = "";
process.stdin.on("data", d => s += d).on("end", () => {
  let j;
  try { j = JSON.parse(s); } catch (e) { process.exit(1); }
  for (const p of process.argv.slice(1)) {
    let v = j;
    for (const k of p.split(".")) v = (v !== null && typeof v === "object") ? v[k] : undefined;
    process.stdout.write((v === undefined || v === null ? "" : String(v)).replace(/[\r\n]+/g, " ") + "\n");
  }
});' "$@"
}

# hook_norm <path>: a path in one comparable form. On Windows (cygpath present): drive form with forward slashes,
# lower case, so "C:\x", "c:/x" and "/c/x" compare equal. Elsewhere: unchanged. No trailing slash.
hook_norm() {
  local p="$1"
  if command -v cygpath > /dev/null 2>&1; then
    p=$(cygpath -m "$p" 2> /dev/null || printf '%s' "$p")
    p="${p//\\//}"
    p=$(printf '%s' "$p" | tr '[:upper:]' '[:lower:]')
  fi
  printf '%s' "${p%/}"
}

# hook_root <cwd>: the repository root (CLAUDE_PROJECT_DIR, else the hook's cwd); returns 1 without openspec/sides.conf
hook_root() {
  local r="${CLAUDE_PROJECT_DIR:-$1}"
  [ -n "$r" ] && [ -f "$r/openspec/sides.conf" ] || return 1
  printf '%s' "$r"
}

# hook_changes_of_branch <branch>: the active changes the branch maps to, one per line (the "Change lookup" rule of
# openspec/sdd-conventions.md: the first run of digits in the branch name, matched against openspec/changes/<n>-*)
hook_changes_of_branch() {
  local n d
  n=$(printf '%s' "$1" | grep -oE '[0-9]+' | head -1)
  [ -n "$n" ] || return 0
  for d in openspec/changes/"$n"-*/; do
    [ -d "$d" ] && basename "$d"
  done
  return 0
}

# hook_skip_specs <id>: the change sets skip_specs: true
hook_skip_specs() { tr -d '\r' < "openspec/changes/$1/.openspec.yaml" 2> /dev/null | grep -qE '^skip_specs: *true'; }

# hook_approved <id>: code may be written (Plan: Approved, or Status: Approved for a skip_specs change)
hook_approved() {
  local line='^\*\*Plan:\*\* Approved'
  hook_skip_specs "$1" && line='^\*\*Status:\*\* Approved'
  tr -d '\r' < "openspec/changes/$1/proposal.md" 2> /dev/null | grep -qE "$line"
}

# hook_created <id>: the created: date of the change (YYYY-MM-DD), empty when missing
hook_created() { tr -d '\r' < "openspec/changes/$1/.openspec.yaml" 2> /dev/null | sed -n 's/^created: *\([0-9-]*\).*/\1/p' | head -1; }

# hook_once <session> <key>: true the first time a key is seen in a session (so a warning is shown once)
hook_once() {
  local dir="${TMPDIR:-/tmp}/eras-hooks" sum
  mkdir -p "$dir" 2> /dev/null || return 0
  sum=$(printf '%s|%s' "$1" "$2" | cksum | tr -d ' ')
  [ -e "$dir/$sum" ] && return 1
  : > "$dir/$sum" 2> /dev/null
  return 0
}

# hook_emit <event> <message> [agent]: prints the warning as hook JSON: systemMessage for the user and, when the
# third argument is "agent", hookSpecificOutput.additionalContext for the agent as well
hook_emit() {
  node -e '
const [ev, msg, agent] = process.argv.slice(1);
const o = { systemMessage: msg };
if (agent === "agent") o.hookSpecificOutput = { hookEventName: ev, additionalContext: msg };
process.stdout.write(JSON.stringify(o));' "$1" "$2" "${3:-}"
}
