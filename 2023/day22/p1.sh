#!/usr/bin/env bash

clear

FILE=input.txt

declare -A bricks
function save_brick() {
  local id=$1
  local layer=$2
  local x1=$3
  local y1=$4
  local x2=$5
  local y2=$6
  new_brick="$id,$x1,$y1,$x2,$y2"
  if [[ -z "${bricks[$layer]}" ]]; then
    bricks[$layer]=$new_brick
  else
    bricks[$layer]="${bricks[$layer]}
$new_brick"
  fi
  echo "$id saved"
}

function debug() {
  echo "$@" 1>&2
}

function check_1d() {
  local x1=$1
  local x2=$2
  local x3=$3
  local x4=$4
  if [[ $x1 -ge $x3 ]] && \
    [[ $x1 -le $x4 ]]; then
    return 0
  fi
  if [[ $x2 -ge $x3 ]] && \
    [[ $x2 -le $x4 ]]; then
    return 0
  fi
  if [[ $x1 -lt $x3 ]] && \
    [[ $x2 -gt $x4 ]]; then
    return 0
  fi
  return 1
}
function check_intersects() {
  local layer=$1
  local x1=$2
  local y1=$3
  local x2=$4
  local y2=$5
  local x3 y3 x4 y4 id line
  while IFS= read -r line; do
    IFS=, read id x3 y3 x4 y4 <<< "${line}"
    [[ "$id" == "" ]] && continue
    if check_1d $x1 $x2 $x3 $x4 \
      && check_1d $y1 $y2 $y3 $y4; then
      echo "$id"
    fi
  done <<< "${bricks[$layer]}"
}

declare -A deps
id=0
while read x1 y1 z1 x2 y2 z2; do
  # drop a brick
  fall_dist=0
  while [[ $z1 -gt 1 ]]; do
    bricks=$(check_intersects $((z1-1)) $x1 $y1 $x2 $y2)
    if [[ ! -z "$bricks" ]]; then
      deps[$id]=$bricks
      break
    fi
    ((z1--))
    ((fall_dist++))
  done
  z2=$((z2-fall_dist))
  save_brick $id $z2 $x1 $y1 $x2 $y2
  ((id++))
done < <(cat $FILE \
  | tr '~,' ' ' \
  | sort -nk3)

UNSAFE=$(for i in "${!deps[@]}";do printf "%s=%s\n" "$i" "${deps[$i]//
/,}";done \
  | grep -v ',' \
  | cut -d'=' -f2 \
  | sort -u \
  | wc -l)

echo $((id - UNSAFE))
