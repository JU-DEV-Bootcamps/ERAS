#!/bin/bash
# Tests for deploy/dispatch-workflow-and-wait.sh using a fake curl. Run: bash deploy/tests/dispatch-workflow-and-wait.test.sh

TESTS_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SCRIPT="$TESTS_DIR/../dispatch-workflow-and-wait.sh"
SUPPORT="$TESTS_DIR/support"

if command -v jq >/dev/null 2>&1; then
  TOOLS_PATH="$SUPPORT/fake-bin:$PATH"
else
  TOOLS_PATH="$SUPPORT/fake-bin:$SUPPORT/jq-shim:$PATH"
fi

PAYLOAD='{"ref":"develop","inputs":{"branch":"develop"}}'
PASSED=0
FAILED=0
FAKE_DIR=""
OUTPUT=""
EXIT_CODE=0

new_scenario() {
  FAKE_DIR=$(mktemp -d)
  TAG_FILE=""
  : > "$FAKE_DIR/calls.log"
}

seq_file() {
  printf '%s\n' "${@:2}" > "$FAKE_DIR/$1.seq"
}

run_script() {
  OUTPUT=$(PATH="$TOOLS_PATH" FAKE_DIR="$FAKE_DIR" GH_TOKEN=test-token \
    RETRY_DELAY=0 DISCOVER_INTERVAL=0 POLL_INTERVAL=0 "$@" \
    bash "$SCRIPT" owner/repo workflow.yml "$PAYLOAD" ${TAG_FILE:+"$TAG_FILE"} 2>&1)
  EXIT_CODE=$?
}

count_calls() {
  grep -c "$1" "$FAKE_DIR/calls.log" || true
}

check() {
  local name=$1 condition=$2
  if eval "$condition"; then
    PASSED=$((PASSED + 1))
    echo "PASS  $name"
  else
    FAILED=$((FAILED + 1))
    echo "FAIL  $name"
    echo "      exit=$EXIT_CODE condition: $condition"
    echo "$OUTPUT" | sed 's/^/      | /'
  fi
}

RUNS_OLD='0|200|{"workflow_runs":[{"id":100}]}'
RUNS_NEW='0|200|{"workflow_runs":[{"id":101},{"id":100}]}'
RUN_IN_PROGRESS='0|200|{"status":"in_progress","conclusion":null}'
RUN_SUCCESS='0|200|{"status":"completed","conclusion":"success"}'
RUN_FAILURE='0|200|{"status":"completed","conclusion":"failure"}'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_IN_PROGRESS" "$RUN_SUCCESS"
run_script env
check "happy path: dispatches once and returns success" '[ "$EXIT_CODE" -eq 0 ] && [ "$(count_calls "POST ")" -eq 1 ]'
check "happy path: waits for the new run id" 'echo "$OUTPUT" | grep -q "run 101"'
check "happy path: does not read any tag when none is requested" '[ "$(count_calls annotations)" -eq 0 ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_OLD" "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '35||' '18||' '0|204|'
seq_file run '56||' "$RUN_SUCCESS"
run_script env RETRIES=3 MAX_POLL_FAILURES=3
check "network failures (curl 35 and 18) are retried until the dispatch works" '[ "$EXIT_CODE" -eq 0 ] && [ "$(count_calls "POST ")" -eq 3 ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '18||'
seq_file run "$RUN_SUCCESS"
run_script env
check "a lost dispatch response does not dispatch a second run" '[ "$EXIT_CODE" -eq 0 ] && [ "$(count_calls "POST ")" -eq 1 ]'

new_scenario
seq_file list "$RUNS_OLD"
seq_file dispatch '0|404|{"message":"Not Found"}'
run_script env
check "a permanent HTTP error fails without retrying" '[ "$EXIT_CODE" -ne 0 ] && [ "$(count_calls "POST ")" -eq 1 ] && echo "$OUTPUT" | grep -q "HTTP 404"'

