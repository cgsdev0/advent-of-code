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
      [[ $c == "@" || $c == "x" ]] || continue
      ((count++))
    done
  done
  echo $count
}

mark_for_removal() {
  marked=0
  for ((y=0;y<my;++y)); do
    for ((x=0;x<mx;++x)); do
      c="${grid[$x,$y]}"
      if [[ $c == "." ]]; then
        continue
      fi
      count=${ count_neighbors $x $y; }
      if [[ count -lt 4 ]]; then
        grid[$x,$y]='x'
        ((marked++))
      fi
    done
      echo
  done
  echo $marked
}

function remove_the_x() {
  for ((y=0;y<my;++y)); do
    for ((x=0;x<mx;++x)); do
      c="${grid[$x,$y]}"
      [[ $c != "x" ]] && continue
      grid[$x,$y]='.'
    done
  done
}
m=100
total=0
while [[ m -gt 0 ]]; do
  m=${ mark_for_removal; }
  remove_the_x
  # print_grid 1>&2
  ((total+=m))
done
echo $total
