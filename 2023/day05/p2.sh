#!/usr/bin/env bash

FILE=input.txt

function sort_map() {
  local IFS=
  local line
  while read -r line; do
    printf "%s" "$line" \
      | tr '|' '\n' \
      | sort -n \
      | paste -sd'|'
    echo
  done
}

function range_intersection() {
  local ad as al bd bs bl change
  read ad as al <<< "$1"
  read bd bs bl <<< "$2"
  ae=$((as+al-1))
  be=$((bd+bl-1))
  if [[ $ae -gt $be ]] && [[ $as -gt $be ]]; then
    return
  fi
  if [[ $as -lt $bd ]] && [[ $ae -lt $bd ]]; then
    return
  fi
  if [[ $bd -lt $as ]]; then
    change=$((as-bd))
    bd=$as
    ((bs+=change))
  fi
  if [[ $be -gt $ae ]]; then
    be=$ae
  fi
  bl=$((be-bd+1))
  echo "$bd $bs $bl"
}

function tree_level() {
  echo ${tree[$1]} | tr '|' '\n' | sort -n
}
function parse() {
  IFS= read -r line
  seeds=$(echo $line \
    | cut -d' ' -f2- \
    | sed 's/ /\n/g' \
    | paste -s -d' \n' \
    | sed 's/\([0-9]\+\) \([0-9]\+\)/\1 0 \2/g')


  IFS= read -r line

  levels=$(grep -v ':' \
    | sed ':a;N;$!ba;s/\n\n/@/g;s/\n/|/g;s/@/\n/g' \
    | tac \
    | sort_map)

  declare -a tree
  i=0
  while IFS= read -r level; do
    if [[ $i -eq 0 ]]; then
      local ptr=0
      level="$(while IFS= read -r fun; do
        local ad as al
        read ad as al <<< "$fun"
        if [[ $ptr -lt $ad ]]; then
          echo "$ptr $ptr $((ad-ptr))"
        fi
        ptr=$((ad+al))
        echo "$fun"
      done < <(echo "$level" | tr '|' '\n') \
        | paste -sd'|')"
    fi
    tree[$i]=$level
    ((i+=1))
  done <<< "${levels}"

  depth=$i

  do_the_thing 0 <<< "$(tree_level 0)"
}

function printl() {
  local indent=$1
  printf "%*s" $indent "" 1>&2
  shift
  printf "%s\n" "$*" 1>&2
}

function do_the_thing() {
  local i=$1
  local range
  local j
  if [[ $i -eq $depth ]]; then
    local seed
    while IFS= read -r range; do
      while IFS= read -r seed; do
        range_intersection "$range" "$seed"
      done <<< "${seeds}"
    done
    return
  fi
  while IFS= read -r range; do
    j=$((i+1))
    local dest_start
    local start
    local len
    read dest_start start len <<< "$range"
    local end=$((start+len))
    # printl $((i*2)) $dest_start $start $len
    local output
    local range2
    output=$(while IFS= read -r range2; do
      range_intersection "$range" "$range2"
    done <<< $(tree_level $j) \
      | sort -n)
    local -a new_ranges
    new_ranges=()
    local ptr=$start
    local rng
    while IFS= read -r rng; do
      if [[ "$rng" == "" ]]; then
        continue
      fi
      local nd
      local ns
      local nl
      read nd ns nl <<< "$rng"
      if [[ $ptr -ne $nd ]]; then
        new_ranges+=("$ptr $ptr $((end-ptr))")
      fi
      new_ranges+=("$rng")
      ptr=$((nd+nl))
    done <<< "${output}"
    if [[ $ptr -ne $end ]]; then
      new_ranges+=("$ptr $ptr $((end-ptr))")
    fi
    local input
    local idk
    input=$(for idk in "${new_ranges[@]}"; do
      echo "$idk"
    done)
    do_the_thing $j <<< "${input}"
  done
}

function parse_p1() {
  local IFS=
  read -r line
  seeds=$(echo $line \
    | cut -d' ' -f2- \
    | sed 's/ /\n/g')


  read -r line

  translators=$(grep -v ':' \
    | sed ':a;N;$!ba;s/\n\n/@/g;s/\n/|/g;s/@/\n/g' \
    | sed 's/\([0-9]\+\) \([0-9]\+\) \([0-9]\+\)/(@>=\2\&\&@<(\2+\3))*(@-\2+\1)/g' \
    | tr '|' '+')

  while read -r seed; do
    while read -r translator; do
      translation=$(echo "$translator" \
        | sed "s/@/$seed/g" \
        | bc)
      if [[ "$translation" != "0" ]]; then
        seed=$translation
      fi
    done <<< "${translators}"
    echo $seed
  done <<< "${seeds}"
}

function p1() {
  parse_p1 \
    | sort -n \
    | head -n1
}


function find_good_guesses() {
  MY_LUCKY_PICKS="$(parse < $FILE \
    | cut -d' ' -f1 \
    | paste -sd' ')"
  echo "seeds: $MY_LUCKY_PICKS"
  cat $FILE \
    | tail +2
}

p1 < <(find_good_guesses)
