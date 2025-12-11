#!/bin/bash

. ../../misc/vardump

FILE="$1"

declare -A graph

load_the_cannon() {
  while IFS= read -r line; do
    eval "$line"
  done
  for key in "${!graph[@]}"; do
    conns=(${graph[$key]})
    for ((i=0;i<${#conns[@]};++i)); do
      echo "$key -> ${conns[i]}"
    done
  done
}

cat "$FILE" \
  | sed 's/^/graph[/;s/: /]="/;s/$/"/' \
  | load_the_cannon
