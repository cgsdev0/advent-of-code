#!/bin/bash

FILE="$1"

mapfile -t grid < "$FILE"

h=${#grid[@]}
w=${#grid[0]}

print_grid() {
  local x y
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do
      printf ${grid[y]:x:1}
    done
    echo
  done
}

q=()
print_grid 1>&2
for ((y=0; y<h; y++)); do
  for ((x=0; x<w; x++)); do
    if [[ ${grid[y]:x:1} == S ]]; then
      q+=($x $((y+1)))
      break 2
    fi
  done
done

set_grid() {
  local x=$1
  local y=$2
  local c=$3
  grid[y]=${grid[y]:0:x}$c${grid[y]:x+1}
}

count=0
while [[ ${#q[@]} -gt 0 ]]; do
  read x y <<< "${q[0]} ${q[1]}"
  c=${grid[y]:x:1}
  if [[ $c == '.' ]]; then
    set_grid $x $y '|'
    # print_grid 1>&2
    q+=($x $((y+1)))
  elif [[ $c == '^' ]]; then
    ((count++))
    q+=($((x-1)) $y)
    q+=($((x+1)) $y)
  fi
  q=(${q[@]:2})
done
echo $count
