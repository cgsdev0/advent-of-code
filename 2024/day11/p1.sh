#!/usr/bin/env bash

FILE="$1"

read -a arr < "$FILE"

apply_rules() {
  local -a new_arr
  for item in "${arr[@]}"; do
    digits="${#item}"
    if ((item == 0)); then
      new_arr+=(1)
    elif (( digits % 2 == 0 )); then
      ((half = digits / 2))
      left=${item:0:$half}
      [[ "$left" =~ ([1-9].*) ]]
      left=${BASH_REMATCH[1]}
      left=${left:-0}
      right=${item:$half}
      [[ "$right" =~ ([1-9].*) ]]
      right=${BASH_REMATCH[1]}
      right=${right:-0}
      new_arr+=("$left" "$right")
    else
      ((item*=2024))
      new_arr+=($item)
    fi
  done
  arr=("${new_arr[@]}")
}

for ((i=0; i<25; i++)); do
  apply_rules
done

echo "${#arr[@]}"
