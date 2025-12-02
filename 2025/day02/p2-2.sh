#!/bin/bash

FILE="$1"

function expand-ranges() {
  local start end
  while read start end; do
    seq $start $end
  done
}

# credit to gnarf37 and ericwastl
function find-invalid() {
  grep -E '^(.+)(\1)+$'
}

cat "$FILE" \
  | tr ',-' '\n ' \
  | expand-ranges \
  | find-invalid \
  | paste -sd+ \
  | bc
