#!/bin/bash

FILE="$1"

declare -A grid

y=0
while read line; do
  x=0
  while read -n1 c; do
    [[ "$c" == "" ]] && continue
    grid[$x,$y]=$c
    ((x++))
  done <<< "$line"
  ((y++))
done < "$FILE"

mx=$x
my=$y
function print_grid() {
  for ((y=0;y<my;++y)); do
    for ((x=0;x<mx;++x)); do
      echo -n "${grid[$x,$y]}"
    done
    echo
  done
}

print_grid 1>&2

function count_neighbors() {
  local x=$1
  local y=$2
  local count=0
  for ((a=-1; a<=1; a++)); do
    for ((b=-1; b<=1; b++)); do
      [[ a -eq b && a -eq 0 ]] && continue
      local c="${grid[$((x+a)),$((y+b))]}"
      [[ $c == "@" ]] || continue
      ((count++))
    done
  done
  echo $count
}

total=0
for ((y=0;y<my;++y)); do
  for ((x=0;x<mx;++x)); do
    c="${grid[$x,$y]}"
    if [[ $c != "@" ]]; then
      echo -n '.'
      continue
    fi
    count=${ count_neighbors $x $y; }
    echo -n $count
    if [[ count -lt 4 ]]; then
      ((total++))
    fi
  done
    echo
done 1>&2
echo $total
