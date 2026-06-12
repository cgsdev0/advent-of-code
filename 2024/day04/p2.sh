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
  if [[ "$c" == "A" ]]; then
    origins+=("$x,$y")
  fi
  ((x++))
done < "$FILE"

count=0

scan() {
  dx="$1"
  dy="$2"
  RVAL=${grid[$((dx*1+x)),$((dy*1+y))]}
}

for origin in "${origins[@]}"; do
  x="${origin%%,*}"
  y="${origin##*,}"
  MAS=
  scan -1 -1
  MAS="${MAS}${RVAL}"
  scan 1 -1
  MAS="${MAS}${RVAL}"
  scan 1 1
  MAS="${MAS}${RVAL}"
  scan -1 1
  MAS="${MAS}${RVAL}"
  case "$MAS" in
    SMMS)
      ;&
    MMSS)
      ;&
    SSMM)
      ;&
    MSSM)
      ((count++))
      ;;
  esac

done

echo $count
