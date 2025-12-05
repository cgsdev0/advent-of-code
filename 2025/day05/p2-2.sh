#!/bin/bash

FILE="$1"

function main() {
  declare -a ranges
  while IFS=- read start end; do
    [[ -z $end ]] && break
    seq $start $end
  done
}

main < "$FILE" |
  sort -u | wc -l
