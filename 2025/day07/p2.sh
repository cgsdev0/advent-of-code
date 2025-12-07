#!/bin/bash

FILE="$1"

mapfile -t grid < "$FILE"

h=${#grid[@]}
w=${#grid[0]}

declare -A cache
q=()

# find our starting point
for ((y=0; y<h; y++)); do
  for ((x=0; x<w; x++)); do
    if [[ ${grid[y]:x:1} == S ]]; then
      sx=$x
      sy=$((y+1))
      q+=($x $sy 'v')
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

while [[ ${#q[@]} -gt 0 ]]; do
  end=$((${#q[@]}-3))
  read x y z <<< "${q[end]} ${q[end+1]} ${q[end+2]}"
  q=(${q[@]:0:end})

  c=${grid[y]:x:1}
  cached=${cache[$x,$y]}
  if [[ $z == '|' ]]; then
    # we are revisiting a beam; update cache
    below=${cache[$x,$((y+1))]}
    cache[$x,$y]=${below:-1}
  elif [[ $z == '^' ]]; then
    # we are revisiting a splitter; update splitter
    left=${cache[$((x-1)),$y]}
    right=${cache[$((x+1)),$y]}
    cache[$x,$y]=$((left+right))
  elif [[ -n "$cached" ]]; then
    continue # i am speed
  elif [[ $c == '.' || $c == '|' ]]; then
    set_grid $x $y '|'
    q+=($x $y '|') # second, revisit ourself
    q+=($x $((y+1)) 'v') # first, visit below
  elif [[ $c == '^' ]]; then
    q+=($x $y '^') # third, revisit ourself
    q+=($((x+1)) $y 'v') # second, go right
    q+=($((x-1)) $y 'v') # first, go left
  fi
done

echo ${cache[$sx,$sy]}
