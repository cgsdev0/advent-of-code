#!/usr/bin/env bash

clear

FILE=input.txt
STEPS=64

sr=0
sc=0
r=0
declare -A grid
while IFS= read -r line; do
  c=0
  while read -n1 char; do
    if [[ "$char" == "S" ]]; then
      sc=$c
      sr=$r
      char=.
    fi
    grid["$r,$c"]=$char
    ((c++))
  done <<< "$line"
  ((r++))
done < $FILE

declare -a queue
queue+=("$STEPS $sr $sc")

count=0
while [[ ${#queue[@]} -gt 0 ]]; do
  item=${queue[0]}
  queue=("${queue[@]:1}")
  read steps row col <<< "${item}"
  if [[ ${grid["$row,$col"]} != "." ]]; then
    continue
  fi
  if [[ $steps -lt 0 ]]; then
    continue
  fi
  remainder=$((steps % 2))
  if [[ $remainder -eq 1 ]]; then
    grid["$row,$col"]=,
  else
    ((count++))
    grid["$row,$col"]=O
  fi
  ((steps--))
  queue+=("$steps $((row-1)) $col")
  queue+=("$steps $row $((col-1))")
  queue+=("$steps $((row+1)) $col")
  queue+=("$steps $row $((col+1))")
done

# for((r=0;r<11;r++)); do
#   for((c=0;c<11;c++)); do
#     echo -n ${grid["$r,$c"]}
#   done
#   echo
# done

echo $count
