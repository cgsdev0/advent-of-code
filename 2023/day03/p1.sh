#!/usr/bin/env bash

set -o noglob


declare -a grid

width=0
height=0
while IFS= read -r line; do
  grid+=("$line")
  width=${#line}
  ((height+=1))
done < input.txt

row=0
col=0
sr=0
sc=0

function scan() {
  local c
  local r
  len=${#number}
  for ((r=sr-1;r<=sr+1;r++)); do
    for ((c=sc-1;c<=len+sc;c++)); do
      if ((r<0)) || ((c<0)); then
        continue
      fi
      if ((r>=height)) || ((c>=width)); then
        continue
      fi
      if [[ "${grid[r]:c:1}" =~ [0-9.] ]]; then
        continue
      fi
      echo "$number"
      return
    done
  done
}

function part_numbers() {
  for line in ${grid[@]}; do
    col=0
    [[ ! -z "$number" ]] && scan
    number=""
    while read -n1 c; do
      if [[ "$c" == '' ]]; then
        break
      fi
      if [[ "$c" =~ [0-9] ]]; then
        if [[ -z "$number" ]]; then
          sr=$row
          sc=$col
        fi
        number="$number$c"
      else
        [[ ! -z "$number" ]] && scan
        number=""
      fi
      # echo "$c"
      ((col+=1))
    done <<< "${line}"
    ((row+=1))
  done

  [[ ! -z "$number" ]] && scan
}

part_numbers | paste -sd+ | bc
