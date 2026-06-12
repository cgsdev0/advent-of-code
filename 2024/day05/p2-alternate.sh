#!/usr/bin/env bash

FILE="$1"

declare -A deps

parse_rule() {
  first="${1%%|*}"
  second="${1##*|}"
  if [[ -n "${deps[$second]}" ]]; then
    first="${deps[$second]} $first"
  fi
  deps[$second]="$first"
}

split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

is_valid() {
  local -a arr
  local -a violations
  split "$1" ,
  local -a pages=("${arr[@]}")
  for page in "${pages[@]}"; do
    split "${deps[$page]}" ' '
    for v in "${violations[@]}"; do
      if [[ "$v" == "$page" ]]; then
        return 1
      fi
    done
    violations+=("${arr[@]}")
  done
}

middle() {
  awk '{print $((NF+1)/2)}'
}

add_deps() {
  while IFS= read -r a; do
    for dep in ${deps[$a]}; do
      echo "$dep $a"
    done
  done
}

main() {
  # parse rules
  while IFS= read -r line; do
    [[ "$line" == "" ]] && break
      parse_rule "$line"
  done
  # parse updates
  while IFS= read -r line; do
      is_valid "$line" && continue
      <<< "$line" \
        tr ',' '\n' |
        add_deps |
        # TIL that tsort exists
        tsort |
        grep -E "^(${line//,/|})$" |
        paste -sd' '
  done
}

main < "$FILE" \
  | middle \
  | paste -sd+ \
  | bc
