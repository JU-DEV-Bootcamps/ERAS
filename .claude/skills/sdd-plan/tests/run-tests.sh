#!/usr/bin/env bash
# Self-test of the SDD check scripts (check-spec, check-plan, check-impl, verify-gate, run-gates, check-adr, check-archive, check-skills) against fixtures built from the worked examples.
# Usage (any directory): bash .claude/skills/sdd-plan/tests/run-tests.sh [plan|impl|verify|gates|spec|adr|archive|skills]
# With no argument every section runs (about 5 minutes on Windows); with one, only that section.
# Exit 0 = every case behaved as expected.
set -u

only="${1:-all}"
section() { [ "$only" = all ] || [ "$only" = "$1" ]; }

skills="$(cd "$(dirname "$0")/../.." && pwd)"
id="608-reject-duplicate-configuration-name"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

passed=0
failed=0

new_change() {
  rm -rf "$work/repo"
  mkdir -p "$work/repo/openspec/changes/$id/specs/configuration-management" "$work/repo/ERAS-BE/test" "$work/repo/ERAS-FE/src/app"
  local c="$work/repo/openspec/changes/$id"
  printf 'schema: spec-driven\ncreated: 2026-01-01\n' > "$c/.openspec.yaml"
  cp "$skills/sdd-spec/examples/$id/proposal.md" "$c/proposal.md"
  cp "$skills/sdd-spec/examples/$id/specs/configuration-management/spec.md" "$c/specs/configuration-management/spec.md"
  cp "$skills/sdd-plan/examples/$id/design.md" "$skills/sdd-plan/examples/$id/tasks.md" "$c/"
  sed -i 's/^\*\*Status:\*\* Draft\r\?$/**Status:** Approved\n**Plan:** Draft/' "$c/proposal.md"
  cd "$work/repo" || exit 1
}

tag_be() { printf '    [Trait("AC", "%s/%s")]\n' "$id" "$1" >> "$work/repo/ERAS-BE/test/$2.cs"; }
tag_fe() { printf "  it('[%s/%s] %s', () => {});\n" "$id" "$1" "$3" >> "$work/repo/ERAS-FE/src/app/$2.spec.ts"; }

add_all_tests() {
  for ac in AC-1 AC-2 AC-4 AC-6; do tag_be "$ac" "Tests$ac"; done
  for ac in AC-3 AC-5 AC-6; do tag_fe "$ac" "unit-$ac" "does the thing"; done
  sed -i 's/^- \[ \]/- [x]/' "$work/repo/openspec/changes/$id/tasks.md"
}

expect() {
  local name="$1" want="$2" pattern="$3"; shift 3
  local out code
  out="$("$@" 2>&1)"; code=$?
  if [ "$code" -eq "$want" ] && { [ -z "$pattern" ] || echo "$out" | grep -qF -- "$pattern"; }; then
    passed=$((passed + 1)); echo "ok    $name"
  else
    failed=$((failed + 1)); echo "FAIL  $name (exit $code, wanted $want, pattern '$pattern')"; echo "$out" | sed 's/^/        /'
  fi
}

plan="bash $skills/sdd-plan/scripts/check-plan.sh $id"
impl="bash $skills/sdd-implement/scripts/check-impl.sh $id"
spec="bash $skills/sdd-spec/scripts/check-spec.sh $id"
c() { echo "$work/repo/openspec/changes/$id"; }

if section plan; then
echo "== check-plan"
new_change;  expect "plan: valid example passes" 0 "Result: 0 error(s)" $plan
new_change;  sed -i '/^| AC-3 /d' "$(c)/tasks.md"
             expect "plan: missing Traceability row" 1 "no row for AC-3 on side FE" $plan
new_change;  sed -i '/^| AC-6 .*| FE |/d' "$(c)/tasks.md"
             expect "plan: BE + FE needs a row per side" 1 "no row for AC-6 on side FE" $plan
new_change;  printf '| AC-1 | x | FE | y |\n' >> "$(c)/tasks.md"
             expect "plan: row for a side the spec does not declare" 1 "not declared by a **Side:**" $plan
new_change;  printf '\n## Extra\n- x\n' >> "$(c)/design.md"
             expect "plan: design must end with Follow-ups" 1 "design.md must end with" $plan
new_change;  sed -i 's/^## Test strategy/## Tests/' "$(c)/design.md"
             expect "plan: design needs Test strategy" 1 "Test strategy" $plan
