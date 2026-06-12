#!/usr/bin/env bash

FILE="$1"

read -a arr < "$FILE"
og_arr=("${arr[@]}")

declare -A cache

apply_rules() {
    local item="$1"
    local i="$2"
    local acc=0
    # printf "%*s" $i "" 1>&2
    # printf "%s\n" "$item $i" 1>&2
    # echo "$item $i $acc"
    local j=$((i-1))
    local key="$item,$i"
    if [[ -n "${cache[$key]}" ]]; then
      # echo "CACHE HIT: $key" 1>&2
      RVAL=${cache[$key]}
      return
    fi
    local digits="${#item}"
    if ((i == 0)); then
      RVAL=1
      return
      if ((item == 0)); then
        RVAL=1
      elif (( digits % 2 == 0 )); then
        RVAL=2
      else
        RVAL=1
      fi

      return
    fi
    if ((item == 0)); then
      apply_rules 1 $j
      ((acc+=RVAL))
    elif (( digits % 2 == 0 )); then
      local half
      ((half = digits / 2))
      local left=${item:0:$half}
      [[ "$left" =~ ([1-9].*) ]]
      left=${BASH_REMATCH[1]}
      left=${left:-0}
      local right=${item:$half}
      [[ "$right" =~ ([1-9].*) ]]
      right=${BASH_REMATCH[1]}
      right=${right:-0}
      apply_rules $left $j
      ((acc+=RVAL))
      apply_rules $right $j
      ((acc+=RVAL))
    else
      ((item*=2024))
      apply_rules $item $j
      ((acc+=RVAL))
    fi
    RVAL=$acc
    cache[$key]=$acc
    # echo "Caching $key = $RVAL" 1>&2
}


clear
# apply_rules 17 6 # should be 15
# echo "FINAL: $RVAL"
# exit 0
# apply_rules 0 4
# exit 0
for n in "${og_arr[@]}"; do
  # echo "STARTING $n"
  apply_rules $n 75
  echo $RVAL
done | paste -sd+ | bc

# echo "${#arr[@]}"
