#!/bin/bash

FILE="$1"

function main() {
  declare -a ranges
  while IFS=- read start end; do
    [[ -z $end ]] && break
    ranges+=($start)
    ranges+=($end)
    ((r+=2))
  done
  while read id; do
    for ((i=0; i<r; i+=2)); do
      start=${ranges[i]}
      end=${ranges[i+1]}
      if [[ id -ge start && id -le end ]]; then
        echo "$id"
        break
      fi

    done
  done
}

main < "$FILE" | wc -l
