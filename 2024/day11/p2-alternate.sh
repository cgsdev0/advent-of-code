#!/usr/bin/env bash

# based on m33p's solution

FILE=$1
read -a arr < "$FILE"

declare -A stones

for stone in "${arr[@]}"; do
  ((stones[$stone]++))
done

for ((i=0; i<75; i++)); do
  for stone in "${!stones[@]}"; do
    n="${stones[$stone]}"
    digits="${#stone}"
    if ((stone == 0)); then
      ((new_stones[1]+=n))
    elif ((digits % 2 == 0)); then
      ((half = digits / 2))
      left=${stone:0:$half}
      [[ "$left" =~ ([1-9].*) ]]
      left=${BASH_REMATCH[1]}
      left=${left:-0}
      right=${stone:$half}
      [[ "$right" =~ ([1-9].*) ]]
      right=${BASH_REMATCH[1]}
      right=${right:-0}
      ((new_stones[$left]+=n))
      ((new_stones[$right]+=n))
    else
      ((stone*=2024))
      ((new_stones[$stone]+=n))
    fi
  done

  # this is the bash equivalent of python's:
  # stone = new_stones
  #
  # lmao
  unset stones
  declare -A stones
  for stone in "${!new_stones[@]}"; do
    stones[$stone]=${new_stones[$stone]}
  done
  unset new_stones
  declare -A new_stones
done

for stone in "${!stones[@]}"; do
  echo "${stones[$stone]}"
done | paste -sd+ | bc
