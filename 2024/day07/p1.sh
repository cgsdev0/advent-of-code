#!/usr/bin/env bash

FILE="$1"

split() {
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

permute() {
  local LEN=${#arr[@]}
  local MAX=$((2**(LEN-1)))
  for ((i=0; i<MAX; i++)); do
    local ACC=${arr[0]}
    for ((j=1; j<LEN; j++)); do
      local NUM=${arr[$j]}
      if [[ $((i >> (j-1) & 1)) -eq 1 ]]; then
        ((ACC*=NUM))
      else
        ((ACC+=NUM))
    fi
    done
    echo "$ACC"
  done
}

while IFS= read -r line; do
  test_number="${line%%:*}"
  rest="${line##*: }"
  split "$rest" " "
  permute \
    | grep "^$test_number$" \
    | head -n1
done < "$FILE" \
  | paste -sd+ \
  | bc
