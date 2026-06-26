#!/usr/bin/env bash

. ../../misc/vardump

FILE="$1"

while read -r line; do
  vowels=${line//[aeiou]/}
  vowels=$((${#line} - ${#vowels}))
  [[ $vowels -lt 3 ]] && continue
  [[ $line =~ aa|bb|cc|dd|ee|ff|gg|hh|ii|jj|kk|ll|mm|nn|oo|pp|qq|rr|ss|tt|uu|vv|ww|xx|yy|zz ]] || continue
  [[ $line =~ ab|cd|pq|xy ]] && continue
  echo "$line"
done < "$FILE" | wc -l
