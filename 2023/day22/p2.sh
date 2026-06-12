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
  | sort -nu)

declare -A inv
for ((i=0;i<1456;i++)); do
  while read dep; do
    [[ "$dep" == "" ]] && continue
    if [[ -z "${inv[$dep]}" ]]; then
      inv[$dep]=$i
    else
      inv[$dep]="${inv[$dep]}
$i"
  fi
  done <<< "${deps[$i]}"
done

function check_deps() {
  local item=$1
  local dep
  while read dep; do
    [[ "$dep" == "" ]] && continue;
    if [[ -z "${moved[$dep]}" ]]; then
      return 1
    fi
  done <<< "${deps[$item]}"
  return 0
}

function chain_reaction() {
  local -A moved=()
  local -A queued=()
  local curr=$1
  local start=$1
  local count=0
  moved[$curr]=1
  queued[$curr]=1
  local -a queue=()
  queue=("$curr")
  local item
  while [[ ${#queue[@]} -gt 0 ]]; do
    item="${queue[0]}"
    queue=("${queue[@]:1}")
    queued[$item]=
    if [[ $start == $item ]] || check_deps $item; then
      moved[$item]=1
      while read dep; do
        [[ "$dep" == "" ]] && continue;
        if [[ -z "${queued[$dep]}" ]]; then
          queue+=("$dep")
          queued[$dep]=1
        fi
      done <<< "${inv[$item]}"
    fi
  done
  count="${#moved[@]}"
  echo $((count-1))
}

for brick in $UNSAFE; do
  chain_reaction "$brick"
done \
  | paste -sd+ \
  | bc
