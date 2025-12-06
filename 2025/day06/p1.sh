#!/bin/bash

FILE="$1"

CLEAN="$(tr -s ' ' < "$FILE" \
  | sed 's/^ //')"

COLS=$(echo "$CLEAN" | head -n1 | tr ' ' '\n' | wc -l)

for ((i=1;i<=COLS;++i)); do
  (read operator; paste -sd$operator) < <(echo "$CLEAN" | cut -d' ' -f$i | tac) | bc
done | paste -sd+ | bc
