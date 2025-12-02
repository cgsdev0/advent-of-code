#!/bin/bash

FILE="$1"

function expand-ranges() {
  local start end i
  while read start end; do
    for ((i=start;i<=end;i++)); do
      echo $i
    done
  done
}

function find-invalid() {
  local num len
  while read num; do
    len=${#num}
    ((len % 2 == 1)) && continue
    half=$((len / 2))
    a=${num:0:half}
    b=${num:half}
    [[ $a == $b ]] && echo $num
  done
}

cat "$FILE" \
  | tr ',-' '\n ' \
  | expand-ranges \
  | find-invalid \
  | paste -sd+ \
  | bc
