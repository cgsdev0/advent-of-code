#!/bin/bash

FILE="$1"
mapfile -t junctions < "$FILE"
count=${#junctions[@]}

conns=1000
if [[ "$FILE" == "sample"* ]]; then
  conns=10
fi

find_closest() {
  local i j a b x1 x2 y1 y2 z1 z2 x y z
  for ((i=0; i<count; ++i)); do
    for ((j=i+1; j<count; ++j)); do
      [[ i -eq j ]] && continue
      a="${junctions[i]}"
      b="${junctions[j]}"
      IFS=, read x1 y1 z1 <<< "$a"
      IFS=, read x2 y2 z2 <<< "$b"
      x=$(((x1-x2)*(x1-x2)))
      y=$(((y1-y2)*(y1-y2)))
      z=$(((z1-z2)*(z1-z2)))
      echo $((x+y+z)) "$a" "$b"
    done
  done \
    | sort -n \
    | head -n $conns
}

declare -A graph
declare -a sizes
idx=0

connect() {
  local a=$1
  local b=$2
  if [[ -z ${graph[$a]} ]]; then
    graph[$a]="$b"
  else
    graph[$a]="${graph[$a]} $b"
  fi
}

while read a b; do
  connect $a $b
  connect $b $a
done < <(find_closest | cut -d' ' -f2-)

declare -A visited

walk() {
  local key=$1
  q=("$key")
  until [[ ${#q[@]} -eq 0 ]]; do
    node=${q[0]}
    q=(${q[@]:1})
    [[ -n "${visited[$node]}" ]] && continue
    visited[$node]=1
    ((sizes[idx]++))
    q+=(${graph[$node]})
  done
}

for key in ${!graph[@]}; do
  [[ -n "${visited[$key]}" ]] && continue
  walk $key
  ((idx++))
done

printf '%s\n' ${sizes[@]} \
  | sort -nr \
  | head -n 3 \
  | paste -sd'*' \
  | bc
