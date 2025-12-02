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
  local num len i j k a b
  while read num; do
    len=${#num}
    half=$((len / 2))
    for ((i=1; i<=half; i++)); do
      ((len % i == 0)) || continue
      a=${num:0:i}
      j=$((len / i))
      b=
      for ((k=0; k<j; k++)); do
        b=${a}${b}
      done
      [[ $num == $b ]] && echo $num && break
    done
  done
}

cat "$FILE" \
  | tr ',-' '\n ' \
  | expand-ranges \
  | find-invalid \
  | paste -sd+ \
  | bc
