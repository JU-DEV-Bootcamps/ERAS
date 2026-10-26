#!/usr/bin/env bash
# Consistency check of the sdd-* skills in .claude/skills/ against the OpenSpec layout of AGENTS.md section 3.3.
# Usage: bash .claude/skills/sdd-plan/tests/check-skills.sh [repo-root]   (default: the repository containing this script)
# Exit 0 = no errors. Exit 1 = at least one error.
set -u

root="${1:-$(cd "$(dirname "$0")/../../../.." && pwd)}"
skills="$root/.claude/skills"
agents="$root/AGENTS.md"
errors=0
err() { echo "ERROR: $*"; errors=$((errors + 1)); }

[ -d "$skills" ] || { echo "no .claude/skills under $root" >&2; exit 2; }

count=0
for dir in "$skills"/sdd-*/; do
  [ -f "${dir}SKILL.md" ] || continue
  name=$(basename "$dir")
  file="${dir}SKILL.md"
  text=$(tr -d '\r' < "$file")
  count=$((count + 1))

  fm_name=$(echo "$text" | sed -n '2,/^---$/{/^name:/p}' | head -1 | sed 's/^name: *//')
  [ "$fm_name" = "$name" ] || err "$name: frontmatter name is '$fm_name', expected '$name'"
  echo "$text" | sed -n '2,/^---$/p' | grep -q '^description:' || err "$name: frontmatter has no description"

  for p in $(echo "$text" | grep -oE '`(\.claude|ERAS-FE|ERAS-BE)/[A-Za-z0-9_./-]+\.(md|sh)`' | tr -d '`' | sort -u); do
    [ -e "$root/$p" ] && continue
    echo "$text" | grep -F "$p" | grep -qi 'if .*exist' && continue
    err "$name: cites '$p' which does not exist"
  done

  for p in $(echo "$text" | sed -n '2,/^---$/p' | grep '^allowed-tools:' | grep -oE 'bash \.claude/[A-Za-z0-9_./-]+\.sh' | sed 's/^bash //' | sort -u); do
    [ -e "$root/$p" ] || err "$name: allowed-tools names '$p' which does not exist"
  done

  echo "$text" | grep -q 'specs/README' && err "$name: mentions specs/README (no such index in ERAS)"
  echo "$text" | grep -qE '\bT-(n|[0-9]+)\b' && err "$name: uses T-n task ids (tasks are numbered <group>.<n>)"
  echo "$text" | grep -E 'plan\.md' | grep -vq 'design\.md' && err "$name: mentions plan.md without design.md (the plan is design.md)"
  echo "$text" | grep -E '["`]Implemented["`]' | grep -vqE '[Nn]o [^.]*Implemented' && err "$name: uses an Implemented status (done = ticked, traced, gates green, archived)"

  if [ -f "$agents" ]; then
    grep -qF "/$name" "$agents" || err "$name: is not documented in AGENTS.md (section 5.1 table)"
  fi
done

[ "$count" -gt 0 ] || err "no sdd-* skill found under $skills"
echo "skills checked: $count"
echo "Result: $errors error(s)"
[ "$errors" -eq 0 ]
