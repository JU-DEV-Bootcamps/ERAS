#!/usr/bin/env bash
# Self-test of the SDD check scripts (check-spec, check-plan, check-impl) against fixtures built from the worked examples.
# Usage (any directory): bash .claude/skills/sdd-plan/tests/run-tests.sh
# Exit 0 = every case behaved as expected.
set -u

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
new_change;  sed -i 's/ (AGENTS.md section 5.6)//' "$(c)/tasks.md"
             expect "plan: verification must cite 5.6" 1 "5.6" $plan
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

if [ -f "$skills/sdd-spec/scripts/check-spec.sh" ]; then
  echo "== check-spec"
  new_change;  expect "spec: valid example passes" 0 "Result: 0 error(s)" $spec
  new_change;  sed -i 's/AC-2 Name of an inactive/AC-1 Name of an inactive/' "$(c)/specs/configuration-management/spec.md"
               expect "spec: duplicate AC numbers" 1 "duplicate AC numbers" $spec
  new_change;  sed -i '0,/^\*\*Side:\*\* BE$/{//d}' "$(c)/specs/configuration-management/spec.md"
               expect "spec: scenario without Side" 1 "has no **Side:** line" $spec
fi

echo
echo "passed: $passed  failed: $failed"
[ "$failed" -eq 0 ]
