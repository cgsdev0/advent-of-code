#!/usr/bin/env bash

FILE="$1"

filter() {
  ENABLE=do
  while IFS= read -r line; do
    if [[ "$line" == "don't()" ]]; then
      ENABLE=
      continue
    fi
    if [[ "$line" == "do()" ]]; then
      ENABLE=do
      continue
    fi
    [[ -n "$ENABLE" ]] && echo "$line"
  done
}

grep -oE 'don'"'"'t\(\)|do\(\)|mul\([0-9]+,[0-9]+\)' "$FILE" \
  | filter \
  | sed 's/,/*/;s/[mul()]//g' \
  | bc \
  | paste -sd+ \
  | bc
