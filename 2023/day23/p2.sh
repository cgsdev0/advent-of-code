#!/usr/bin/env bash

FILE=sample.txt

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

function scan() {
  local dir=$1
  local row=$2
  local col=$3
  case "$dir" in
    S)
      ((row++))
      while [[ $row -lt $size ]]; do
        if [[ ${grid["$row,$col"]} != "#" ]]; then
          return 1
        fi
        ((row++))
      done
      ;;
    N)
      ((row--))
      while [[ $row -lt $size ]]; do
        if [[ ${grid["$row,$col"]} != "#" ]]; then
          return 1
        fi
        ((row--))
      done
      ;;
    W)
      ((col++))
      while [[ $col -lt $size ]]; do
        if [[ ${grid["$row,$col"]} != "#" ]]; then
          return 1
        fi
        ((col++))
      done
      ;;
  esac
  return 0
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
    if [[ "$dir" == Z ]] && scan W $row $col; then
      echo "TRIMMING north"
    else
      add_option "$((row-1)),$col" N
    fi
    if [[ "$dir" == Z ]]; then
      if scan N $row $col || scan S $row $col; then
        echo "TRIMMING east"
      else
        add_option "$row,$((col-1))" E
      fi
    else
      add_option "$row,$((col-1))" E
    fi
    add_option "$((row+1)),$col" S
    add_option "$row,$((col+1))" W
    queue+=("${options[@]}")
  done
done

visited=()
target="$((size-1)),$((size-2))"

function debug() {
  echo "$@" 1>&2
}
biggest=0
function visit() {
  local item="${1}"
  local row col d dist direction
  IFS=, read row col d <<< ${item}
  item="$row,$col"
  if [[ "$item" == "$target" ]]; then
    if [[ $d -gt $biggest ]]; then
      biggest=$d
      echo $d
    fi
    return
  fi
  if [[ ! -z ${visited[$item]} ]]; then
    return
  fi

  visited[$item]=1
  while IFS=, read row col dist direction; do
    [[ "$row" == "" ]] && continue
    local new_dist=$((dist+d))
    visit "$row,$col,$new_dist"
  done <<< "${edges[$item]}"
  visited[$item]=
}

visit 0,1,0
