#!/usr/bin/env bash

FILE="$1"

declare -a disk
free=
ID=0
while IFS= read -r -n1 c; do
  [[ "$c" == "" ]] && break
  while [[ $c -gt 0 ]]; do
    if [[ -z "$free" ]]; then
      disk+=("$ID")
    else
      disk+=(".")
    fi
    ((c--))
  done
  if [[ -z "$free" ]]; then
    free=yes
  else
    ((ID++))
    free=
  fi
done < "$FILE"

show_disk() {
  output="${disk[@]}"
  echo "${output// /}"
}

defrag() {
  LEN=${#disk[@]}
  j=$((LEN-1))
  for ((i=0; i<LEN; i++)); do
    [[ $i -ge $j ]] && break
    while [[ ${disk[$j]} == '.' ]]; do ((j--)); done
    while [[ ${disk[$i]} != '.' ]]; do ((i++)); done
    disk[$i]=${disk[$j]}
    disk[$j]='.'
    ((j--))
  done
}

checksum() {
  LEN=${#disk[@]}
  for ((i=0; i<LEN; i++)); do
    [[ ${disk[$i]} == '.' ]] && break
    echo "$i*${disk[$i]}"
  done
}

defrag
checksum \
  | paste -sd+ \
  | bc
