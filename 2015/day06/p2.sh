#!/usr/bin/env bash

. ../../misc/vardump

declare -a grid

light() {
  local x1 y1 x2 y2 r c
  IFS=, read x1 y1 <<< "$1"
  IFS=, read x2 y2 <<< "$2"
  for ((r=y1; r<=y2; r++)); do
  for ((c=x1; c<=x2; c++)); do
    ((grid[r*1000+c]++))
  done
  done
}

unlight() {
  local x1 y1 x2 y2
  IFS=, read x1 y1 <<< "$1"
  IFS=, read x2 y2 <<< "$2"
  for ((r=y1; r<=y2; r++)); do
  for ((c=x1; c<=x2; c++)); do
    ((grid[r*1000+c]--))
    if [[ ${grid[r*1000+c]} -lt 0 ]]; then
      grid[r*1000+c]=0
    fi
  done
  done
}

toggle() {
  local x1 y1 x2 y2
  IFS=, read x1 y1 <<< "$1"
  IFS=, read x2 y2 <<< "$2"
  for ((r=y1; r<=y2; r++)); do
  for ((c=x1; c<=x2; c++)); do
    ((grid[r*1000+c]+=2))
  done
  done
}

while read -r action a b; do
  $action $a $b
done < <(cat "$1" | sed 's/turn on/light/g;s/turn off/unlight/g;s/ through//')

count=0
for ((r=0; r<1000; r++)); do
for ((c=0; c<1000; c++)); do
    brightness=${grid[r*1000+c]:-0}
    ((count+=brightness))
done
done

echo $count
