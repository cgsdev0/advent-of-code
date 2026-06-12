#!/usr/bin/env bash

FILE="$1"

x=0
y=0
declare -A grid
declare -a trailheads
while IFS= read -r -n1 c; do
  if [[ "$c" == "" ]]; then
    ((y++))
    x=0
    continue
  fi
  if [[ "$c" == "0" ]]; then
    trailheads+=("$x,$y")
  fi
  grid[$x,$y]=$c
  ((x++))
done < "$FILE"

bfs() {
  local -a queue=($1)
  local -A visited
  local count=0
  while [[ ${#queue[@]} -gt 0 ]]; do
    local sx="${queue[0]%,*}"
    local sy="${queue[0]#*,}"
    queue=("${queue[@]:1}")
    [[ -n "${visited[$sx,$sy]}" ]] && continue
    visited[$sx,$sy]=y
    local c=${grid[$sx,$sy]}
    if [[ $c -eq 9 ]]; then
      ((count++))
      continue
    fi
    # echo "$sx,$sy -> $c"
    A=$((sx+1)),$sy
    if [[ "${grid[$A]}" -eq $((c+1)) ]]; then
      queue+=($A)
    fi
    A=$((sx-1)),$sy
    if [[ "${grid[$A]}" -eq $((c+1)) ]]; then
      queue+=($A)
    fi
    A=$sx,$((sy+1))
    if [[ "${grid[$A]}" -eq $((c+1)) ]]; then
      queue+=($A)
    fi
    A=$sx,$((sy-1))
    if [[ "${grid[$A]}" -eq $((c+1)) ]]; then
      queue+=($A)
    fi
  done
  echo $count
}

for trailhead in "${trailheads[@]}"; do
  bfs "$trailhead"
done |
  paste -sd+ | bc
