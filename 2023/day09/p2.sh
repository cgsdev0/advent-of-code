#!/usr/bin/env bash

clear

FILE=input.txt

while IFS= read -r line; do
  while grep -q '[1-9]' <<< "$line"; do
    echo "$line"
    prev=
    line=$(while IFS= read -r number; do
      if [[ ! -z "$prev" ]]; then
        echo "$((number-prev))"
      fi
      prev=$number
    done < <(echo "$line" \
      | tr ' ' '\n') \
      | paste -sd' ')
  done \
    | sed 's/^\([-0-9]\+\) .*$/(\1)/' \
    | paste -sd'-+' \
    | bc
done < "$FILE" \
  | paste -sd'+' \
  | bc
