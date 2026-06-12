#!/usr/bin/env bash

FILE=edges.txt

declare -A graph
function add_edge() {
  local key=$1
  local val=$2
  if [[ -z "${graph[$key]}" ]]; then
    graph[$key]=$val
  else
    graph[$key]="${graph[$key]}
$val"
  fi
}
while read key val; do
  [[ "$key" == "" ]] && continue
  add_edge $key $val
  add_edge $val $key
done < <(cat $FILE \
| tr -d '-')

function traverse() {
  counter=0
  local -A visited=()
  local -a queue=("$1")
  while [[ ${#queue[@]} -gt 0 ]]; do
    item=${queue[0]}
    queue=("${queue[@]:1}")
    if [[ ! -z "${visited[$item]}" ]]; then
      continue
    fi
    visited[$item]=1
    ((counter++))
    while read edge; do
      [[ "$edge" == "" ]] && continue
      queue+=("$edge")
    done <<< "${graph[$item]}"
  done
  echo $counter
}
(traverse xnn;
traverse txf) \
  | paste -sd* | bc