new_change;  sed -i 's/^- \[ \] 1\.1 /- [] 1.1 /' "$(c)/tasks.md"
             expect "plan: malformed checkbox" 1 "malformed task line" $plan
new_change;  sed -i 's/^- \[ \] 1\.1 Write/- [ ] 1.1 Implement/' "$(c)/tasks.md"
             expect "plan: implementation before its test" 1 "first task for AC-1 is not a test task" $plan
new_change;  sed -i 's/ (AGENTS.md section 8.7)//' "$(c)/tasks.md"
             expect "plan: verification must cite 8.7" 1 "cite 8.7" $plan
new_change;  sed -i '/^## 3\. Verification/,/^## Traceability/{/^## Traceability/!d}' "$(c)/tasks.md"
             expect "plan: last group must be verification" 1 "verification group" $plan
new_change;  sed -i '/(AC-5)/d' "$(c)/tasks.md"
             expect "plan: an AC no task cites" 1 "no task cites (AC-5)" $plan
new_change;  rm "$(c)/tasks.md"
             expect "plan: tasks.md missing" 1 "tasks.md is missing" $plan
new_change;  sed -i 's/$/\r/' "$(c)/tasks.md" "$(c)/design.md" "$(c)/proposal.md" "$(c)/specs/configuration-management/spec.md"
             expect "plan: CRLF files still pass" 0 "Result: 0 error(s)" $plan
new_change;  printf 'schema: spec-driven\nskip_specs: true\n' > "$(c)/.openspec.yaml"; rm -r "$(c)/design.md" "$(c)/specs"
             printf '# Tasks\n\n## 1. Docs\n\n- [ ] 1.1 Add the page and verify it renders\n\n## 2. Verification\n\n- [ ] 2.1 Verify the link works\n' > "$(c)/tasks.md"
             expect "plan: skip_specs change needs only proposal and tasks" 0 "Result: 0 error(s)" $plan

fi

if section impl; then
echo "== check-impl"
new_change;  add_all_tests
             expect "impl: complete change passes --final" 0 "Result: 0 error(s)" $impl --final
new_change;  add_all_tests; rm "$work/repo/ERAS-BE/test/TestsAC-4.cs"
             expect "impl: missing test fails --final" 1 "AC-4 on BE has no tagged test" $impl --final
new_change;  add_all_tests; rm "$work/repo/ERAS-BE/test/TestsAC-4.cs"
             expect "impl: missing test is a warning in progress" 0 "WARN:  $id/AC-4 on BE has no tagged test" $impl
new_change;  add_all_tests; tag_be AC-1 Duplicate
             expect "impl: two tests for one AC" 1 "has 2 tagged tests" $impl
new_change;  add_all_tests; tag_fe AC-6 more "second one"
             expect "impl: two FE tests for one AC" 1 "$id/AC-6 on FE has 2 tagged tests" $impl
new_change;  add_all_tests; tag_be AC-3 WrongSide
             expect "impl: tag on a side the spec does not declare" 1 "does not declare it for BE" $impl
new_change;  add_all_tests; tag_fe AC-1 WrongSideFe "wrong side"
             expect "impl: FE tag on a side the spec does not declare" 1 "does not declare it for FE" $impl
new_change;  add_all_tests; printf "  fit('x', () => {});\n" >> "$work/repo/ERAS-FE/src/app/unit-AC-3.spec.ts"
             expect "impl: focused test" 1 "focused or skipped test" $impl
new_change;  add_all_tests; sed -i '0,/^- \[x\]/s//- [ ]/' "$(c)/tasks.md"
             expect "impl: unchecked task fails --final" 1 "still unchecked" $impl --final
new_change;  add_all_tests; sed -i '0,/^- \[x\]/s//- [ ]/' "$(c)/tasks.md"
             expect "impl: unchecked task is a warning in progress" 0 "still unchecked" $impl

fi

