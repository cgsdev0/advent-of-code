#!/bin/bash

FILE="$1"

mapfile -t list < "$FILE"

count=${#list[@]}
max=0
for ((i=0;i<count;i++)); do
  for ((j=i+1;j<count;j++)); do
    [[ i -eq j ]] && continue
    IFS=, read x1 y1 <<< "${list[i]}"
    IFS=, read x2 y2 <<< "${list[j]}"
    dx=$((x1-x2))
    dx=${dx/-/}
    dy=$((y1-y2))
    dy=${dy/-/}
    area=$(((dx + 1)*(dy + 1)))
    if [[ area -gt max ]]; then
      max=$area
    fi
  done
done

echo $max
