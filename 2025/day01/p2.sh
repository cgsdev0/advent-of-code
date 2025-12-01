#!/bin/bash

FILE="$1"


function running_sum() {
  dial=50
  while read num; do
    echo "$dial $num -> $((dial + num))"
    [[ num -lt 0 && dial -eq 0 ]] && echo -n no
    ((dial+=num))

    while ((dial < 0)); do
      ((dial+=100))
      echo click
    done
    [[ dial -eq 0 ]] && echo click
    while ((dial >= 100)); do
      ((dial-=100))
      echo click
    done
  done
}
cat "$FILE" \
  | tr 'LR' '-+' \
  | running_sum \
  | grep -c '^click$'
