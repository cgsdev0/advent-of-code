#!/bin/bash

. ../../misc/vardump

FILE="$1"
FILE=input.txt

while IFS=x read l w h; do
  s=$((l<w?w:l))
  s=$((s<h?h:s))
  main=$(((l+w+h-s)*2))
  bow=$((l*w*h))
  echo $((main + bow))
done < $FILE \
  | paste -sd+ | bc
