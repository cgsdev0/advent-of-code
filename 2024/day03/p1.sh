#!/usr/bin/env bash

FILE="$1"

grep -o 'mul([0-9]\+,[0-9]\+)' "$FILE" \
  | sed 's/,/*/;s/[mul()]//g' \
  | paste -sd+ \
  | bc