if section verify; then
echo "== verify-gate"
vg() { bash "$skills/sdd-verify/scripts/verify-gate.sh" "$id"; }
ready_verify() {
  new_change
  sed -i 's/^- \[ \]/- [x]/' "$(c)/tasks.md"
  sed -i 's/^\*\*Plan:\*\* Draft/**Plan:** Approved/' "$(c)/proposal.md"
  printf '\n## Validation log\n\n- Skipped: no BE controller or FE change.\n' >> "$(c)/proposal.md"
}
ready_verify; expect "verify: ready change passes clean" 0 "Result: 0 error(s), 0 warning(s)" vg
ready_verify; sed -i '0,/^- \[x\]/s//- [ ]/' "$(c)/tasks.md"
              expect "verify: unchecked task fails" 1 "still unchecked" vg
ready_verify; printf -- '- [ ] ~~9.9~~ (replaced by 1.1)\n' >> "$(c)/tasks.md"
              expect "verify: struck-through task is ignored" 0 "Result: 0 error(s), 0 warning(s)" vg
ready_verify; rm "$(c)/tasks.md"
              expect "verify: tasks.md missing" 1 "tasks.md is missing" vg
ready_verify; sed -i 's/^\*\*Plan:\*\* Approved/**Plan:** Draft/' "$(c)/proposal.md"
              expect "verify: Plan not approved warns" 0 "expected '**Plan:** Approved'" vg
ready_verify; sed -i 's/^\*\*Status:\*\* Approved/**Status:** Draft/' "$(c)/proposal.md"
              expect "verify: Status not approved warns" 0 "expected '**Status:** Approved'" vg
ready_verify; sed -i '/^## Validation log/,$d' "$(c)/proposal.md"
              expect "verify: no validation log warns" 0 "no '## Validation log' entries" vg
ready_verify; sed -i '/^- Skipped:/d' "$(c)/proposal.md"; printf -- '- Round 1: found a problem.\n' >> "$(c)/proposal.md"
              expect "verify: log without approval or skip warns" 0 "has no 'Approved by" vg
ready_verify; sed -i 's/^- Skipped:.*/- Approved by the developer, 2026-10-28./' "$(c)/proposal.md"
              expect "verify: an approval in the log passes clean" 0 "Result: 0 error(s), 0 warning(s)" vg
ready_verify; printf -- '- Verified 2026-10-28: no gaps, no drift, gates green\n' >> "$(c)/proposal.md"
              expect "verify: an existing Verified line is noted" 0 "a 'Verified ...' line already exists" vg
ready_verify; sed -i 's/$/\r/' "$(c)/tasks.md" "$(c)/proposal.md"
              expect "verify: CRLF files still pass" 0 "Result: 0 error(s), 0 warning(s)" vg
ready_verify; printf 'schema: spec-driven\nskip_specs: true\n' > "$(c)/.openspec.yaml"; sed -i '/^\*\*Status:\*\*/d; /^\*\*Plan:\*\*/d' "$(c)/proposal.md"
              expect "verify: skip_specs change needs no Status or Plan" 0 "Result: 0 error(s), 0 warning(s)" vg
fi

if section gates; then
echo "== run-gates"
# Fake dotnet, npm, openspec and reportgenerator on the PATH: GATE_MODE picks the behavior, COV the coverage figure.
stubs="$work/bin"
mkdir -p "$stubs"
printf '#!/bin/sh\nexit 0\n' > "$stubs/openspec"
printf '#!/bin/sh\nexit 0\n' > "$stubs/npm"
cat > "$stubs/dotnet" <<'STUB'
#!/bin/sh
case "$GATE_MODE:$1" in
  fail-build:build) echo "src/A.cs(1,1): error CS1002: ; expected"; exit 1 ;;
  lock:build) echo "error MSB3027: The process cannot access the file because it is being used by another process."; exit 1 ;;
