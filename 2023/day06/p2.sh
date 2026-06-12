#!/usr/bin/env bash

FILE=input.txt

function calculate() {
  read t
  read d

  echo $(\
    echo "$(\
      echo "sqrt($t * $t - 4 * $d)" \
      | bc -l) / 1 + 1" \
    | bc)
}

cut -d' ' -f2- $FILE \
  | tr -d ' ' \
  | calculate
