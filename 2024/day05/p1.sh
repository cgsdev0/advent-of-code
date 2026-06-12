#!/usr/bin/env bash

FILE="$1"

declare -A deps

parse_rule() {
  IFS='|' read a b <<< "$line"
  if [[ -n "${deps[$b]}" ]]; then
    a="${deps[$b]} $a"
  fi
  deps[$b]="$a"
}

split() {
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

parse_update() {
  local -a arr violations
  local invalid
  split "$line" ,
  local -a pages=("${arr[@]}")
  for page in "${pages[@]}"; do
    split "${deps[$page]}" ' '
    for v in "${violations[@]}"; do
      if [[ "$v" == "$page" ]]; then
        invalid=yes
      fi
    done
    violations+=("${arr[@]}")
  done
  [[ -z "$invalid" ]] && echo "${pages[@]}"
}

middle() {
  awk '{print $((NF+1)/2)}'
}

main() {
  while read line; do
      test -z "$line" && break
      parse_rule
  done

  while read line; do
      parse_update
  done
}

sum() {
  paste -sd+ | bc
}

main < "$FILE" \
  | middle \
  | sum
