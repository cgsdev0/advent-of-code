#!/usr/bin/env bash

clear

FILE=input.txt
function transpose() {
  awk '{ for (i=1; i<=NF; i++) a[i]= (a[i]? a[i] FS $i: $i) } END{ for (i in a) print a[i] }'
}

while IFS= read -r line; do
  read time distance <<< "$line"
  seq 0 $time \
    | awk '{ print "(('$time'-"$0")*"$0")>'$distance'"; }' \
    | bc \
    | grep '^1$' -c
done < <(cat $FILE \
  | tr -s ' ' \
  | cut -d' ' -f2- \
  | transpose \
  | tac) \
  | paste -sd'*' \
  | bc
