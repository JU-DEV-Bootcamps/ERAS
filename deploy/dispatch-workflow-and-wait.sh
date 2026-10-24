#!/bin/bash
# Dispatches a workflow_dispatch workflow in another repository and waits for that exact run to finish,
# tolerating transient network failures.
#
# Usage: GH_TOKEN=<token> dispatch-workflow-and-wait.sh <owner/repo> <workflow-file> <payload-json> [tag-output-file]
# payload-json is the dispatch body: {"ref": "<branch>", "inputs": {...}}
# When tag-output-file is given, the image tag published by the run (annotation titled "eras-image-tag" on its
# "package" job) is written to that file once the run succeeds.

set -euo pipefail

REPO=${1:?usage: dispatch-workflow-and-wait.sh <owner/repo> <workflow-file> <payload-json> [tag-output-file]}
WORKFLOW=${2:?usage: dispatch-workflow-and-wait.sh <owner/repo> <workflow-file> <payload-json> [tag-output-file]}
PAYLOAD=${3:?usage: dispatch-workflow-and-wait.sh <owner/repo> <workflow-file> <payload-json> [tag-output-file]}
TAG_OUTPUT=${4:-}
: "${GH_TOKEN:?GH_TOKEN is required}"

API=${GITHUB_API_URL:-https://api.github.com}
RETRIES=${RETRIES:-6}
RETRY_DELAY=${RETRY_DELAY:-5}
DISCOVER_TIMEOUT=${DISCOVER_TIMEOUT:-120}
DISCOVER_INTERVAL=${DISCOVER_INTERVAL:-5}
POLL_INTERVAL=${POLL_INTERVAL:-30}
MAX_POLL_FAILURES=${MAX_POLL_FAILURES:-10}
TOTAL_TIMEOUT=${TOTAL_TIMEOUT:-2700}
TAG_JOB=${TAG_JOB:-package}
TAG_TITLE=${TAG_TITLE:-eras-image-tag}
TAG_TIMEOUT=${TAG_TIMEOUT:-60}

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

REF=$(jq -r '.ref' <<< "$PAYLOAD")

urlencode() {
  local value=$1 i char encoded=""
  for ((i = 0; i < ${#value}; i++)); do
    char=${value:i:1}
    case $char in
      [a-zA-Z0-9.~_-]) encoded+=$char ;;
      *) encoded+=$(printf '%%%02X' "'$char") ;;
    esac
  done
  printf '%s' "$encoded"
}

RUNS_PATH="/repos/${REPO}/actions/workflows/${WORKFLOW}/runs?event=workflow_dispatch&branch=$(urlencode "$REF")&per_page=20"

gh_call() {
  local method=$1 path=$2 data=${3:-}
  local args=()
  if [ -n "$data" ]; then
    args=(-H 'Content-Type: application/json' --data "$data")
  fi
  CALL_RC=0
  CALL_CODE=$(curl --silent --show-error --max-time 30 --output "$TMP" --write-out '%{http_code}' \
    -X "$method" -H "Authorization: token ${GH_TOKEN}" -H 'Accept: application/vnd.github+json' \
    "${args[@]}" "${API}${path}") || CALL_RC=$?
  CALL_CODE=${CALL_CODE:-000}
}

is_permanent_error() {
  [ "$1" -ge 400 ] && [ "$1" -lt 500 ] && [ "$1" -ne 408 ] && [ "$1" -ne 429 ]
}

gh_api() {
  local method=$1 path=$2 data=${3:-}
  local attempt=1
  while true; do
    gh_call "$method" "$path" "$data"
    if [ "$CALL_RC" -eq 0 ] && [ "$CALL_CODE" -ge 200 ] && [ "$CALL_CODE" -lt 300 ]; then
      cat "$TMP"
      return 0
    fi
    if [ "$CALL_RC" -eq 0 ] && is_permanent_error "$CALL_CODE"; then
      echo "GitHub API ${method} ${path} failed with HTTP ${CALL_CODE}: $(head -c 300 "$TMP")" >&2
      return 22
    fi
    if [ "$attempt" -ge "$RETRIES" ]; then
      echo "GitHub API ${method} ${path} failed after ${attempt} attempts (curl exit ${CALL_RC}, HTTP ${CALL_CODE})" >&2
      return 1
    fi
    echo "GitHub API ${method} ${path} attempt ${attempt} failed (curl exit ${CALL_RC}, HTTP ${CALL_CODE}); retrying in ${RETRY_DELAY}s" >&2
    sleep "$RETRY_DELAY"
    attempt=$((attempt + 1))
  done
}

latest_run_id() {
  gh_api GET "$RUNS_PATH" | jq '[.workflow_runs[].id] | max // 0'
}

dispatch() {
  local attempt=1 latest
  while true; do
    gh_call POST "/repos/${REPO}/actions/workflows/${WORKFLOW}/dispatches" "$PAYLOAD"
    if [ "$CALL_RC" -eq 0 ] && [ "$CALL_CODE" -ge 200 ] && [ "$CALL_CODE" -lt 300 ]; then
      return 0
    fi
    if [ "$CALL_RC" -eq 0 ] && is_permanent_error "$CALL_CODE"; then
      echo "Dispatch of ${WORKFLOW} failed with HTTP ${CALL_CODE}: $(head -c 300 "$TMP")" >&2
      return 1
    fi
    latest=$(latest_run_id) || latest=$BEFORE
    if [ "$latest" -gt "$BEFORE" ]; then
      echo "The dispatch response was lost but the run exists; not dispatching again" >&2
      return 0
    fi
    if [ "$attempt" -ge "$RETRIES" ]; then
      echo "Dispatch of ${WORKFLOW} failed after ${attempt} attempts (curl exit ${CALL_RC}, HTTP ${CALL_CODE})" >&2
      return 1
    fi
    echo "Dispatch attempt ${attempt} failed (curl exit ${CALL_RC}, HTTP ${CALL_CODE}); retrying in ${RETRY_DELAY}s" >&2
    sleep "$RETRY_DELAY"
    attempt=$((attempt + 1))
  done
}

find_new_run() {
  local deadline=$((SECONDS + DISCOVER_TIMEOUT)) run_id
  while [ "$SECONDS" -lt "$deadline" ]; do
    run_id=$(gh_api GET "$RUNS_PATH" | jq --argjson before "$BEFORE" '[.workflow_runs[] | select(.id > $before) | .id] | min // empty') || run_id=""
    if [ -n "$run_id" ]; then
      echo "$run_id"
      return 0
    fi
    sleep "$DISCOVER_INTERVAL"
  done
  return 1
}

wait_for_run() {
  local run_id=$1
  local deadline=$((SECONDS + TOTAL_TIMEOUT)) failures=0 rc info status conclusion
  while [ "$SECONDS" -lt "$deadline" ]; do
    rc=0
    info=$(gh_api GET "/repos/${REPO}/actions/runs/${run_id}") || rc=$?
    if [ "$rc" -eq 0 ]; then
      failures=0
      status=$(jq -r '.status' <<< "$info")
      conclusion=$(jq -r '.conclusion // ""' <<< "$info")
      echo "Run ${run_id}: ${status} ${conclusion}"
      if [ "$status" = "completed" ]; then
        if [ "$conclusion" = "success" ]; then
          return 0
        fi
        echo "Run ${run_id} finished with conclusion '${conclusion}': https://github.com/${REPO}/actions/runs/${run_id}" >&2
        return 1
      fi
    elif [ "$rc" -eq 22 ]; then
      return 1
    else
      failures=$((failures + 1))
      echo "Could not read run ${run_id} (${failures}/${MAX_POLL_FAILURES} consecutive failures)" >&2
      if [ "$failures" -ge "$MAX_POLL_FAILURES" ]; then
        return 1
      fi
    fi
    sleep "$POLL_INTERVAL"
  done
  echo "Timed out after ${TOTAL_TIMEOUT}s waiting for run ${run_id}: https://github.com/${REPO}/actions/runs/${run_id}" >&2
  return 1
}

# GitHub replaces any text equal to a secret's value with *** in annotations. If some secret is a short value such as
# "1", every "1" in the commit sha becomes ***. Each *** stands for exactly one masked character of the sha, so the tag
# is rebuilt from the run's head_sha, checking that the visible characters match.
unmask_image_tag() {
  local run_id=$1 tag=$2
  local prefix suffix pattern head_sha candidate
  case $tag in
    *'***'*) ;;
    *) printf '%s' "$tag"; return 0 ;;
  esac
  prefix=${tag%-*}
  suffix=${tag##*-}
  pattern=${prefix//\*\*\*/?}
  head_sha=$(gh_api GET "/repos/${REPO}/actions/runs/${run_id}" | jq -r '.head_sha // empty') || head_sha=""
  candidate=${head_sha:0:${#pattern}}
  # shellcheck disable=SC2053
  if [ -z "$head_sha" ] || [[ $candidate != $pattern ]]; then
    echo "Image tag '${tag}' is masked and does not match the head sha of run ${run_id}" >&2
    return 1
  fi
  echo "Image tag was masked by a secret value; restored from the run head sha" >&2
  printf '%s-%s' "$candidate" "$suffix"
}

read_image_tag() {
  local run_id=$1 output_file=$2
  local deadline=$((SECONDS + TAG_TIMEOUT)) job_id tag
  while [ "$SECONDS" -lt "$deadline" ]; do
    job_id=$(gh_api GET "/repos/${REPO}/actions/runs/${run_id}/jobs?per_page=50" | jq -r --arg name "$TAG_JOB" '[.jobs[] | select(.name == $name) | .id] | .[0] // empty') || job_id=""
    if [ -n "$job_id" ]; then
      tag=$(gh_api GET "/repos/${REPO}/check-runs/${job_id}/annotations?per_page=50" | jq -r --arg title "$TAG_TITLE" '[.[] | select(.title == $title) | .message] | .[0] // empty') || tag=""
      if [ -n "$tag" ]; then
        tag=$(unmask_image_tag "$run_id" "$tag") || return 1
        printf '%s\n' "$tag" > "$output_file"
        echo "Image tag of ${REPO} run ${run_id}: ${tag}"
        return 0
      fi
    fi
    sleep "$DISCOVER_INTERVAL"
  done
  echo "Could not read the image tag annotation '${TAG_TITLE}' of job '${TAG_JOB}' in run ${run_id}" >&2
  return 1
}

BEFORE=$(latest_run_id)
echo "Dispatching ${WORKFLOW} in ${REPO} on ${REF}"
dispatch

RUN_ID=$(find_new_run) || {
  echo "The run dispatched in ${REPO} did not appear within ${DISCOVER_TIMEOUT}s" >&2
  exit 1
}
echo "Waiting for ${REPO} run ${RUN_ID}: https://github.com/${REPO}/actions/runs/${RUN_ID}"
wait_for_run "$RUN_ID"
echo "${REPO} run ${RUN_ID} completed successfully"

if [ -n "$TAG_OUTPUT" ]; then
  read_image_tag "$RUN_ID" "$TAG_OUTPUT"
fi
