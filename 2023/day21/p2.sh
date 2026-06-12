#!/usr/bin/env bash

clear

CACHE_DIR=/tmp/day21
FILE=input.txt
STEPS=26501365

size=$(wc -l < $FILE | cut -d' ' -f2)
mid=$((size / 2 + 1))
mid2=$((mid - 1))
last=$((size - 1))

declare -A grid

load_grid() {
  r=0
  while IFS= read -r line; do
    c=0
    while read -n1 char; do
      if [[ "$char" == "S" ]]; then
        char=.
      fi
      grid["$r,$c"]=$char
      ((c++))
    done <<< "$line"
    ((r++))
  done < $FILE
}

mkdir -p $CACHE_DIR

function floodfill() {
  local -A grid
  load_grid
  local sr=$1
  local sc=$2
  local -a queue=()
  queue+=("0 $sr $sc")
  count=0
  count2=0
  biggest_step=0
  while [[ ${#queue[@]} -gt 0 ]]; do
    item=${queue[0]}
    queue=("${queue[@]:1}")
    read steps row col <<< "${item}"
    if [[ ${grid["$row,$col"]} != "." ]]; then
      continue
    fi
    if [[ $steps -gt $biggest_step ]]; then
      biggest_step=$steps
    fi
    remainder=$((steps % 2))
    if [[ $remainder -eq 0 ]]; then
      ((count2++))
      grid["$row,$col"]=,
    else
      ((count++))
      grid["$row,$col"]=O
    fi
    echo "$count $count2" > $CACHE_DIR/${sr}_${sc}_$steps
    ((steps++))
    queue+=("$steps $((row-1)) $col")
    queue+=("$steps $row $((col-1))")
    queue+=("$steps $((row+1)) $col")
    queue+=("$steps $row $((col+1))")
  done
  echo "$biggest_step" > $CACHE_DIR/${sr}_${sc}_MAX
}

function edge() {
  read c d < "$CACHE_DIR/${1}_${2}_${size}"
  echo "$d"
}

function filling() {
  read max < $CACHE_DIR/${mid2}_${mid2}_MAX
  read a b < $CACHE_DIR/${mid2}_${mid2}_${max}
  N=$(( (STEPS - (mid -1)) / size ))
  M=$(( N - 1 ))
  echo "($a * $M * $M + $b * $N * $N)"
}
function corner() {
  A=$(( (STEPS - (mid -1)) / size ))
  B=$(( A - 1 ))
  SA=$(( (3*size - 3) / 2 ))
  SB=$(( (size - 3) / 2 ))
  read c a < "$CACHE_DIR/${1}_${2}_$SA"
  read b d < "$CACHE_DIR/${1}_${2}_$SB"
  echo "($c*$B + $d*$A)"
}

# first, we warm up the cache
function warm_up() {
  # center grid
  floodfill $mid2 $mid2 &

  # edges
  floodfill ${mid2} 0 &
  floodfill 0 ${mid2} &
  floodfill ${last} ${mid2} &
  floodfill ${mid2} ${last} &

  # corners
  floodfill 0 0 &
  floodfill 0 ${last} &
  floodfill ${last} 0 &
  floodfill ${last} ${last} &

  for job in $(jobs -p); do
    wait $job
  done
}
warm_up

function compute() {
  filling
  edge ${mid2} 0
  edge 0 ${mid2}
  edge ${last} ${mid2}
  edge ${mid2} ${last}
  corner 0 0
  corner 0 ${last}
  corner ${last} 0
  corner ${last} ${last}
}
compute

compute \
  | paste -sd+ \
  | bc
