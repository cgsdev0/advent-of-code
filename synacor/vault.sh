#!/usr/bin/env bash

set -o noglob
declare -A grid

grid[0,0]='*'
grid[1,0]='8'
grid[2,0]='-'
grid[3,0]='1'
grid[0,1]='4'
grid[1,1]='*'
grid[2,1]='11'
grid[3,1]='*'
grid[0,2]='+'
grid[1,2]='4'
grid[2,2]='-'
grid[3,2]='18'
grid[0,3]='22'
grid[1,3]='-'
grid[2,3]='9'
grid[3,3]='*'

dfs() {
  local x=$1
  local y=$2
  local d=$3
  local val=$4
  local op=$5
  local path=$6
  if [[ d -eq 0 ]]; then
    if [[ $x -eq 3 && y -eq 0 ]]; then
      thing=1
      let "val=$val$op$thing"
      if [[ $val -eq 30 ]]; then
        echo "$path $val"
      fi
    fi
    return
  elif [[ x -eq 3 && y -eq 0 ]]; then
    return
  fi
  if [[ -n "$path" && x -eq 0 && y -eq 3 ]]; then
    return
  fi
  thing="${grid[$x,$y]}"
  if [[ -z "$thing" ]]; then
    return
  fi
  if [[ "$thing" =~ [0-9]+ && -n "$op" ]]; then
     let "val=$val$op$thing"
     if ((val > 32767)); then
       return
     elif ((val <= 0)); then
       return
     fi
  else
    op=$thing
  fi
  ((d--))
  dfs $((x-1)) $y $d $val "$op" "$path west"
  dfs $((x+1)) $y $d $val "$op" "$path east"
  dfs $x $((y-1)) $d $val "$op" "$path north"
  dfs $x $((y+1)) $d $val "$op" "$path south"
}
dfs 0 3 $1 22
