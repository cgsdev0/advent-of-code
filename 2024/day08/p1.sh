#!/usr/bin/env bash

FILE="$1"

declare -A grid
declare -A freq
declare -A antinode

x=0
y=0
mx=0
my=0
while IFS= read -n1 -r c; do
  if [[ "$c" == "" ]]; then
    ((y++))
    mx=$x
    x=0
    continue
  fi
  grid["$x,$y"]=$c
  if [[ "$c" != "." ]]; then
    pos=$x,$y
    if [[ -z "${freq[$c]}" ]]; then
      freq[$c]=$pos
    else
      freq[$c]="${freq[$c]} $pos"
    fi
  fi
  ((x++))
done < "$FILE"

my=$y

print_grid() {
  count=0
  local x
  local y
  for ((y=0; y<my; y++)); do
    for ((x=0; x<mx; x++)); do
      if [[ -n "${antinode[$x,$y]}" ]]; then
        ((count++))
        printf "#"
      else
        printf "%s" "${grid["$x,$y"]}"
      fi
    done
    echo
  done
}

split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

for f in "${!freq[@]}"; do
  split "${freq[$f]}" ' '
  LEN="${#arr[@]}"
  for ((i=0; i<LEN; i++)); do
    for ((j=0; j<LEN; j++)); do
      [[ $i -eq $j ]] && continue
      A="${arr[$i]}"
      ax="${A%,*}"
      ay="${A#*,}"
      B="${arr[$j]}"
      bx="${B%,*}"
      by="${B#*,}"
      dx=$((bx-ax))
      dy=$((by-ay))
      cx=$((ax-dx))
      cy=$((ay-dy))
      antinode[$cx,$cy]=$f
    done
  done
done

print_grid 1>&2
echo "$count"
