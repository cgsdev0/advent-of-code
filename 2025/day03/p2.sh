#!/bin/bash

FILE="$1"

function find_twelve() {
  local input=$1
  local acc=$2
  local first=$3
  local search=9
  local len=${#input}
  RVAL=
  local needed=${#acc}
  needed=$((12-needed))
  if [[ needed -eq 0 ]]; then
    RVAL=$acc
    return
  fi
  if [[ len -lt needed ]]; then
    RVAL=
    return
  fi
  if [[ len -eq 1 ]]; then
    RVAL=$acc$input
    return
  fi
  # max_i=-1
  for ((search=9; search>0; --search)); do
    for ((i=0; i<len-needed+1; ++i)); do
      local c=${input:i:1}
      if [[ c -eq search ]]; then
        find_twelve ${input:((i+1))} $acc$c
        if [[ ${#RVAL} -eq 12 ]]; then
          [[ -n $first ]] && echo $RVAL
          return
        fi
        break
      fi
    done
  done
  [[ -n $first ]] && echo $RVAL
  RVAL=$acc
}

function find_ninety_seven() {
  while read -r line; do
    # echo -n "$line -> "
    find_twelve $line '' 1
  done
}

cat "$FILE" |
  find_ninety_seven \
  | paste -sd+ | bc
  # | paste -sd+ | bc
  # | paste -sd+ | bc
# gotta go fast
# if [[ -n "$DONT_FORK_BOMB_ME_BRO" ]]; then
#   find_twelve
# else
#   export DONT_FORK_BOMB_ME_BRO=true
#   <$FILE parallel --pipe -N 4 $0 \
#     | paste -sd+ \
#     | bc
#
