#!/bin/bash

. ../../misc/vardump

FILE="$1"

do_the_math() {
  while IFS=, read -a arr; do
    max=0
    total=0
    for ((i=0; i<${#arr[@]}; i++)); do
      el=${arr[i]}
      if [[ el -gt max ]]; then
        max=$el
      fi
      ((total+=el))
    done
    echo "$((total-max)) ($max-$total)"
  done
}

shwoop() {
  while read -a stuff; do
    local tmp=${stuff[0]}
    local len="${#stuff[@]}"
    stuff[0]="${stuff[len-1]}"
    stuff[len-1]="${tmp}"
    echo "${stuff[@]}"
  done
}

make_buckets() {
  while read -a row; do
    requirements="${row[0]}"
    buttons=("${row[@]:1}")
    IFS=, read -a reqs <<< $requirements
    unset buckets
    local -a buckets
    for ((i=0; i<${#reqs[@]}; i++)); do
      for ((j=0; j<${#buttons[@]}; j++)); do
        IFS=, read -a wires <<< "${buttons[j]}"
        contains=0
        for ((k=0; k<${#wires[@]}; k++)); do
          if [[ ${wires[k]} -eq i ]]; then
            contains=1
          fi
        done
        [[ contains -eq 0 ]] && continue
        if [[ -z "${buckets[i]}" ]]; then
          buckets[i]=${buttons[j]}
        else
          buckets[i]="${buckets[i]} ${buttons[j]}"
        fi
      done
    done
    min=10000
    key=0
    for ((i=0;i<${#buckets[@]};++i)); do
      arr=(${buckets[i]})
      length=${#arr[@]}
      if [[ length -lt min ]]; then
        key=$i
        min=$length
      fi
    done
    echo "$min buckets, ${reqs[key]} presses"
  done
}

FILE=input.txt
cat $FILE \
  | cut -d' ' -f2- \
  | shwoop \
  | tr -d '{}()' \
  | make_buckets \
  | sort -n
