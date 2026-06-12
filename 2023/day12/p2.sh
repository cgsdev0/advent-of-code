#!/usr/bin/env bash

# lmao, got me again
set -o noglob

FILE=input.txt

declare -A cache

# recursive hell
function descend() {
  local record="$1"
  local sizes="$2"
  local iter="$3"
  local sliced="$4"

  # base case
  if [[ $iter -eq 0 ]]; then
    local left=${record//[^#]/}
    if [[ ${#left} -eq 0 ]]; then
      ((counter++))
    fi
    return
  fi


  local key="$record $sizes"
  if [[ ! -z "${cache[$key]}" ]]; then
    # cache hit :)
    local cached=${cache[$key]}
    ((counter+=cached))
    return
  fi


  local counter_before=$counter
  # pop size from sizes
  local size="${sizes%%,*}"
  sizes="${sizes#*,}"

  if [[ -z "$record" ]]; then
    return
  fi

  local cost=${sizes//[,]/+}
  cost=$((cost))

  local idx=0
  local char
  while read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi

    local remainder=${record:idx}
    local budget="${remainder//[^#?]/}"
    budget=${#budget}
    # is this branch a financial disaster?
    if [[ $budget -lt cost ]]; then
      break
    fi

    local slice="${record:idx:size}"
    if [[ ${#slice} -lt $size ]]; then
      break
    fi
    if [[ ${slice:0:1} == "." ]]; then
      ((idx++))
      continue
    fi
    group=${slice//[^?#]/}
    if [[ ${#group} -lt $size ]]; then
      if [[ "${slice:0:1}" == "#" ]]; then
        break
      fi
      ((idx++))
      continue
    fi
    local peek="${record:((idx+size)):1}"
    if [[ "$peek" != "#" ]]; then
      local descendant="${record:((idx+size+1))}"
      descend "$descendant" "${sizes:-0}" "$((iter-1))" "$((sliced+idx+size+1))"
    fi
    # check if we hit obsidian
    if [[ "${slice:0:1}" == "#" ]]; then
      break
    fi
    ((idx++))
  done <<< "$record"

  # cache miss
  local change=$((counter-counter_before))
  cache[$key]=$change
}

function main() {
  while read record sizes; do
    record=${record}?${record}?${record}?${record}?${record}
    sizes=${sizes},${sizes},${sizes},${sizes},${sizes}
    maxdepth=${sizes//[^,]/}
    maxdepth=${#maxdepth}
    ((maxdepth++))
    counter=0
    descend "$record" "$sizes" "$maxdepth" 0
    echo $counter
  done
}

# gotta go fast
if [[ ! -z "$DONT_FORK_BOMB_ME_BRO" ]]; then
  main
else
  export DONT_FORK_BOMB_ME_BRO=true
  <$FILE parallel --pipe -N 100 $0 \
    | paste -sd+ \
    | bc
fi
