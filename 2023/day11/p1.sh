#!/usr/bin/env bash

clear

FILE=input.txt

function transpose() {
  awk '{
    split($0, chars, "")
    for(j=1; j<=length(chars); j++) {
      idx=(j)
      a[idx]=a[idx]chars[j]
    }
  }
  END{ for (i=1; i<=NR; i++) print a[i] }
    '
}

function expand_universe() {
  local line
  while IFS= read -r line; do
    if ! grep -q "#" <<< $line; then
      echo $line
    fi
    echo $line
  done
}

function galaxy_list() {
  local line
  local char
  local row=0
  local col=0
  while IFS= read -r line; do
    col=0
    while read -n1 char; do
      if [[ "$char" == "" ]]; then
        continue
      fi
      if [[ "$char" == "#" ]]; then
        echo "$row,$col"
      fi
      ((col++))
    done <<< "$line"
    ((row++))
  done
}

function permute() {
  local -a galaxies
  while IFS= read -r line; do
    galaxies+=("$line")
  done
  local len=${#galaxies[@]}
  local i
  for ((i=0; i<len; i++)); do
    for ((j=i+1; j<len; j++)); do
      echo "${galaxies[i]} ${galaxies[j]}"
    done
  done
}

function distance() {
  (echo 'define abs(i) {
    if (i < 0) return (-i)
    return (i)
  }'; sed 's/^\([^,]\+\),\([^ ]\+\) \([^,]\+\),\(.*\)$/abs(\1-\3)+abs(\2-\4)/') \
    | bc
}

function sum() {
  paste -sd+ \
    | bc
}

cat $FILE \
  | expand_universe \
  | transpose \
  | expand_universe \
  | transpose \
  | galaxy_list \
  | permute \
  | distance \
  | sum
