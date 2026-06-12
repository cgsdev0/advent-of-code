#!/usr/bin/env bash

FILE="$1"

declare -A grid
declare -a origins
x=0
y=0

while IFS= read -n1 c; do
  if [[ "$c" == "" ]]; then
    ((y++))
    x=0
    continue
  fi
  grid["$x,$y"]=$c
  if [[ "$c" == "X" ]]; then
    origins+=("$x,$y")
  fi
  ((x++))
done < "$FILE"

count=0

scan() {
  dx="$1"
  dy="$2"
  M=${grid[$((dx*1+x)),$((dy*1+y))]}
  A=${grid[$((dx*2+x)),$((dy*2+y))]}
  S=${grid[$((dx*3+x)),$((dy*3+y))]}
  [[ "$M" == "M" && "$A" == "A" && "$S" == "S" ]] && ((count++))
}

for origin in "${origins[@]}"; do
  x="${origin%%,*}"
  y="${origin##*,}"
  scan 1 0
  scan -1 0
  scan 0 1
  scan 0 -1
  scan 1 1
  scan -1 -1
  scan 1 -1
  scan -1 1
done

echo $count
