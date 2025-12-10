#!/bin/bash

. ../../misc/vardump

FILE="$1"

count-lights() {
  while read lights otherstuff; do
    lights=${lights//[\[\]]/}
    echo "${#lights} $lights"
    echo "${otherstuff% \{*}"
  done
}

combinations() {
  local start=$1
  local count=$2
  local amount=$3
  local acc=$4
  local i
  if [[ amount -eq 0 ]]; then
    echo "$acc"
    return
  fi
  local before="$acc"
  for ((i=start; i<=count-amount; ++i)); do
    if [[ -z "$acc" ]]; then
      acc="${buttons[i]//[()]/}"
    else
      acc="${acc} ${buttons[i]//[()]/}"
    fi
    combinations $((i+1)) $count $((amount-1)) "$acc"
    acc="$before"
  done
}

combinatorics() {
  while read c desired; do
    read -a buttons
    for ((i=1; i<=${#buttons[@]}; ++i)); do
      initial=()
      for ((j=0; j<c; j++)); do
        initial+=(.)
      done
      while read -a attempt; do
        state=("${initial[@]}")
        for ((k=0; k<${#attempt[@]}; k++)); do
          IFS=, read -a butts <<< "${attempt[k]}"
          for ((l=0; l<${#butts[@]}; l++)); do
            butt=${butts[l]}
            cur=${state[butt]}
            case "$cur" in
              '.') state[butt]='#' ;;
              '#') state[butt]='.' ;;
            esac
          done
        done
        final="${state[@]}"
        final="${final// /}"
        if [[ "$final" == "$desired" ]]; then
          echo ${#attempt[@]}
          break 2
        fi
      done< <(combinations 0 ${#buttons[@]} $i)
    done
  done
}

cat "$FILE" \
  | count-lights \
  | combinatorics \
  | paste -sd+ | bc
