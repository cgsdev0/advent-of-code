#!/bin/bash

. ../../misc/vardump

FILE="$1"

while IFS=x read l w h; do
  a=$((l*w))
  b=$((l*h))
  c=$((w*h))
  s=$((a>b?b:a))
  s=$((s>c?c:s))
  echo $((2*a+2*b+2*c+s))
done < $FILE \
  | paste -sd+ | bc
