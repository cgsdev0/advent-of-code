#!/usr/bin/env bash

clear

FILE=input.txt
function rotate() {
  awk '{
    split($0, chars, "")
    for(j=1; j<=length(chars); j++) {
      idx=(j)
      a[idx]=a[idx]chars[j]
    }
  }
  END{ for (i=1; i<=length(a); i++) print a[i] }
    '
}

function debug() {
  return
  echo "$@" 1>&2
}

function solve_line() {
  local len=${#1}
  local i
  # debug
  # debug
  # debug "$1"
  for ((i=0; i<=((len-2)); i++)); do
    LEFT=${1:0:((i+1))}
    RIGHT=${1:((i+1))}
    if [[ ${#RIGHT} -gt ${#LEFT} ]]; then
      local trim=${#LEFT}
      RIGHT=${RIGHT:0:trim}
    fi
    if [[ ${#LEFT} -gt ${#RIGHT} ]]; then
      local rtrim=${#RIGHT}
      local ltrim=${#LEFT}
      local trim=$((ltrim-rtrim))
      LEFT=${LEFT:trim}
    fi
    debug "LEFT:  $LEFT"
    debug "RIGHT: $RIGHT"
    LEFT="$(echo "$LEFT" | rev)"
    if [[ "$LEFT" == "$RIGHT" ]]; then
      debug "----- $((i+1))"
      echo "$((i+1))"
    fi
  done
}

function solve() {
  local line
  local row=0
  while IFS= read -r line; do
    debug "$line"
    solve_line "$line"
  done \
    | sort -n \
    | uniq -c \
    | sed 's/^ *//g' \
    | grep "^$(($1-1)) " \
    | cut -d' ' -f2 \
    | sed "s/\$/*$2/g"
}

lines=""
height=1
while IFS= read -r line; do
  if [[ "$line" == "" ]]; then
    solve $height 1 <<< "$lines"
    solve $width 100 < <(echo "$lines" | rotate)
    lines=""
    height=1
  fi
  if [[ -z "$lines" ]]; then
    lines="$line"
    width="${#line}"
  else
  lines="$lines
$line"
  ((height++))
  fi
done < $FILE \
  | tee /dev/fd/2 \
  | paste -sd+ \
  | bc
