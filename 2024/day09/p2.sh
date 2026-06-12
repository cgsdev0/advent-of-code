#!/usr/bin/env bash

FILE="$1"

declare -a disk
free=
ID=0
while IFS= read -r -n1 c; do
  [[ "$c" == "" ]] && break
  if [[ -z "$free" ]]; then
    disk+=("$ID:$c")
  else
    disk+=(".:$c")
  fi
  if [[ -z "$free" ]]; then
    free=yes
  else
    ((ID++))
    free=
  fi
done < "$FILE"

show_disk() {
  local LEN=${#disk[@]}
  local j=0
  local i
  for ((i=0; i<LEN; i++)); do
    local node="${disk[$i]}"
    local ID="${node%:*}"
    local COUNT="${node#*:}"
    while [[ $COUNT -gt 0 ]]; do
      printf "%s" "$ID"
      ((j++))
      ((COUNT--))
    done
  done
  echo
}

defrag() {
  LEN=${#disk[@]}
  MIN_J=0
  for ((i=LEN-1; i>0; i--)); do
    [[ "${disk[$i]:0:1}" == '.' ]] && continue
    SCANNING=true
    for ((j=MIN_J; j<i; j++)); do
      [[ "${disk[$j]:0:1}" != '.' ]] && continue
      if [[ -n $SCANNING ]]; then
        SCANNING=
        MIN_J=$j
      fi
      empty_node="${disk[$j]}"
      other_node="${disk[$i]}"
      empty_size="${empty_node#*:}"
      other_size="${other_node#*:}"
      empty_id="${empty_node%:*}"
      other_id="${other_node%:*}"
      if [[ $empty_size -ge $other_size ]]; then
        disk[$j]="$other_id:$other_size"
        disk[$i]=".:$other_size"
        if [[ $empty_size -gt $other_size ]]; then
          disk=("${disk[@]:0:$((j+1))}" ".:$((empty_size - other_size))" "${disk[@]:$((j+1))}")
        fi
        ((i++))
        break
      fi
    done
  done
}

checksum() {
  LEN=${#disk[@]}
  j=0
  for ((i=0; i<LEN; i++)); do
    node="${disk[$i]}"
    ID="${node%:*}"
    COUNT="${node#*:}"
    while [[ $COUNT -gt 0 ]]; do
     if [[ $ID != '.' ]]; then
        echo "$j*$ID"
     fi
     ((j++))
     ((COUNT--))
    done
  done
}

defrag
checksum \
  | paste -sd+ \
  | bc
