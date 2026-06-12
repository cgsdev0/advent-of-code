#!/usr/bin/env bash

while IFS= read -r line; do
  echo "$line" \
    | cut -d' ' -f3- \
    | sed 's/[,;] /\n/g' \
    | sort -nr \
    | sort -sk2 \
    | uniq -f1 \
    | cut -d' ' -f1 \
    | paste -sd'*' \
    | bc
done < input.txt \
  | paste -sd+ \
  | bc
