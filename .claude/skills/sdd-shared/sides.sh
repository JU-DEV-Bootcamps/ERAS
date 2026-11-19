# Reader of the SDD side registry, openspec/sides.conf (ADR-0011). Sourced by the check scripts, never run alone:
#   . "$(dirname "$0")/../../sdd-shared/sides.sh"
# The scripts run from the repository root, so the registry path is relative to it; SIDES_CONF overrides it.
# A side is matched by its whole name: "FE" never matches "FE-React".

SIDES_CONF="${SIDES_CONF:-openspec/sides.conf}"

# The registry is read once, when this file is sourced, into _SIDES_ORDER (names in file order), _SIDES_VAL
# ("<side>|<key>" -> value) and _SIDES_GATES (<side> -> "<name><TAB><command>" lines in file order).
declare -gA _SIDES_VAL=() _SIDES_GATES=()
_SIDES_ORDER=""
if [ -f "$SIDES_CONF" ]; then
  _sides_cur=""
  while IFS= read -r _sides_line || [ -n "$_sides_line" ]; do
    _sides_line="${_sides_line%$'\r'}"
    _sides_line="${_sides_line#"${_sides_line%%[![:space:]]*}"}"
    case "$_sides_line" in
      ''|'#'*) continue ;;
    esac
    if [[ "$_sides_line" =~ ^\[([^]]*)\][[:space:]]*$ ]]; then
      _sides_cur="${BASH_REMATCH[1]}"
      _SIDES_ORDER="${_SIDES_ORDER:+$_SIDES_ORDER$'\n'}$_sides_cur"
      continue
    fi
    [ -n "$_sides_cur" ] || continue
    case "$_sides_line" in *=*) ;; *) continue ;; esac
    _sides_k="${_sides_line%%=*}"; _sides_v="${_sides_line#*=}"
    _sides_k="${_sides_k#"${_sides_k%%[![:space:]]*}"}"; _sides_k="${_sides_k%"${_sides_k##*[![:space:]]}"}"
    _sides_v="${_sides_v#"${_sides_v%%[![:space:]]*}"}"; _sides_v="${_sides_v%"${_sides_v##*[![:space:]]}"}"
    _SIDES_VAL["$_sides_cur|$_sides_k"]="$_sides_v"
    if [[ "$_sides_k" == gate.* ]]; then
      _SIDES_GATES["$_sides_cur"]+="${_sides_k#gate.}"$'\t'"$_sides_v"$'\n'
    fi
  done < "$SIDES_CONF"
  unset _sides_cur _sides_line _sides_k _sides_v
fi

# sides_ok: the registry exists
sides_ok() { [ -f "$SIDES_CONF" ]; }

# sides_list: the side names, in file order
sides_list() { [ -n "$_SIDES_ORDER" ] && printf '%s\n' "$_SIDES_ORDER"; return 0; }

# sides_has <name>: the name is a registered side
sides_has() { [ -n "$1" ] && [[ $'\n'"$_SIDES_ORDER"$'\n' == *$'\n'"$1"$'\n'* ]]; }

# sides_get <side> <key>: the value of one key, empty when the key is missing
sides_get() { printf '%s\n' "${_SIDES_VAL["$1|$2"]:-}"; }

# sides_gates <side>: one line per gate, "<name><TAB><command>", in file order
sides_gates() { printf '%s' "${_SIDES_GATES["$1"]:-}"; }

# sides_dir <side>: the side's test folder, from the repository root
sides_dir() { echo "$(sides_get "$1" submodule)/$(sides_get "$1" tests)"; }

# sides_split <value>: the parts of a **Side:** value ("BE + FE"), one per line
sides_split() {
  printf '%s\n' "$1" | tr -d '\r' | awk '{
    n = split($0, p, / \+ /)
    for (i = 1; i <= n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", p[i]); if (p[i] != "") print p[i] }
  }'
}

# sides_check <value>: prints why a **Side:** value is not valid and returns 1; prints nothing for a valid one.
# Valid = one or more registered sides, each once, joined by " + ".
sides_check() {
  local value parts part joined="" seen=""
  value=$(printf '%s' "$1" | tr -d '\r' | sed 's/[[:space:]]*$//')
  parts=$(sides_split "$value")
  if [ -z "$parts" ]; then echo "names no side"; return 1; fi
  while IFS= read -r part; do
    if ! sides_has "$part"; then echo "names '$part', which is not a side of $SIDES_CONF ($(sides_list | paste -sd, - | sed 's/,/, /g'))"; return 1; fi
    case " $seen " in *" $part "*) echo "names '$part' twice"; return 1 ;; esac
    seen="$seen $part"
    joined="${joined:+$joined + }$part"
  done <<< "$parts"
  if [ "$joined" != "$value" ]; then echo "must join the sides with ' + ' (expected '$joined')"; return 1; fi
  return 0
}

# sides_of_specs <spec.md>...: "AC-<n>|<side>" for every side of every scenario
sides_of_specs() {
  local f
  for f in "$@"; do
    [ -f "$f" ] || continue
    tr -d '\r' < "$f" | awk '
      /^#### Scenario: AC-[0-9]+ / { key = $3 }
      /^\*\*Side:\*\* / {
        side = $0; sub(/^\*\*Side:\*\* /, "", side)
        n = split(side, p, / \+ /)
        for (i = 1; i <= n; i++) { gsub(/^[[:space:]]+|[[:space:]]+$/, "", p[i]); if (p[i] != "") print key "|" p[i] }
      }'
  done
}

# sides_grep <side> <grep options and pattern>: grep -r over the side's test files; nothing when the folder is missing
sides_grep() {
  local side="$1" dir inc args=() incs=()
  shift
  dir=$(sides_dir "$side")
  [ -d "$dir" ] || return 1
  read -r -a incs <<< "$(sides_get "$side" include)"
  for inc in "${incs[@]}"; do args+=("--include=$inc"); done
  grep -r "${args[@]}" "$@" "$dir" 2> /dev/null
}

# sides_count <side> <ac-key>: the number of tests that carry one AC key on one side
sides_count() {
  case "$(sides_get "$1" key)" in
    trait) sides_grep "$1" -F "[Trait(\"AC\", \"$2\")]" | wc -l | tr -d ' ' ;;
    title) sides_grep "$1" -F "[$2]" | grep -cF "it(" || true ;;
    *) echo 0 ;;
  esac
}

