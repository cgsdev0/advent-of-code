#!/usr/bin/env bash

set -o noglob


FILE=input.txt

function printl() {
  return
  local indent=$1
  printf "%*s" $indent "" 1>&2
  shift
  printf "%s\n" "$*" 1>&2
}

function descend() {
  local record="$1"
  local sizes="$2"
  local iter="$3"
  local sliced="$4"

  if [[ $iter -eq 0 ]]; then
    local left=${record//[^#]/}
    if [[ ${#left} -eq 0 ]]; then
      echo "------------"
    fi
    return
  fi

  # pop size from sizes
  local size="${sizes%%,*}"
  sizes="${sizes#*,}"

  if [[ -z "$record" ]]; then
    return
  fi
  printl $sliced $record $size "depth:$iter"


  local idx=0
  local char
  while read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi
    local slice="${record:idx:size}"
    if [[ ${#slice} -lt $size ]]; then
      return
    fi
    if [[ ${slice:0:1} == "." ]]; then
      ((idx++))
      continue
    fi
    group=${slice//[^?#]/}
    if [[ ${#group} -lt $size ]]; then
      if [[ "${slice:0:1}" == "#" ]]; then
        return
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
      return
    fi
    # wtf was the point of this? idk
    # check if we hit air
    # if [[ "${record:((idx+size)):1}" == "." ]]; then
    #   return
    # fi
    ((idx++))
  done <<< "$record"
}

while read record sizes; do
  maxdepth=${sizes//[^,]/}
  maxdepth=${#maxdepth}
  ((maxdepth++))
  descend "$record" "$sizes" "$maxdepth" 0 \
    | wc -l

done < "$FILE" \
  | paste -sd + \
  | bc
