#!/usr/bin/env bash

clear

FILE=input.txt

width=$(wc -l < $FILE | cut -d' ' -f1)
x=0
y=0
declare -A grid
while read -r -n1 char; do
  if [[ "$char" == "" ]]; then
    ((y++))
    x=0
    continue
  fi
  grid["$x,$y"]="$char"
  ((x++))
done < "$FILE"

function move() {
  case "$d" in
    R)
      ((x++))
      ;;
    L)
      ((x--))
      ;;
    U)
      ((y--))
      ;;
    D)
      ((y++))
      ;;
  esac
}

function out_of_bounds() {
  if [[ $x -ge $width ]] || \
  [[ $x -lt 0 ]] || \
  [[ $y -lt 0 ]] || \
  [[ $y -ge $width ]]; then
    return 0
  fi
  return 1
}

function solve() {
  local start=$1
  declare -A visited
  declare -a queue
  queue+=("$start")
  while [[ ${#queue[@]} -gt 0 ]]; do
    item=${queue[0]}
    queue=("${queue[@]:1}")
    IFS=, read x y d <<< "$item"
    # printf "%s -> " "$x $y $d"
    move
    if out_of_bounds; then
      # echo "OUT OF BOUNDS"
      continue
    fi
    if [[ ! -z "${visited["$x,$y,$d"]}" ]]; then
      # echo "LOOP DETECTED"
      continue
    fi
    visited["$x,$y,$d"]=true
    # echo "$x $y $d"
    char=${grid["$x,$y"]}
    # echo "$char"
    case "${char}${d}" in
      "-L")
        ;&
      "-R")
        ;&
      "|D")
        ;&
      "|U")
        ;&
      "."*)
        queue+=("$x,$y,$d")
        ;;
      "|L")
        ;&
      "|R")
        queue+=("$x,$y,U")
        queue+=("$x,$y,D")
        ;;
      "-U")
        ;&
      "-D")
        queue+=("$x,$y,L")
        queue+=("$x,$y,R")
        ;;
      "/L")
        queue+=("$x,$y,D")
        ;;
      "/R")
        queue+=("$x,$y,U")
        ;;
      "/U")
        queue+=("$x,$y,R")
        ;;
      "/D")
        queue+=("$x,$y,L")
        ;;
      "\L")
        queue+=("$x,$y,U")
        ;;
      "\R")
        queue+=("$x,$y,D")
        ;;
      "\U")
        queue+=("$x,$y,L")
        ;;
      "\D")
        queue+=("$x,$y,R")
        ;;
    esac
  done

  for i in "${!visited[@]}"; do
    echo "$i"
  done \
      | cut -d',' -f1-2 \
      | sort -u \
      | wc -l
}

function edges() {
  for ((i=0;i<width;i++)); do
    echo "-1,$i,R"
  done
  for ((i=0;i<width;i++)); do
    echo "$width,$i,L"
  done
  for ((i=0;i<width;i++)); do
    echo "$i,-1,D"
  done
  for ((i=0;i<width;i++)); do
    echo "$i,$width,U"
  done
}

function main() {
  while IFS= read -r line; do
    solve "$line"
  done
}

# gotta go fast
if [[ ! -z "$DONT_FORK_BOMB_ME_BRO" ]]; then
  main
else
  export DONT_FORK_BOMB_ME_BRO=true
  edges | parallel --pipe -N 100 $0 \
    | sort -n \
    | tail -n1
fi