new_scenario
seq_file list "$RUNS_OLD"
seq_file dispatch '35||'
run_script env RETRIES=2
check "dispatch gives up after the configured attempts" '[ "$EXIT_CODE" -ne 0 ] && [ "$(count_calls "POST ")" -eq 2 ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_FAILURE"
run_script env
check "a failed run fails the script and prints its url" '[ "$EXIT_CODE" -ne 0 ] && echo "$OUTPUT" | grep -q "github.com/owner/repo/actions/runs/101"'

new_scenario
seq_file list "$RUNS_OLD"
seq_file dispatch '0|204|'
run_script env DISCOVER_TIMEOUT=2 DISCOVER_INTERVAL=1
check "an older completed run is never mistaken for the new one" '[ "$EXIT_CODE" -ne 0 ] && echo "$OUTPUT" | grep -q "did not appear"'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_IN_PROGRESS"
run_script env TOTAL_TIMEOUT=2 POLL_INTERVAL=1
check "waiting for a run that never finishes times out" '[ "$EXIT_CODE" -ne 0 ] && echo "$OUTPUT" | grep -q "Timed out"'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run '35||' '35||' '35||' "$RUN_SUCCESS"
run_script env RETRIES=1 MAX_POLL_FAILURES=5
check "isolated polling failures do not fail the deploy" '[ "$EXIT_CODE" -eq 0 ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run '35||'
run_script env RETRIES=1 MAX_POLL_FAILURES=3
check "too many consecutive polling failures fail the deploy" '[ "$EXIT_CODE" -ne 0 ] && echo "$OUTPUT" | grep -q "3/3"'

new_scenario
seq_file list '0|200|{"workflow_runs":[]}' '0|200|{"workflow_runs":[{"id":7}]}'
seq_file dispatch '0|204|'
seq_file run "$RUN_SUCCESS"
run_script env
check "a workflow with no previous runs is handled" '[ "$EXIT_CODE" -eq 0 ] && echo "$OUTPUT" | grep -q "run 7"'

JOBS_PACKAGE='0|200|{"jobs":[{"id":556,"name":"coverage"},{"id":555,"name":"package"}]}'
TAG_ANNOTATIONS='0|200|[{"title":"other","message":"ignored"},{"title":"eras-image-tag","message":"1fe615f4-dev"}]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_SUCCESS"
seq_file jobs "$JOBS_PACKAGE"
seq_file annotations "$TAG_ANNOTATIONS"
TAG_FILE="$FAKE_DIR/tag.txt"
run_script env
check "the image tag is written to the requested file" '[ "$EXIT_CODE" -eq 0 ] && [ "$(cat "$TAG_FILE")" = "1fe615f4-dev" ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_SUCCESS"
seq_file jobs '0|200|{"jobs":[]}' "$JOBS_PACKAGE"
seq_file annotations '0|200|[]' "$TAG_ANNOTATIONS"
TAG_FILE="$FAKE_DIR/tag.txt"
run_script env
check "the image tag is awaited until the annotation appears" '[ "$EXIT_CODE" -eq 0 ] && [ "$(cat "$TAG_FILE")" = "1fe615f4-dev" ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_SUCCESS"
seq_file jobs "$JOBS_PACKAGE"
seq_file annotations '0|200|[]'
TAG_FILE="$FAKE_DIR/tag.txt"
run_script env TAG_TIMEOUT=2 DISCOVER_INTERVAL=1
check "a run without the tag annotation fails" '[ "$EXIT_CODE" -ne 0 ] && echo "$OUTPUT" | grep -q "image tag annotation" && [ ! -s "$TAG_FILE" ]'

new_scenario
seq_file list "$RUNS_OLD" "$RUNS_NEW"
seq_file dispatch '0|204|'
seq_file run "$RUN_FAILURE"
seq_file jobs "$JOBS_PACKAGE"
seq_file annotations "$TAG_ANNOTATIONS"
TAG_FILE="$FAKE_DIR/tag.txt"
run_script env
check "the tag is not read from a failed run" '[ "$EXIT_CODE" -ne 0 ] && [ "$(count_calls annotations)" -eq 0 ]'

echo
echo "$PASSED passed, $FAILED failed"
[ "$FAILED" -eq 0 ]
