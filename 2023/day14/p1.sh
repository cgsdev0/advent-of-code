#!/usr/bin/env bash

clear
FILE=input.txt

declare -a sums
declare -a idx
row=0
height=$(wc -l < $FILE | cut -d' ' -f2)
while IFS= read -r line; do
  if [[ $row -eq 0 ]]; then
    width=${#line}
    for ((i=0; i<width; i++)); do
      sums[$i]=0
      idx[$i]=0
    done
  fi
  col=0
  while IFS= read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi
    if [[ "$char" == "O" ]]; then
      i=${idx[col]}
      ((sums[$col]+=(height - i)))
      ((idx[$col]++))
    fi
    if [[ "$char" == "#" ]]; then
      idx[$col]=$((row + 1))
    fi
    ((col++))
  done <<< "$line"
  ((row++))
done < $FILE

for ((i=0; i<width; i++)); do
  echo ${sums[$i]}
done \
  | paste -sd+ \
  | bc
