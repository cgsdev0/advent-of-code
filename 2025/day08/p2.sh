#!/bin/bash

. ../../misc/vardump

FILE="$1"
mapfile -t junctions < "$FILE"
count=${#junctions[@]}

CONN_CACHE="/tmp/connection-order-$FILE"
find_closest() {
  if [[ -f "$CONN_CACHE" ]]; then
    cat "$CONN_CACHE"
    return 0
  fi
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
    | tee "$CONN_CACHE"
}

declare -A graph
declare -a sizes
idx=0

declare -A sets
declare -A cigarettes # rhymes with 'sets'

main_set=1

move() {
  local key=$1
  local id=$2
  echo "moving $key to $id..." 1>&2
  sets[$key]=$id
  cigarettes[$id]="${cigarettes[$id]} $key"
  if [[ id -eq 1 ]]; then
    ((main_set++))
  fi
}

connect() {
  local a=$1
  local b=$2
  local id_a=${sets[$a]}
  local id_b=${sets[$b]}
  local smaller=$((id_a<id_b?id_a:id_b))
  local larger=$((id_a>id_b?id_a:id_b))
  if [[ smaller -eq larger ]]; then
    return
  fi
  sets[$a]=$smaller
  sets[$b]=$smaller

  local key
  for key in ${cigarettes[$larger]}; do
    move $key $smaller
  done
}


id=1
while read line; do
  sets[$line]=$id
  cigarettes[$id]="$line"
  ((id++))
done < "$FILE"

conns=0
while read a b; do
  echo "Connection #$conns..." 1>&2
  connect $a $b
  ((conns++))
  echo "Main set: $main_set" 1>&2
  [[ main_set -eq count ]] && break
done < <(find_closest | cut -d' ' -f2-)

IFS=, read x1 _ _ x2 _ <<< "$a,$b"
echo "$((x1*x2))"
