#!/bin/bash

FILE="$1"
# FILE=input.txt

mapfile -t grid < "$FILE"

h=${#grid[@]}
w=${#grid[0]}

print_grid() {
  local x y
  local rx=$1
  local ry=$2
  local r=${3:-32}
  for ((y=0; y<h; y++)); do
    for ((x=0; x<w; x++)); do
      if [[ x -eq rx && y -eq ry ]]; then
        RESET_ME=1
        echo -ne '\033['$r'm'
      fi
      if [[ -z ${cache[$x,$y]} ]]; then
        printf ${grid[y]:x:1}
      else
        local cached=${cache[$x,$y]}
        printf $((cached % 10))

      fi
      if [[ -n $RESET_ME ]]; then
        unset RESET_ME
        echo -ne '\033[39m'
      fi
    done
    echo
  done
}

q=()
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
print_grid ${q[0]} $((q[1]-1)) 1>&2

set_grid() {
  local x=$1
  local y=$2
  local c=$3
  grid[y]=${grid[y]:0:x}$c${grid[y]:x+1}
}

declare -A cache

count=1
while [[ ${#q[@]} -gt 0 ]]; do
  end=${#q[@]}
  ((end-=3))
  read x y z <<< "${q[end]} ${q[end+1]} ${q[end+2]}"
  # read x y z <<< "${q[0]} ${q[1]} ${q[2]}"
  q=(${q[@]:0:end})
  # q=(${q[@]:3})
  c=${grid[y]:x:1}
  cached=${cache[$x,$y]}
  if [[ $z == '|' ]]; then
    below=${cache[$x,$((y+1))]}
    cache[$x,$y]=${below:-1}
    # print_grid $x $y 35 1>&2
    foo=0
  elif [[ $z == '^' ]]; then
    left=${cache[$((x-1)),$y]}
    right=${cache[$((x+1)),$y]}
    cache[$x,$y]=$((left+right))
    # print_grid $x $y 35 1>&2
    foo=0
  elif [[ -n "$cached" ]]; then
    continue
  elif [[ $c == '.' || $c == '|' ]]; then
    set_grid $x $y '|'
    # print_grid $x $y 33 1>&2
    q+=($x $y '|')
    q+=($x $((y+1)) 'v')
  elif [[ $c == '^' ]]; then
    q+=($x $y '^')
    q+=($((x+1)) $y 'v')
    q+=($((x-1)) $y 'v')
  elif [[ $c == '|' ]]; then
    v=${cache[$x,$y]}
    # print_grid $x $y 31 1>&2
    # ((count+=v))
  fi
done
# print_grid
echo ${cache[$sx,$sy]}