esac
exit 0
STUB
cat > "$stubs/reportgenerator" <<'STUB'
#!/bin/sh
mkdir -p CoverletReport
printf 'Line coverage: %s%%\n' "${COV:-41.2}" > CoverletReport/Summary.txt
STUB
chmod +x "$stubs"/*
gates_script="$skills/sdd-verify/scripts/run-gates.sh"
rg() { env PATH="$stubs:$PATH" "$@" bash "$gates_script" "$id"; }
nonpm="$work/bin-nonpm"
mkdir -p "$nonpm"
cp "$stubs/openspec" "$stubs/dotnet" "$stubs/reportgenerator" "$nonpm/"
rg_noext() { env PATH="$nonpm:$(dirname "$(command -v bash)"):/usr/bin:/bin" "$@" bash "$gates_script" "$id"; }

new_change; expect "gates: every gate passes" 0 "Result: 8 passed, 0 failed, 0 unrunnable" rg
new_change; expect "gates: a failing gate shows its error and fails" 1 "error CS1002" rg GATE_MODE=fail-build
new_change; expect "gates: a failing gate is named" 1 "FAIL        BE build" rg GATE_MODE=fail-build
new_change; expect "gates: a locked file is unrunnable, not failed" 3 "UNRUNNABLE  BE build: a file is locked" rg GATE_MODE=lock
new_change; expect "gates: coverage below 25 fails" 1 "FAIL        BE coverage" rg COV=12
new_change; expect "gates: a missing tool is unrunnable" 3 "UNRUNNABLE  FE lint: 'npm' not found" rg_noext
new_change; expect "gates: --be runs only the backend" 0 "Result: 5 passed, 0 failed, 0 unrunnable" env PATH="$stubs:$PATH" bash "$gates_script" "$id" --be
new_change; printf 'schema: spec-driven\nskip_specs: true\n' > "$(c)/.openspec.yaml"; rm -r "$(c)/specs"
            expect "gates: a change with no side runs only openspec validate" 0 "Result: 1 passed, 0 failed, 0 unrunnable" rg
fi

if section spec && [ -f "$skills/sdd-spec/scripts/check-spec.sh" ]; then
  echo "== check-spec"
  new_change;  expect "spec: valid example passes" 0 "Result: 0 error(s)" $spec
  new_change;  sed -i 's/AC-2 Name of an inactive/AC-1 Name of an inactive/' "$(c)/specs/configuration-management/spec.md"
               expect "spec: duplicate AC numbers" 1 "duplicate AC numbers" $spec
  new_change;  sed -i '0,/^\*\*Side:\*\* BE$/{//d}' "$(c)/specs/configuration-management/spec.md"
               expect "spec: scenario without Side" 1 "has no **Side:** line" $spec
fi

if section adr; then
echo "== check-adr"
a() { echo "$work/adr/openspec/adr"; }
mk_adr() { # <nnnn> <slug> <status> <area> [supersedes]
  { printf '# ADR-%s: %s\n\n**Status:** %s\n**Date:** 2026-10-26\n**Area:** %s\n**Change:** none\n' "$1" "$2" "$3" "$4"
    [ -n "${5:-}" ] && printf '**Supersedes:** %s\n' "$5"
    printf '\n## Context\n\nx\n\n## Decision\n\nx\n\n## Alternatives\n\n- x\n\n## Consequences\n\n- x\n'; } > "$(a)/$1-$2.md"
}
row() { printf '| [ADR-%s](%s-%s.md) | %s | %s | %s |\n' "$1" "$1" "$2" "$2" "$3" "${4:-—}" >> "$(a)/README.md"; }
summ() { printf '### [ADR-%s](%s-%s.md): %s\nRule: x\n\n' "$1" "$1" "$2" "$2" >> "$(a)/SUMMARY.md"; }
sign() { sed -i "s/^\*\*Change:\*\* none/**Change:** none\n**Reviewed by:** r (2026-10-30)\n**Signed by:** s (2026-10-30)/" "$(a)/$1"; }
new_adr_root() {
  rm -rf "$work/adr"
  mkdir -p "$work/adr/openspec/adr" "$work/adr/openspec/changes/$id"
  printf '# ADRs\n\n## Index\n\n### process\n\n| ADR | Title | Status | Superseded by |\n|---|---|---|---|\n' > "$(a)/README.md"
  printf '# Summary\n\n## process\n\n' > "$(a)/SUMMARY.md"
  mk_adr 0001 use-openspec Proposed process
  row 0001 use-openspec Proposed
  cd "$work/adr" || exit 1
}
adrc="bash $skills/sdd-adr/scripts/check-adr.sh"
supersede_0001() { # ADR-0002 <status> supersedes ADR-0001; the old one marked superseded when $2 = done
  mk_adr 0002 use-other "$1" process ADR-0001; row 0002 use-other "$1"
  [ "$1" = Accepted ] && summ 0002 use-other
  if [ "${2:-}" = done ]; then
    sed -i 's/^\*\*Status:\*\* Proposed/**Status:** Superseded by ADR-0002/' "$(a)/0001-use-openspec.md"
    sed -i 's/| use-openspec | Proposed | — |/| use-openspec | Superseded | ADR-0002 |/' "$(a)/README.md"
  fi
}

new_adr_root; expect "adr: valid folder passes" 0 "Result: 0 error(s)" $adrc
new_adr_root; cp "$(a)/0001-use-openspec.md" "$(a)/0001-use-other.md"
              expect "adr: number used twice" 1 "number used twice" $adrc
new_adr_root; mk_adr 0003 skipped Proposed process; row 0003 skipped Proposed
              expect "adr: numbering gap" 1 "expected ADR-0002, found ADR-0003" $adrc
new_adr_root; mk_adr 0002 Bad_Name Proposed process
              expect "adr: bad file name" 1 "file name must be" $adrc
new_adr_root; sed -i '/^## Consequences$/d' "$(a)/0001-use-openspec.md"
              expect "adr: missing section" 1 "no '## Consequences'" $adrc
new_adr_root; sed -i 's/^\*\*Status:\*\* Proposed/**Status:** Done/' "$(a)/0001-use-openspec.md"
              expect "adr: bad status" 1 "Status 'Done'" $adrc
new_adr_root; sed -i 's/^\*\*Area:\*\* process/**Area:** process, mobile/' "$(a)/0001-use-openspec.md"
              expect "adr: bad area" 1 "Area 'mobile'" $adrc
new_adr_root; sed -i '/ADR-0001/d' "$(a)/README.md"
              expect "adr: ADR missing from the index" 1 "ADR-0001 has no row" $adrc
new_adr_root; row 0002 ghost Proposed
              expect "adr: index row without a file" 1 "row for ADR-0002, which has no file" $adrc
new_adr_root; sed -i 's/^\*\*Status:\*\* Proposed/**Status:** Accepted/' "$(a)/0001-use-openspec.md"
              expect "adr: index status out of sync" 1 "shows status 'Proposed', the file says 'Accepted'" $adrc
new_adr_root; mk_adr 0002 backend-thing Proposed backend; row 0002 backend-thing Proposed
              expect "adr: row under the wrong area" 1 "expected '### backend'" $adrc
new_adr_root; supersede_0001 Accepted
              expect "adr: one-way supersede" 1 "ADR-0001 is not 'Superseded by ADR-0002'" $adrc
new_adr_root; supersede_0001 Accepted done
              expect "adr: two-way supersede passes" 0 "Result: 0 error(s)" $adrc
new_adr_root; supersede_0001 Proposed
              expect "adr: proposed superseder leaves the old one alone" 0 "Result: 0 error(s)" $adrc
new_adr_root; supersede_0001 Proposed done
              expect "adr: superseded by an ADR not yet Accepted" 1 "which is not Accepted" $adrc
new_adr_root; printf '### D1. x\n**ADR:** ADR-0001\n' > "openspec/changes/$id/design.md"
              expect "adr: --change with a Proposed ADR" 1 "must be Accepted" $adrc --change $id
new_adr_root; printf '### D1. x\n**ADR:** ADR-0009\n' > "openspec/changes/$id/design.md"
              expect "adr: --change with a missing ADR" 1 "ADR-0009, which does not exist" $adrc --change $id
new_adr_root; printf '### D1. x\n**ADR:** ADR-0001\n' > "openspec/changes/$id/design.md"
              sed -i 's/Proposed/Accepted/' "$(a)/0001-use-openspec.md" "$(a)/README.md"; summ 0001 use-openspec
              expect "adr: --change with an Accepted ADR passes" 0 "Result: 0 error(s)" $adrc --change $id
new_adr_root; sed -i 's/$/\r/' "$(a)/0001-use-openspec.md" "$(a)/README.md"
              expect "adr: CRLF files still pass" 0 "Result: 0 error(s)" $adrc
git_commit_all() { git init -q . && git -c core.autocrlf=false add -A && git -c user.name=t -c user.email=t@t commit -qm fixture; }
new_adr_root; git_commit_all; mk_adr 0002 new-for-change Proposed process
              sed -i "s/^\*\*Change:\*\* none/**Change:** $id/" "$(a)/0002-new-for-change.md"; row 0002 new-for-change Proposed
              expect "adr: --change warns about an uncommitted ADR" 0 "0002-new-for-change.md is untracked or has uncommitted changes" $adrc --change $id
new_adr_root; printf '### D1. x\n**ADR:** ADR-0001\n' > "openspec/changes/$id/design.md"
              sed -i 's/Proposed/Accepted/' "$(a)/0001-use-openspec.md" "$(a)/README.md"; summ 0001 use-openspec; sign 0001-use-openspec.md; git_commit_all
              expect "adr: --change with everything committed has no warning" 0 "Result: 0 error(s), 0 warning(s)" $adrc --change $id
# ADR-0006: review and sign-off, and SUMMARY.md
accept_0001() { sed -i 's/Proposed/Accepted/' "$(a)/0001-use-openspec.md" "$(a)/README.md"; }
new_adr_root; rm "$(a)/SUMMARY.md"
              expect "adr: SUMMARY.md is missing" 1 "SUMMARY.md is missing" $adrc
new_adr_root; expect "adr: SUMMARY.md next to the ADRs is not parsed as an ADR" 0 "Result: 0 error(s)" $adrc
new_adr_root; accept_0001
              expect "adr: Accepted ADR missing from SUMMARY.md" 1 "SUMMARY.md: ADR-0001 has no entry" $adrc
new_adr_root; summ 0001 use-openspec
              expect "adr: SUMMARY.md entry for a Proposed ADR" 1 "SUMMARY.md: ADR-0001 is not Accepted" $adrc
new_adr_root; accept_0001; summ 0001 use-openspec; summ 0009 ghost
              expect "adr: SUMMARY.md entry without a file" 1 "SUMMARY.md: entry for ADR-0009, which has no file" $adrc
new_adr_root; accept_0001; summ 0001 use-openspec; sed -i 's/^## process/## backend/' "$(a)/SUMMARY.md"
              expect "adr: SUMMARY.md entry under the wrong area" 1 "SUMMARY.md: ADR-0001 is under '## backend'" $adrc
new_adr_root; accept_0001; summ 0001 use-openspec; sed -i 's/^\*\*Date:\*\* 2026-10-26/**Date:** 2026-10-30/' "$(a)/0001-use-openspec.md"
              expect "adr: new Accepted ADR without sign-off fails" 1 "no '**Signed by:**' value" $adrc
new_adr_root; accept_0001; summ 0001 use-openspec
              expect "adr: older Accepted ADR without sign-off only warns" 0 "no '**Signed by:**' value" $adrc
new_adr_root; accept_0001; summ 0001 use-openspec; sed -i 's/^\*\*Date:\*\* 2026-10-26/**Date:** 2026-10-30/' "$(a)/0001-use-openspec.md"; sign 0001-use-openspec.md
              expect "adr: new Accepted ADR with sign-off passes" 0 "Result: 0 error(s)" $adrc
cd "$skills/../.." || exit 1
expect "adr: the real ADRs pass" 0 "Result: 0 error(s)" $adrc
fi

if section archive; then
echo "== check-archive"
archc="bash $skills/sdd-archive/scripts/check-archive.sh $id"
ready_change() {
  new_change
  sed -i 's/^- \[ \]/- [x]/' "$(c)/tasks.md"
  printf '\n## Validation log\n\n- Verified 2026-10-27: no gaps, no drift, gates green\n' >> "$(c)/proposal.md"
}
ready_change; expect "archive: verified change passes" 0 "Result: 0 error(s)" $archc
ready_change; sed -i '0,/^- \[x\]/s//- [ ]/' "$(c)/tasks.md"
              expect "archive: unchecked task" 1 "unchecked task" $archc
ready_change; printf -- '- [ ] ~~9.9~~ (replaced by 1.1)\n' >> "$(c)/tasks.md"
              expect "archive: struck-through task is ignored" 0 "Result: 0 error(s)" $archc
ready_change; sed -i '/^- Verified /d' "$(c)/proposal.md"
              expect "archive: no Verified line" 1 "no 'Verified <date>' line" $archc
ready_change; printf '\n## Clarifications\n\n- Verified 2026-10-27 is not here\n' >> "$(c)/proposal.md"; sed -i '/^- Verified 2026-10-27: /d' "$(c)/proposal.md"
              expect "archive: Verified outside the Validation log" 1 "no 'Verified <date>' line" $archc
ready_change; mkdir -p openspec/adr
              printf '# ADR-0001: x\n\n**Status:** Proposed\n**Date:** 2026-10-27\n**Area:** process\n**Change:** none\n\n## Context\n\n## Decision\n\n## Alternatives\n\n## Consequences\n' > openspec/adr/0001-x.md
              printf '# ADRs\n\n### process\n\n| [ADR-0001](0001-x.md) | x | Proposed | — |\n' > openspec/adr/README.md
              printf '\n**ADR:** ADR-0001\n' >> "$(c)/design.md"
              expect "archive: linked ADR not Accepted" 1 "must be Accepted" $archc
fi

if section skills; then
echo "== check-skills"
new_skills_root() {
  rm -rf "$work/sk"
  mkdir -p "$work/sk/.claude/skills/sdd-a/scripts"
  printf '#!/bin/sh\n' > "$work/sk/.claude/skills/sdd-a/scripts/x.sh"
  printf -- '---\nname: sdd-a\ndescription: test skill\nallowed-tools: Bash(bash .claude/skills/sdd-a/scripts/x.sh:*)\n---\nBody cites `.claude/skills/sdd-a/scripts/x.sh`.\n' > "$work/sk/.claude/skills/sdd-a/SKILL.md"
  printf 'AGENTS\n| `/sdd-a` | test |\n## 8. Workflow\n### 8.7 Done\n' > "$work/sk/AGENTS.md"
}
skill_file() { echo "$work/sk/.claude/skills/sdd-a/SKILL.md"; }
sk() { bash "$skills/sdd-plan/tests/check-skills.sh" "$work/sk"; }

new_skills_root; expect "skills: aligned skill passes" 0 "Result: 0 error(s)" sk
new_skills_root; sed -i 's/^name: sdd-a/name: sdd-b/' "$(skill_file)"
                 expect "skills: name must equal the folder" 1 "frontmatter name" sk
new_skills_root; printf 'Cites `.claude/skills/sdd-a/templates/missing.md`.\n' >> "$(skill_file)"
                 expect "skills: dangling path" 1 "does not exist" sk
new_skills_root; printf 'Run the gates of AGENTS.md §8.7 (see §8 and section 8.7).\n' >> "$(skill_file)"
                 expect "skills: cited AGENTS.md sections exist" 0 "Result: 0 error(s)" sk
new_skills_root; printf 'Run the gates of AGENTS.md §5.6.\n' >> "$(skill_file)"
                 expect "skills: stale AGENTS.md section" 1 "cites AGENTS.md section 5.6" sk
new_skills_root; mkdir -p "$work/sk/.claude/skills/sdd-a/templates"; printf 'Gates (AGENTS.md section 4.2)\n' > "$work/sk/.claude/skills/sdd-a/templates/t.md"
                 expect "skills: stale section in a template" 1 "cites AGENTS.md section 4.2" sk
new_skills_root; printf 'If `ERAS-FE/.claude/skills/eras-fe-test/SKILL.md` exists, follow it.\n' >> "$(skill_file)"
                 expect "skills: optional path is allowed" 0 "Result: 0 error(s)" sk
new_skills_root; printf 'Update the row in specs/README.md.\n' >> "$(skill_file)"
                 expect "skills: legacy specs/README" 1 "specs/README" sk
new_skills_root; printf -- '- [ ] T-3 Fix the thing\n' >> "$(skill_file)"
                 expect "skills: legacy T-n task ids" 1 "T-n task ids" sk
new_skills_root; printf 'Read `plan.md` first.\n' >> "$(skill_file)"
                 expect "skills: plan.md as an artifact" 1 "plan.md without design.md" sk
new_skills_root; printf 'Set the status to "Implemented".\n' >> "$(skill_file)"
                 expect "skills: Implemented status" 1 "Implemented status" sk
new_skills_root; printf 'There is no `Implemented` status to set.\n' >> "$(skill_file)"
                 expect "skills: negated Implemented is allowed" 0 "Result: 0 error(s)" sk
new_skills_root; printf 'AGENTS\n' > "$work/sk/AGENTS.md"
                 expect "skills: skill missing from AGENTS.md" 1 "not documented in AGENTS.md" sk
new_skills_root; rm "$work/sk/.claude/skills/sdd-a/scripts/x.sh"
                 expect "skills: allowed-tools script missing" 1 "allowed-tools names" sk
expect "skills: the real skills pass" 0 "Result: 0 error(s)" bash "$skills/sdd-plan/tests/check-skills.sh"
fi

echo
echo "passed: $passed  failed: $failed"
[ "$failed" -eq 0 ]
