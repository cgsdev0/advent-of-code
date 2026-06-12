#!/usr/bin/env bash

clear

FILE=input.txt

declare -A map

function main() {
  read instructions
  read
  while read -r key left right; do
    map[$key]="$left $right"
  done < <(cat \
    | tr -ds '=(,)' ' ')
  start="AAA"
  curr="$start"
  idx=0
  steps=0
  while [[ $curr != "ZZZ" ]]; do
    instr=${instructions:idx:1}
    case $instr in
      L)
        curr=${map[$curr]%% *}
        ;;
      R)
        curr=${map[$curr]##* }
        ;;
    esac
    # echo "$curr"

    # next instruction
    len=${#instructions}
    idx=$(( (idx+1) % len))
    ((steps++))
  done
  echo $steps
}

main < $FILE
