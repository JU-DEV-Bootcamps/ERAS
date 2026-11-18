#!/usr/bin/env bash
# Self-test of the ERAS Claude Code hooks (change 0005-add-agent-harness-observe-mode): feeds sample hook inputs to
# require-approved-change.sh (PreToolUse) and report-traceability.sh (Stop) inside a throwaway fixture repository
# and checks that they always exit 0 and warn only when they should.
# Usage (any directory): bash .claude/hooks/tests/run-tests.sh
# Exit 0 = every case behaved as expected.
set -u

hooks="$(cd "$(dirname "$0")/.." && pwd)"
repo="$(cd "$hooks/../.." && pwd)"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

passed=0
failed=0
ok() { echo "ok    $1"; passed=$((passed + 1)); }
ko() { echo "FAIL  $1"; echo "      exit=$2 output=$3"; failed=$((failed + 1)); }

# --- fixture: a parent repo with the real sides registry and scripts, three sides as git repos, and changes
root="$work/repo"
mkdir -p "$root/openspec/changes" "$root/.claude/skills/sdd-shared" "$root/.claude/skills/sdd-implement/scripts"
cp "$repo/openspec/sides.conf" "$root/openspec/sides.conf"
cp "$repo/.claude/skills/sdd-shared/sides.sh" "$root/.claude/skills/sdd-shared/sides.sh"
cp "$repo/.claude/skills/sdd-implement/scripts/check-impl.sh" "$root/.claude/skills/sdd-implement/scripts/check-impl.sh"

# change <id> <created> <skip_specs 0|1> <status> [<plan>]
change() {
  local d="$root/openspec/changes/$1"
  mkdir -p "$d/specs/demo"
  printf 'schema: spec-driven\ncreated: %s\n' "$2" > "$d/.openspec.yaml"
  [ "$3" = 1 ] && printf 'skip_specs: true\n' >> "$d/.openspec.yaml"
  { printf '# Proposal\n\n**Status:** %s\n' "$4"; [ -n "${5:-}" ] && printf '**Plan:** %s\n' "$5"; } > "$d/proposal.md"
  printf '# Tasks\n\n## 1. Demo\n\n- [ ] 1.1 Write the test (AC-1)\n' > "$d/tasks.md"
  printf '## ADDED Requirements\n\n### Requirement: Demo\nThe system SHALL demo.\n\n#### Scenario: AC-1 Demo\n**Side:** BE\n- **WHEN** x\n- **THEN** y\n' > "$d/specs/demo/spec.md"
}
change 701-approved-plan    2099-01-01 0 Approved Approved
change 702-draft-plan       2099-01-01 0 Approved Draft
change 703-skip-approved    2099-01-01 1 Approved
change 704-old-approved     2000-01-01 0 Approved Approved
change 705-dup-a            2099-01-01 0 Approved Approved
change 705-dup-b            2099-01-01 0 Approved Approved

# side <folder> <branch|DETACHED>: a git repo with one commit on that branch
side() {
  local d="$root/$1"
  rm -rf "$d"; mkdir -p "$d"
  git -C "$d" init -q
  git -C "$d" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
  if [ "$2" = DETACHED ]; then git -C "$d" checkout -q --detach; else git -C "$d" checkout -q -b "$2"; fi
}
side ERAS-BE feature/701/approved
side ERAS-FE feature/BE702/draft
side ERAS-FE-React develop

export CLAUDE_PROJECT_DIR="$root"
export TMPDIR="$work/tmp"
mkdir -p "$TMPDIR"
unset ERAS_HOOKS

session=0
# run <hook> <json>: sets out and code; every call gets a new session id unless SAME_SESSION=1
run() {
  [ "${SAME_SESSION:-0}" = 1 ] || session=$((session + 1))
  local json="${2//@SESSION@/s$session}"
  out=$(printf '%s' "$json" | bash "$hooks/$1" 2> /dev/null)
  code=$?
}
pre() { printf '{"session_id":"@SESSION@","cwd":"%s","hook_event_name":"PreToolUse","tool_name":"%s","tool_input":{"%s":"%s"}}' "$root" "${3:-Edit}" "${2:-file_path}" "$1"; }
stop() { printf '{"session_id":"@SESSION@","cwd":"%s","hook_event_name":"Stop","stop_hook_active":%s}' "$root" "${1:-false}"; }

