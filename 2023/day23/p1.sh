#!/usr/bin/env bash

FILE=input.txt

size=$(wc -l < $FILE | cut -d' ' -f2)
y=0
x=0
declare -A grid
while read -r -n1 char; do
  if [[ "$char" == "" ]]; then
    ((y++))
    x=0
    continue
  fi
  grid["$y,$x"]="$char"
  ((x++))
done < "$FILE"

row=0
col=1
declare -a queue=()
declare -A visited


function add_option() {
  opt="$1"
  char=${grid[$opt]}
  case "$2$char" in
    "Nv") return ;;
    "S^") return ;;
    "E>") return ;;
    "W<") return ;;
  esac
  if [[ $char == "#" ]] || [[ "$char" == "" ]]; then
    return
  fi
  if [[ ! -z "$2" ]]; then
      opt="$opt,$2"
  fi
  options+=("$opt")
  ((optc++))
}

node_id=0
declare -A nodes
function add_node() {
  local row=$1
  local col=$2
  grid["$row,$col"]="F"
  nodes["$row,$col"]=$((node_id++))
}

add_node 0 1
add_node $((size-1)) $((size-2))

queue+=("$row,$col")
counter=0
while [[ ${#queue[@]} -gt 0 ]]; do
  item=${queue[0]}
  queue=("${queue[@]:1}")
  char=${grid[$item]}
  IFS=, read row col <<< "$item"
  if [[ ! -z ${visited[$item]} ]]; then
    continue
  fi
  if [[ $char == "#" ]] || [[ "$char" == "" ]]; then
    continue
  fi
  visited[$item]=1
  ((counter++))
  declare -a options=()
  optc=0
  add_option "$((row-1)),$col"
  add_option "$row,$((col-1))"
  add_option "$((row+1)),$col"
  add_option "$row,$((col+1))"
  if [[ $optc -gt 2 ]]; then
    add_node $row $col
  fi
  queue+=("${options[@]}")
done
echo $counter

for ((row=0; row<size; row++)); do
  for ((col=0; col<size; col++)); do
    # if [[ ! -z ${visited["$row,$col"]} ]]; then
    #   echo -n O
    # else
    #   echo -n "${grid["$row,$col"]}"
    # fi
    echo -n "${grid["$row,$col"]}"
  done
  echo
done

declare -A edges
function add_edge() {
  from=$1
  to=$2
  weight=$3
  dir=$4
  if [[ -z "${edges[$from]}" ]]; then
    edges[$from]="$to,$weight,$dir"
  else
    edges[$from]="${edges[$from]}
$to,$weight,$dir"
  fi
}

for node in "${!nodes[@]}"; do
  queue=("$node,Z")
  visited=()
  counter=0
  while [[ ${#queue[@]} -gt 0 ]]; do
    # DFS
    item=${queue[-1]}
    unset 'queue[-1]'
    IFS=, read row col dir <<< "$item"
    item="$row,$col"
    char=${grid[$item]}
    if [[ ! -z ${visited[$item]} ]]; then
      continue
    fi
    if [[ $char == F ]] && [[ $node != $item ]]; then
      echo "F $counter ($node) -> ($item)"
      add_edge $node $item $counter $dir
      counter=1
      continue
    fi
    if [[ $char == "#" ]] || [[ "$char" == "" ]]; then
      continue
    fi
    visited[$item]=1
    ((counter++))
    declare -a options=()
    optc=0
    add_option "$((row-1)),$col" N
    add_option "$row,$((col-1))" E
    add_option "$((row+1)),$col" S
    add_option "$row,$((col+1))" W
    queue+=("${options[@]}")
  done
done
# for i in "${!nodes[@]}"; do printf "%s=%s\n" "$i" "${nodes[$i]}";done

# one more BFS for the road
function topo_sort() {
  queue=("0,1")
  visited=()
  counter=0
  while [[ ${#queue[@]} -gt 0 ]]; do
    item=${queue[0]}
    queue=("${queue[@]:1}")
    echo "$item"
    if [[ ! -z ${visited[$item]} ]]; then
      continue
    fi
    visited[$item]=1
    while IFS=, read row col dist direction; do
      [[ "$row" == "" ]] && continue
      queue+=("$row,$col")
    done <<< "${edges[$item]}"
  done
}

declare -A length_to
declare -A path_to
for v in $(topo_sort); do
  echo $v
  while IFS=, read row col dist direction; do
    [[ "$row" == "" ]] && continue
    w="$row,$col"
    len=${length_to[$v]}
    len=${len:-0}
    new_dist=$((dist+len))
    if [[ -z "${length_to[$w]}" ]] || \
      [[ ${length_to[$w]} -lt $new_dist ]]; then
      path_to[$w]="${path_to[$v]}
$w,$dist,$direction"
      length_to[$w]=$new_dist
    fi
  done <<< "${edges[$v]}"
done
target=$((size-1)),$((size-2))
answer=${length_to[$target]}
declare -A visualize
while IFS=, read r c dist d; do
  [[ -z "$r" ]] && continue
  p="$r,$c"
  echo "P: $p $dist $d"
  visualize[$p]=$d
done <<< "${path_to[$target]}"
echo $answer
