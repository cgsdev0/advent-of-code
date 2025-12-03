#!/bin/bash

FILE="$1"

function find_two() {
  while read line; do
    len=${#line}
    max_v=0
    max_i=0
    for ((i=0; i<len-1; ++i)); do
      c=${line:i:1}
      if [[ c -gt max_v ]]; then
        max_v=$c
        max_i=$i
      fi
    done
    max_v2=0
    for ((i=max_i+1; i<len; ++i)); do
      c=${line:i:1}
      if [[ c -gt max_v2 ]]; then
        max_v2=$c
      fi
    done
    echo "$max_v$max_v2"
  done
}

cat "$FILE" \
  | find_two \
  | paste -sd+ \
  | bc
