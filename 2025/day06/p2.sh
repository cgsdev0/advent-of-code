#!/bin/bash

set -o noglob

FILE="$1"

mapfile -t arr < $FILE

rows=${#arr[@]}
op_row=$((rows-1))
((rows--))

cols=0
for((i=0; i<rows; ++i)); do
  len="${#arr[i]}"
  if [[ len -gt cols ]]; then
    cols=$len
  fi
done

for((r=0; r<=cols; ++r)); do
  new_op=${arr[op_row]:r:1}
  if [[ -n $new_op && $new_op != ' ' ]]; then
    op=$new_op
  fi
  for((c=0; c<rows; c++)); do
    echo -n "${arr[c]:r:1}"
  done
  echo $op
done \
  | sed 's/^[^0-9]*$//' \
  | tr '\n' '|' \
  | sed 's/[+*]||/||/g;s/||/\n/g;s/|//g' \
  | bc | paste -sd+ | bc
