#!/usr/bin/env bash

FILE=input.txt

declare -a grid
declare -A visited

function idx() {
  local row
  if [[ $1 -lt 0 ]]; then
    unset ret
    return
  fi
  if [[ $2 -lt 0 ]]; then
    unset ret
    return
  fi
  row="${grid[$1]}"
  ret=${row:$2:1}
}

function check_down() {
  local row=$1
  local col=$2
  idx $((row+1)) $col
  local next=$ret
  idx $row $col
  local here=$ret
  if [[ $here != "S" ]] \
    && [[ $here != "|" ]] \
    && [[ $here != "F" ]] \
    && [[ $here != "7" ]]; then
    unset ret
    return
  fi
  if [[ $next != "J" ]] \
    && [[ $next != "|" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "L" ]]; then
    unset ret
    return
  fi
  ret="up down $((row+1)) $col"
}
function check_up() {
  local row=$1
  local col=$2
  idx $((row-1)) $col
  local next=$ret
  idx $row $col
  local here=$ret
  if [[ $here != "S" ]] \
    && [[ $here != "|" ]] \
    && [[ $here != "J" ]] \
    && [[ $here != "L" ]]; then
    unset ret
    return
  fi
  if [[ $next != "F" ]] \
    && [[ $next != "|" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "7" ]]; then
    unset ret
    return
  fi
  ret="down up $((row-1)) $col"
}
function check_right() {
  local row=$1
  local col=$2
  idx $row $((col+1))
  local next=$ret
  idx $row $col
  local here=$ret
  if [[ $here != "S" ]] \
    && [[ $here != "-" ]] \
    && [[ $here != "L" ]] \
    && [[ $here != "F" ]]; then
    unset ret
    return
  fi
  if [[ $next != "J" ]] \
    && [[ $next != "-" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "7" ]]; then
    unset ret
    return
  fi
  ret="left right $row $((col+1))"
}
function check_left() {
  local row=$1
  local col=$2
  idx $row $((col-1))
  local next=$ret
  idx $row $col
  local here=$ret
  if [[ $here != "S" ]] \
    && [[ $here != "-" ]] \
    && [[ $here != "J" ]] \
    && [[ $here != "7" ]]; then
    unset ret
    return
  fi
  if [[ $next != "L" ]] \
    && [[ $next != "-" ]] \
    && [[ $next != "S" ]] \
    && [[ $next != "F" ]]; then
    unset ret
    return
  fi
  ret="right left $row $((col-1))"
}

sr=0
sc=0
r=0
while IFS= read -r line; do
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
  idx $row $col
  current=$ret
  if [[ $last != "NA" ]] && [[ $current == "S" ]]; then
    state=done
    return
  fi
  check_left $row $col
  if [[ ! -z "$ret" ]] && [[ "${ret%% *}" != "$last" ]]; then
    next="$ret"
  else
  check_right $row $col
  if [[ ! -z "$ret" ]] && [[ "${ret%% *}" != "$last" ]]; then
    next="$ret"
  else
    check_up $row $col
    if [[ ! -z "$ret" ]] && [[ "${ret%% *}" != "$last" ]]; then
      next="$ret"
    else
    check_down $row $col
    if [[ ! -z "$ret" ]] && [[ "${ret%% *}" != "$last" ]]; then
      next="$ret"
    fi
    fi
  fi
  fi
  read garbage last row col <<< "$next"
  # echo "$last"
}

row=$sr
col=$sc

state=moving
declare -A visited
while [[ $state != "done" ]]; do
  move
  visited["$row $col"]=1
  ((count++))
done
row=0

for line in "${grid[@]}"; do
  col=0
  while read -n1 char; do
    case "$char" in
      "J")
        char=┘
        ;;
      "|")
        char=│
        ;;
      "-")
        char=─
        ;;
      "7")
        char=┐
        ;;
      "F")
        char=┌
        ;;
      "L")
        char=└
        ;;
    esac
    if [[ "${visited["$row $col"]}" ]]; then
      if [[ "$char" == "S" ]]; then
        printf "%s" "╋"
      else
        printf "%s" "$char"
      fi
    else
      printf "%s" "."
    fi
    ((col++))
  done <<< "$line"
  echo
  ((row++))

  # ok, now things are about to get REAL dank
  # 
  # for the readers at home, 'convert'
  # is a program called 'imagemagick'
done \
 | convert -background black -fill white \
  +antialias \
      -font "/home/sarah/.fonts/Hack Regular Nerd Font Complete Mono.ttf" \
      -pointsize 6 label:@- \
      -draw "color 0,0 floodfill" \
      -fill black \
      -draw "color 0,0 floodfill" \
      -define histogram:unique-colors=true \
      -format %c histogram:info:- \
      | grep white \
      | cut -d':' -f1 \
      | tr -d ' '
