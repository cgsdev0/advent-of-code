#!/bin/bash

FILE="$1"

function detect_intersect() {
  local i=$1
  local j=$2
  read s1 e1 <<< ${ranges[i]}
  read s2 e2 <<< ${ranges[j]}
  if [[ s1 -ge s2 && s1 -le e2 ]]; then
    return 0
  fi
  if [[ e1 -ge s2 && e1 -le e2 ]]; then
    return 0
  fi
  if [[ s2 -ge s1 && s2 -le e1 ]]; then
    return 0
  fi
  if [[ e2 -ge s1 && e2 -le e1 ]]; then
    return 0
  fi
  return 1
}

function merge() {
  local i=$1
  local j=$2
  read s1 e1 <<< ${ranges[i]}
  read s2 e2 <<< ${ranges[j]}
  start=$s1
  if [[ $s2 -lt $start ]]; then
    start=$s2
  fi
  end=$e1
  if [[ $e2 -gt $end ]]; then
    end=$e2
  fi
  ranges[i]="$start $end"
  ranges[j]="$start $end"
}

function main() {
  declare -a ranges
  while IFS=- read start end; do
    [[ -z $end ]] && break
    ranges+=("$start $end")
    ((r++))
  done
  for ((i=0; i<r; ++i)); do
    for ((j=1; j<r; ++j)); do
      [[ i -eq j ]] && continue
      if detect_intersect $i $j; then
        merge $i $j
      fi
    done
  done

  for ((i=0; i<r; ++i)); do
    read s e <<< ${ranges[i]}
    echo "$e-$s+1"
  done | sort -u | bc | paste -sd+ | bc
}

main < "$FILE"
