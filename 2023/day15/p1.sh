#!/usr/bin/env bash

clear

FILE=input.txt

function hashit() {
  local total=0
  while read -n1 char; do
    [[ "$char" == "" ]] && continue
    add=$(LC_CTYPE=C printf '%d' "'$char")
    total=$(((total+add) * 17 % 256))
  done <<< "$1"
  echo "$total"
}

while read -d, str; do
  hashit "$str"
done < "$FILE" \
  | paste -sd+ \
  | bc
