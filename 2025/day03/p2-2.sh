#!/bin/bash

FILE="$1"

function find_ninety_seven() {
  while read line; do
    len=${#line}
    max_v=0
    for ((i=0; i<len-2; ++i)); do
      for ((j=i+1; j<len-1; ++j)); do
        for ((k=j+1; k<len; ++k)); do
          [[ k -eq j ]] && continue
          [[ k -eq i ]] && continue
          c="${line:0:i}${line:$((i+1)):$((j-i-1))}${line:$((j+1)):$((k-j-1))}${line:$((k+1)):$((len-k))}"
          # echo $i $j $k "$c" ${#c}
          if [[ c -gt max_v ]]; then
            max_v=$c
          fi
        done
      done
    done
    echo $max_v
  done
}

head -n1 "$FILE" |
  find_ninety_seven
# gotta go fast
# if [[ -n "$DONT_FORK_BOMB_ME_BRO" ]]; then
#   find_twelve
# else
#   export DONT_FORK_BOMB_ME_BRO=true
#   <$FILE parallel --pipe -N 4 $0 \
#     | paste -sd+ \
#     | bc
# fi
