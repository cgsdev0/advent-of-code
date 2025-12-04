#!/bin/bash

FILE="$1"

cat "$FILE" \
  | tr 'LR' '-+' \
  | awk 'BEGIN {sum=50} {sum = (sum+$1+100)%100; print sum}' \
  | grep -c '^0$'
