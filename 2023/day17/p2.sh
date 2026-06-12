#!/usr/bin/env bash

clear
FILE=input.txt

declare -a grid
while read -r line; do
  grid+=($line)
done < $FILE

declare -a priority_queue

enqueue() {
    local value=$1
    priority_queue+=("$value")
    heapify_up
}

enqueue_if_missing() {
    local key=$1
    local priority=$2
    local size=${#priority_queue[@]}
    for ((i=0; i<size; i++)); do
      if [[ ${priority_queue[i]%,*} == $key ]]; then
        return
      fi
    done
    enqueue $key,$priority
}

dequeue() {
    local size=${#priority_queue[@]}
    if [ $size -eq 0 ]; then
        echo "Priority queue is empty"
        return 1
    fi

    front=${priority_queue[0]%,*}
    priority_queue=("${priority_queue[@]:1}")
    heapify_down
}

heapify_up() {
    local index=$(( ${#priority_queue[@]} - 1 ))

    while [ $index -gt 0 ]; do
        local parent_index=$(( ($index - 1) / 2 ))
        parent="${priority_queue[$parent_index]##*,}"
        self="${priority_queue[$index]##*,}"
        if [ $self -lt $parent ]; then
            local temp=${priority_queue[$index]}
            priority_queue[$index]=${priority_queue[$parent_index]}
            priority_queue[$parent_index]=$temp

            index=$parent_index
        else
            break
        fi
    done
}

heapify_down() {
  local index=0
  local size=${#priority_queue[@]}

  while true; do
      local left_idx=$((2 * index + 1))
      local right_idx=$((2 * index + 2))
      local smallest_idx=$index

      local left="${priority_queue[$left_idx]##*,}"
      local smallest="${priority_queue[$smallest_idx]##*,}"
      local right="${priority_queue[$right_idx]##*,}"

      if [ "$left_idx" -lt "$size" ] && [ $left -lt $smallest ]; then
          smallest_idx=$left_idx
      fi
      if [ "$right_idx" -lt "$size" ] && [ $right -lt $smallest ]; then
          smallest_idx=$right_idx
      fi

      if [ "$smallest_idx" -ne "$index" ]; then
          local temp=${priority_queue[$index]}
          priority_queue[$index]=${priority_queue[$smallest_idx]}
          priority_queue[$smallest_idx]=$temp

          index=$smallest_idx
      else
          break
      fi
  done
}

width=${#grid[0]}
height=$(wc -l < $FILE | cut -d' ' -f2)
target=$((height-1)),$((width-1))
echo "TARGET: $target"

function compute_cost() {
  local ur=$1
  local uc=$2
  local vr=$3
  local vc=$4

  dr=$((vr-ur))
  dc=$((vc-uc))
  if [[ $dr -gt 0 ]]; then
    ((dr/=dr))
  fi
  if [[ $dr -lt 0 ]]; then
    ((dr/=-dr))
  fi
  if [[ $dc -gt 0 ]]; then
    ((dc/=dc))
  fi
  if [[ $dc -lt 0 ]]; then
    ((dc/=-dc))
  fi
  cost=0
  while [[ $vr -ne $ur ]] || [[ $vc -ne $uc ]]; do
    dist=${grid[$vr]:$vc:1}
    ((cost+=dist))
    ((vr-=dr))
    ((vc-=dc))
  done
}

# do A* pathfinding
enqueue V,0,0,0
enqueue H,0,0,0
declare -A cameFrom
declare -A gScore
declare -A fScore
for layer in V H; do
  for ((r=0; r<height; r++)); do
    for ((c=0; c<width; c++)); do
      v="$layer,$r,$c"
      if [[ $r -eq 0 ]] && [[ $c -eq 0 ]]; then
        gScore[$v]=0
      else
        gScore[$v]=1000000000
      fi
    done
  done
done

while [[ ${#priority_queue[@]} -gt 0 ]]; do
  dequeue
  current=${front#*,}

  u=$front
  IFS=, read ul ur uc <<< "$u"
  # like a good neighbor...
  for v in \
    "H,$((ur-4)),$uc,U" \
    "H,$((ur-5)),$uc,U" \
    "H,$((ur-6)),$uc,U" \
    "H,$((ur-7)),$uc,U" \
    "H,$((ur-8)),$uc,U" \
    "H,$((ur-9)),$uc,U" \
    "H,$((ur-10)),$uc,U" \
    "H,$((ur+4)),$uc,D" \
    "H,$((ur+5)),$uc,D" \
    "H,$((ur+6)),$uc,D" \
    "H,$((ur+7)),$uc,D" \
    "H,$((ur+8)),$uc,D" \
    "H,$((ur+9)),$uc,D" \
    "H,$((ur+10)),$uc,D" \
    "V,$ur,$((uc-4)),L" \
    "V,$ur,$((uc-5)),L" \
    "V,$ur,$((uc-6)),L" \
    "V,$ur,$((uc-7)),L" \
    "V,$ur,$((uc-8)),L" \
    "V,$ur,$((uc-9)),L" \
    "V,$ur,$((uc-10)),L" \
    "V,$ur,$((uc+4)),R" \
    "V,$ur,$((uc+5)),R" \
    "V,$ur,$((uc+6)),R" \
    "V,$ur,$((uc+7)),R" \
    "V,$ur,$((uc+8)),R" \
    "V,$ur,$((uc+9)),R" \
    "V,$ur,$((uc+10)),R"; \
  do
    IFS=, read vl vr vc d <<< "$v"
    v=$vl,$vr,$vc
    if [[ $vr -lt 0 ]] || [[ $vc -lt 0 ]]; then
      continue
    fi
    if [[ $vr -ge $height ]] || [[ $vc -ge $width ]]; then
      continue
    fi
    if [[ "$ul" == "$vl" ]]; then
      continue
    fi
    compute_cost $ur $uc $vr $vc
    tentative_gScore=${gScore[$u]}
    ((tentative_gScore+=cost))
    if [[ $tentative_gScore -lt ${gScore[$v]} ]]; then
      cameFrom[$v]=$u
      gScore[$v]=$tentative_gScore
      fScore[$v]=$((tentative_gScore + vr * vc))
      enqueue_if_missing $v ${fScore[$v]}
    fi
  done
done

# find solutions
for level in V H; do
  declare -a sequence
  sequence=()
  u=$level,$target
  if [[ ! -z ${cameFrom[$u]} ]]; then
    while [[ ! -z "$u" ]]; do
      sequence=("$u" "${sequence[@]}")
      u=${cameFrom[$u]}
    done
  fi
  counter=0
  prev=$level,0,0
  for cell in "${sequence[@]:1}"; do
    IFS=, read vl vr vc <<< "$cell"
    IFS=, read ul ur uc <<< "$prev"
    compute_cost $ur $uc $vr $vc
    ((counter+=cost))
    prev=$cell
  done
  echo "$counter"
done
