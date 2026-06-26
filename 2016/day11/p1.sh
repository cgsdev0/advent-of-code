#!/usr/bin/env bash

. ../../misc/vardump

FILE="$1"

floor=0
declare -A visited

declare -A map

while IFS= read -r line; do
  if [[ ${line// /} == "" ]]; then
    ((floor++))
    continue
  fi
  map[${line// /_}]=$floor
done < <(tr -d ',.' < "$FILE" \
   | sed 's/ a /\n/g' \
   | sed 's/^.* contains//' \
   | sed 's/generator/G/' \
   | sed 's/microchip/M/' \
   | sed 's/-compatible//' \
   | sed 's/nothing relevant//' \
   | sed 's/ and//')

E=1
debug() {
  local key
  echo "Elevator: $E"
  for key in "${!map[@]}"; do
    echo "$key=${map[$key]}"
  done
  echo
}

move() {
  local dir=$1
  local what1=$2
  local what2=$3
  if [[ -n "$what1" ]]; then
    ((map[$what1]+=dir))
  fi
  if [[ -n "$what2" ]]; then
    ((map[$what2]+=dir))
  fi
  ((E+=dir))
}

hash_state() {
  hash="E=$E"
  for key in "${!map[@]}"; do
    hash="$hash;map[$key]=${map[$key]}"
  done
}

hash_move() {
  local dir=$1
  local next=$((dir+E))
  local what1=$2
  local what2=$3

  local t1 t2
  [[ -n "$what1" ]] && t1="${map[$what1]}"
  [[ -n "$what2" ]] && t2="${map[$what2]}"

  [[ -n "$what1" ]] && ((map[$what1]+=dir))
  [[ -n "$what2" ]] && ((map[$what2]+=dir))

  hash="E$E;$dir;${what1##*_};${what2##*_};"
  local key
  for key in "${!map[@]}"; do
    hash="$hash;${key##*_};${map[$key]}"
  done
  # reset state
  [[ -n "$what1" ]] && map[$what1]=$t1
  [[ -n "$what2" ]] && map[$what2]=$t2
}

filter_move() {
  local dir=$1
  local next=$((dir+E))
  local what1=$2
  local what2=$3
  hash_move $dir $what1 $what2
  local h=$hash
  if [[ -n "${visited[$h]}" ]]; then
    return
  fi
  if [[ -n "$what1" ]]; then
    if [[ "${map[$what1]}" != "$E" ]]; then
      return
    fi
  fi
  if [[ -n "$what2" ]]; then
    if [[ "${map[$what2]}" != "$E" ]]; then
      return
    fi
  fi

  local t1 t2
  [[ -n "$what1" ]] && t1="${map[$what1]}"
  [[ -n "$what2" ]] && t2="${map[$what2]}"

  [[ -n "$what1" ]] && ((map[$what1]+=dir))
  [[ -n "$what2" ]] && ((map[$what2]+=dir))

  local good=1
  local -A gens
  local g=0
  local key
  for key in "${!map[@]}"; do
    if [[ "${map[$key]}" == "$next" ]]; then
      if [[ "$key" == *"_G" ]]; then
        ((g++))
        gens[${key%_G}]=1
      fi
    fi
  done
  if [[ "$what1" == *"_M" ]]; then
    if [[ -z ${gens[${what1%_M}]} ]]; then
      if [[ $g -gt 0 ]]; then
        good=0
      fi
    fi
  fi
  if [[ "$what2" == *"_M" ]]; then
    if [[ -z ${gens[${what2%_M}]} ]]; then
      if [[ $g -gt 0 ]]; then
        good=0
      fi
    fi
  fi

  # reset state
  [[ -n "$what1" ]] && map[$what1]=$t1
  [[ -n "$what2" ]] && map[$what2]=$t2

  if [[ $good -eq 1 ]]; then
    echo "$@"
  fi
}

valid_moves() {
  local dir
  for dir in 1 -1; do
    local dest=$((E+dir))
    if [[ $dest -gt 4 ]] || [[ $dest -le 0 ]]; then
      continue
    fi
    local key
    for key1 in "${!map[@]}"; do
      if [[ "${map[$key1]}" == "$E" ]]; then
        for key2 in "${!map[@]}"; do
          [[ $key2 == $key1 ]] && break
          if [[ "${map[$key2]}" == "$E" ]]; then
            filter_move $dir $key1 $key2
          fi
        done
        filter_move $dir $key1
      fi
    done
  done
}

# move 1 "lithium_M"
# debug

solved() {
  local key
  for key in "${!map[@]}"; do
    if [[ ${map[$key]} != 4 ]]; then
      return 1
    fi
  done
  return 0
}

queue=()
states=()

s=0

restore_state() {
  local sid=$1
  eval "${states[$sid]}"
}

depth=0
echo "$hash"
while ! solved; do
  valid=${ valid_moves; }
  hash_state
  states[$s]=$hash
  while IFS= read -r dir what1 what2; do
    queue+=("$s $((depth+1)) $dir $what1 $what2")
  done <<< "$valid"
  ((s++))
  next=${queue[0]}
  queue=("${queue[@]:1}")
  read -r sid depth dir what1 what2 <<< "$next"
  restore_state "$sid"
  hash_move $dir $what1 $what2
  visited["$hash"]=1
  move $dir $what1 $what2
done
echo "$depth"
