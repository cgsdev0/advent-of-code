#!/bin/bash

. ../../misc/vardump

FILE="$1"

FILE=input.txt


volumes=()
while IFS= read -r line; do
  presents+=("$line")
  vol="${line//\./}"
  volumes+=("${#vol}")

done < <(grep -v x $FILE \
  | paste -d' ' - - - - - \
  | tr -d ': [0-9]')

filter_impossible() {
  while read grid rest; do
    read -a guys <<< "${rest}"
    IFS=x read x y <<< "${grid}"
    area=$((x*y))
    liquified_presents=0
    for ((i=0;i<6;++i)); do
      ((liquified_presents+=guys[i]*volumes[i]))
    done
    if [[ $area -lt $liquified_presents ]]; then
      :
    else
      air=$((area-liquified_presents))
      echo "$air $grid $rest"
    fi
  done
}
grep x $FILE \
  | tr -d : \
  | filter_impossible \
  | wc -l
