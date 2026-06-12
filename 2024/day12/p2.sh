#!/usr/bin/env bash

FILE="$1"

x=0
y=0
declare -A grid
RID=0
declare -A regions
declare -A area
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
declare -A edges
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
    if [[ $c == ${grid[$up]} ]]; then
      queue+=("$up")
    else
      if [[ -n ${edges[$RID]} ]]; then
        edges[$RID]="${edges[$RID]} $up,U"
      else
        edges[$RID]="$up,U"
      fi
    fi
    if [[ $c == ${grid[$d]} ]]; then
      queue+=("$d")
    else
      if [[ -n ${edges[$RID]} ]]; then
        edges[$RID]="${edges[$RID]} $d,D"
      else
        edges[$RID]="$d,D"
      fi
    fi
    if [[ $c == ${grid[$l]} ]]; then
      queue+=("$l")
    else
      if [[ -n ${edges[$RID]} ]]; then
        edges[$RID]="${edges[$RID]} $l,L"
      else
        edges[$RID]="$l,L"
      fi
    fi
    if [[ $c == ${grid[$r]} ]]; then
      queue+=("$r")
    else
      if [[ -n ${edges[$RID]} ]]; then
        edges[$RID]="${edges[$RID]} $r,R"
      else
        edges[$RID]="$r,R"
      fi
    fi
    ((area[$RID]+=1))
    done
    if [[ -n $DID_ANYTHING ]]; then
      ((RID++))
    fi
  done
done

dedupe() {
  local px=-5
  local py=-5
  local pd=-5
  local x y d
  while read -r d x y; do
    if [[ $d == $pd ]] && ((x == px && (y-py == 1 || py-y == 1) )); then
      :
    else
      echo $d $x $y
    fi
    pd=$d
    px=$x
    py=$y
  done
}

swap() {
  local x y d
  while read -r d x y; do
    echo $d $y $x
  done
}

fix() {
  local x y d
  while IFS=, read -r x y d; do
    echo $d $x $y
  done
}

for ((i=0; i<RID; i++)); do
  PERIM=$(echo "${edges[$i]// /$'\n'}" \
      | fix \
      | sort -u -k1,1 -k2,2n -k3,3n \
      | dedupe \
      | swap \
      | sort -u -k1,1 -k2,2n -k3,3n \
      | dedupe \
      | wc -l)
  printf "%s * %s\n" "${area[$i]}" $PERIM
done  | paste -sd+ | bc
