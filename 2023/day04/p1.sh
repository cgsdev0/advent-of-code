#!/usr/bin/env bash

clear

while IFS= read -r line; do
  echo "$line" \
    | tr -d '|' \
    | tr -s ' ' \
    | cut -d' ' -f3- \
    | sed 's/ /\n/g' \
    | sort -n \
    | uniq -d \
    | wc -l \
    | grep -v '^0$' \
    | sed 's/\(.*\)/2^(\1-1)/g' \
    | bc
done < input.txt \
  | paste -sd+ \
  | bc
