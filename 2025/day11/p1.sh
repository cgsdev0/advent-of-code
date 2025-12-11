#!/bin/bash

. ../../misc/vardump

FILE="$1"

declare -A graph
declare -A visited

count=0
function dfs() {
  local start=$1
  local depth=$2
  printf "%${depth}s" 1>&2
  printf "%s\n" "$start" 1>&2
  if [[ "$start" == "out" ]]; then
    ((count++))
    return
  fi
  local -a conns=(${graph[$start]})
  local i
  for ((i=0;i<${#conns[@]};++i)); do
    dfs "${conns[i]}" "$((depth+1))"
  done
}

load_the_cannon() {
  while IFS= read -r line; do
    eval "$line"
  done
  dfs "you" "0"
  echo $count

  # while [[ ${#q[@]} -gt 0 ]]; do
  #   len=${#q[@]}
  #   next="${q[len-1]}"
  #   q=("${q[@]:0:len-1}")
  #   [[ -n "${visited[$next]}" ]] && continue
  #   echo "visiting $next"
  #   visited[$next]=1
  #   q+=(${graph[$next]})
  # done
}

cat "$FILE" \
  | sed 's/^/graph[/;s/: /]="/;s/$/"/' \
  | load_the_cannon