H1=require-approved-change.sh
H2=report-traceability.sh
# expect_silent <name>; expect_warn <name> <text>
expect_silent() { if [ "$code" = 0 ] && [ -z "$out" ]; then ok "$1"; else ko "$1" "$code" "$out"; fi; }
expect_warn() {
  if [ "$code" = 0 ] && printf '%s' "$out" | grep -q '"systemMessage"' && printf '%s' "$out" | grep -qF "$2" \
    && printf '%s' "$out" | node -e 'let s="";process.stdin.on("data",d=>s+=d).on("end",()=>JSON.parse(s))' 2> /dev/null; then
    ok "$1"
  else
    ko "$1" "$code" "$out"
  fi
}

# --- Hook 1 (PreToolUse)
run $H1 "$(pre "$root/openspec/notes.md")";                        expect_silent "H1: a parent-repo path is not checked"
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_silent "H1: a submodule edit on a branch of a Plan-Approved change is silent"
side ERAS-BE feature/999/unknown
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_warn   "H1: a branch that maps to no change warns" "maps to no change"
side ERAS-BE develop
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_warn   "H1: a branch with no change number warns" "names no change number"
side ERAS-BE DETACHED
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_warn   "H1: a detached HEAD warns and says so" "detached"
side ERAS-BE feature/705/dup
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_warn   "H1: a branch that maps to two changes warns" "several changes"
run $H1 "$(pre "$root/ERAS-FE/src/app/a.ts")";                     expect_warn   "H1: a change whose Plan is Draft warns" "702-draft-plan is not approved"
side ERAS-BE chore/703/skip
run $H1 "$(pre "$root/ERAS-BE/src/A.cs")";                         expect_silent "H1: a skip_specs change with Status Approved is silent"
winroot=$( { command -v cygpath > /dev/null && cygpath -w "$root"; } || printf '%s' "$root" | tr / '\\')
winpath=$(printf '%s\\ERAS-FE\\src\\app\\a.ts' "$winroot" | sed 's/\\/\\\\/g')
run $H1 "$(pre "$winpath")";                                       expect_warn   "H1: a Windows path with backslashes is matched to its side" "702-draft-plan"
run $H1 "$(pre "$root/ERAS-FE/x.ipynb" notebook_path NotebookEdit)"; expect_warn  "H1: NotebookEdit's notebook_path is checked" "702-draft-plan"
run $H1 "$(pre "$root/ERAS-FE-React/src/a.tsx")";                  expect_warn   "H1: a side found through the registry (FE-React) is checked" "ERAS-FE-React"
run $H1 '{"tool_input": {"file_path": ';                           expect_silent "H1: broken JSON fails open"
ERAS_HOOKS=off run $H1 "$(pre "$root/ERAS-FE/src/app/a.ts")";      expect_silent "H1: ERAS_HOOKS=off silences it"
SAME_SESSION=0 run $H1 "$(pre "$root/ERAS-FE/src/app/a.ts")"
SAME_SESSION=1 run $H1 "$(pre "$root/ERAS-FE/src/app/b.ts")";      expect_silent "H1: the same warning is shown once per session"
CLAUDE_PROJECT_DIR="$work/nowhere" run $H1 "$(pre "$work/nowhere/ERAS-BE/A.cs")"; expect_silent "H1: a folder without openspec/sides.conf fails open"

# --- Hook 2 (Stop)
side ERAS-BE feature/701/approved
side ERAS-FE develop
run $H2 "$(stop)";                                                 expect_silent "H2: no uncommitted submodule change is silent"
echo x > "$root/ERAS-BE/new.cs"
run $H2 "$(stop)";                                                 expect_warn   "H2: an uncommitted change on an approved post-cutoff change reports check-impl" "701-approved-plan"
SAME_SESSION=1 run $H2 "$(stop)";                                  expect_silent "H2: the same result is not reported twice in a session"
run $H2 "$(stop true)";                                            expect_silent "H2: stop_hook_active=true is silent"
ERAS_HOOKS=off run $H2 "$(stop)";                                  expect_silent "H2: ERAS_HOOKS=off silences it"
side ERAS-BE feature/704/old
echo x > "$root/ERAS-BE/new.cs"
run $H2 "$(stop)";                                                 expect_silent "H2: a change created before the cutoff is skipped"
side ERAS-BE feature/702/draft
echo x > "$root/ERAS-BE/new.cs"
run $H2 "$(stop)";                                                 expect_silent "H2: a change whose Plan is Draft is skipped"
run $H2 'not json';                                                expect_silent "H2: broken JSON fails open"

echo
echo "passed: $passed  failed: $failed"
[ "$failed" -eq 0 ]
