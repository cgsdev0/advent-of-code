#!/usr/bin/env bash

FILE="$1"

x=0
y=0
declare -A grid
RID=0
declare -A regions
declare -A area
declare -A perimeter
while IFS= read -r -n1 c; do
  if [[ "$c" == "" ]]; then
    ((y++))
    width=$x
    x=0
    continue
  fi
  grid[$x,$y]="$c"
  ((x++))
done < "$FILE"

height=$y


declare -A visited
declare -a queue
for ((gy=0; gy<height; gy++)); do
  for ((gx=0; gx<width; gx++)); do
    DID_ANYTHING=
    queue+=("$gx,$gy")
    while [[ ${#queue[@]} -gt 0 ]]; do
    next="${queue[0]}"
    queue=("${queue[@]:1}")

    IFS=, read x y <<< "$next"
    [[ -n ${visited[$x,$y]} ]] && continue
    DID_ANYTHING=yes
    visited[$x,$y]=tru
    c="${grid[$x,$y]}"
    regions[$x,$y]=$RID
    up="${x},$((y-1))"
    d="${x},$((y+1))"
    l="$((x-1)),${y}"
    r="$((x+1)),${y}"
    P=4
    if [[ $c == ${grid[$up]} ]]; then
      queue+=("$up")
      ((P--))
    fi
    if [[ $c == ${grid[$d]} ]]; then
      queue+=("$d")
      ((P--))
    fi
    if [[ $c == ${grid[$l]} ]]; then
      queue+=("$l")
      ((P--))
    fi
    if [[ $c == ${grid[$r]} ]]; then
      queue+=("$r")
      ((P--))
    fi
    ((perimeter[$RID]+=P))
    ((area[$RID]+=1))
    # if [[ ${grid[$u]} == $c ]]; then
    #   regions[$x,$y]=${regions[$u]}
    # elif [[ ${grid[$l]} == $c ]]; then
    #   regions[$x,$y]=${regions[$l]}
    # else
    #   ((RID++))
    #   regions[$x,$y]=$RID
    # fi
    done
    if [[ -n $DID_ANYTHING ]]; then
      ((RID++))
    fi
  done
done

for ((i=0; i<RID; i++)); do
  echo "${perimeter[$i]} * ${area[$i]}"
done | paste -sd+ | bc
