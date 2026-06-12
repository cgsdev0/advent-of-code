#!/usr/bin/env bash

clear

FILE=input.txt

declare -A map
declare -a starts
declare -a cycles

function debug() {
  echo "$*" 1>&2
}

function main() {
  read instructions
  read
  while read -r key left right; do
    map[$key]="$left $right"
    if [[ "$key" =~ .*A ]]; then
      starts+=($key)
    fi
  done < <(cat \
    | tr -ds '=(,)' ' ')

  for start in "${starts[@]}"; do
    debug "$start"
    curr="$start"
    idx=0
    steps=0
    while ! [[ $curr =~ .*Z ]]; do
      instr=${instructions:idx:1}
      case $instr in
        L)
          curr=${map[$curr]%% *}
          ;;
        R)
          curr=${map[$curr]##* }
          ;;
      esac

      # next instruction
      len=${#instructions}
      idx=$(( (idx+1) % len))
      ((steps++))
    done
    debug $steps
    cycles+=($steps)
  done

  # find LCM
  debug
  debug "finding LCM"
  for cycle in "${cycles[@]}"; do
    factor $cycle 1>&2
    factor $cycle \
      | cut -d' ' -f2- \
      | tr ' ' '\n' \
      | sort -n \
      | uniq -c
  done \
    | sort -k2n -k1nr \
    | uniq -f1 \
    | tr -s ' ' \
    | sed 's/^ \([^ ]*\) \([^ ]*\)$/\2^\1/' \
    | bc \
    | paste -sd'*' \
    | bc
}

main < $FILE
