#!/usr/bin/env bash

declare -A grid

FILE=sample2.txt
size=$(wc -l < $FILE | cut -d' ' -f2)

load_grid() {
  r=0
  while IFS= read -r line; do
    c=0
    while read -n1 char; do
      grid["$r,$c"]=$char
      ((c++))
    done <<< "$line"
    ((r++))
  done < $FILE
}

n=$1
m=$((n / 2))
function print_grid() {
  for ((r=0; r<size; r++)); do
    for ((j=0; j<n; j++)); do
      for ((c=0; c<size; c++)); do
        char="${grid["$r,$c"]}"
        if [[ $char == "S" ]]; then
          if [[ $j -ne $m ]] || [[ $1 -ne $m ]]; then
            char=.
          fi
        fi
        echo -n $char
      done
    done
    echo
  done
}
load_grid
for((i=0; i<n; i++)); do
  print_grid $i
done