# sides_tags <side> <change-id>: the AC-<n> of the change tagged on one side, unique
sides_tags() {
  case "$(sides_get "$1" key)" in
    trait) sides_grep "$1" -hoE "Trait\(\"AC\", \"$2/AC-[0-9]+\"\)" | sort -u | sed -E 's/.*\/(AC-[0-9]+)".*/\1/' ;;
    title) sides_grep "$1" -hoE "it\(['\"\`]\[$2/AC-[0-9]+\]" | sort -u | sed -E 's/.*\/(AC-[0-9]+)\]$/\1/' ;;
  esac
}

# sides_tagged_files <side> <change-id>: the side's test files that carry a key of the change
sides_tagged_files() {
  case "$(sides_get "$1" key)" in
    trait) sides_grep "$1" -lF "$2/AC-" ;;
    title) sides_grep "$1" -lF "[$2/AC-" ;;
  esac
}

# sides_skip_label <side>: how a skipped test of the side is called in messages
sides_skip_label() { [ "$(sides_get "$1" key)" = trait ] && echo "skipped test" || echo "focused or skipped test"; }

# sides_article <side>: "a" or "an" before the side's name read as letters (a BE test, an FE test)
sides_article() { case "$1" in [AEFHILMNORSXaefhilmnorsx]*) echo an ;; *) echo a ;; esac; }
