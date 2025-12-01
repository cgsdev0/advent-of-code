#!/bin/bash

FILE="$1"

function running_sum() {
  dial=50
  while read num; do
    dial=$(((dial + num + 100000) % 100))
    echo $dial
  done
}
cat "$FILE" \
  | tr 'LR' '-+' \
  | running_sum \
  | grep -c '^0$'
