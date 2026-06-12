#!/usr/bin/env bash

clear

FILE=input.txt

declare -a grid
declare -A visited

function idx() {
  if [[ $1 -lt 0 ]]; then
    return
  fi
  if [[ $2 -lt 0 ]]; then
    return
  fi
  row="${grid[$1]}"
  echo ${row:$2:1}
}

function check_down() {
  local row=$1
  local col=$2
  local next=$(idx $((row+1)) $col)
  local here=$(idx $row $col)
  if [[ $here != "S" ]] \
    && [[ $here != "|" ]] \
    && [[ $here != "F" ]] \
    && [[ $here != "7" ]]; then
    return
  fi
  if [[ $next != "J" ]] \
    && [[ $next != "|" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "L" ]]; then
    return
  fi
  echo "up" "down" $((row+1)) $col
}
function check_up() {
  local row=$1
  local col=$2
  local next=$(idx $((row-1)) $col)
  local here=$(idx $row $col)
  if [[ $here != "S" ]] \
    && [[ $here != "|" ]] \
    && [[ $here != "J" ]] \
    && [[ $here != "L" ]]; then
    return
  fi
  if [[ $next != "F" ]] \
    && [[ $next != "|" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "7" ]]; then
    return
  fi
  echo "down" "up" $((row-1)) $col
}
function check_right() {
  local row=$1
  local col=$2
  local next=$(idx $row $((col+1)))
  local here=$(idx $row $col)
  if [[ $here != "S" ]] \
    && [[ $here != "-" ]] \
    && [[ $here != "L" ]] \
    && [[ $here != "F" ]]; then
    return
  fi
  if [[ $next != "J" ]] \
    && [[ $next != "-" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "7" ]]; then
    return
  fi
  echo "left" "right" $row $((col+1))
}
function check_left() {
  local row=$1
  local col=$2
  local next=$(idx $row $((col-1)))
  local here=$(idx $row $col)
  if [[ $here != "S" ]] \
    && [[ $here != "-" ]] \
    && [[ $here != "J" ]] \
    && [[ $here != "7" ]]; then
    return
  fi
  if [[ $next != "L" ]] \
    && [[ $next != "-" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "F" ]]; then
    return
  fi
  echo "right" "left" $row $((col-1))
}

sr=0
sc=0
r=0
while IFS= read -r line; do
  echo "$line" | sed 's/7/┑/g;s/F/┏/g;s/L/┗/g;s/J/┙/g'
  grid+=("$line")
  c=0
  while read -n1 char; do
    if [[ "$char" == "S" ]]; then
      sc=$c
      sr=$r
    fi
    ((c++))
  done <<< "$line"
  ((r++))
done < $FILE

last=NA
function move() {
  current=$(idx $row $col)
  if [[ $last != "NA" ]] && [[ $current == "S" ]]; then
    state=done
    return
  fi
  next=$( (check_left $row $col
  check_right $row $col
  check_up $row $col
  check_down $row $col) \
    | grep -v "^$last " \
    | head -n1)
  read garbage last row col <<< "$next"
}

row=$sr
col=$sc

state=moving
count=0
while [[ $state != "done" ]]; do
  move
  ((count++))
done

echo "$((count/2))"
