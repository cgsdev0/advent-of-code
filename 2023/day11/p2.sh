#!/usr/bin/env bash

clear

FILE=input.txt
MULTIPLE=1000000

function transpose() {
  awk '{
    split($0, chars, "")
    for(j=1; j<=length(chars); j++) {
      idx=(j)
      a[idx]=a[idx]chars[j]
    }
  }
  END{ for (i=1; i<=NR; i++) print a[i] }
    '
}

function debug() {
  echo "$*" 1>&2
}

function expand_universe() {
  local -a e
  local direction=$1
  local idx=0
  local i
  local llen
  while IFS= read -r line; do
    if ! grep -q "#" <<< $line; then
        line=${line/\n/}
        llen=${#line}
        for ((i=idx; i<=llen; i++)); do
          if [[ -z "${e[$i]}" ]]; then
            e[$i]=0
          fi
          ((e[i]++))
        done
    fi
    ((idx++))
  done
  local val
  for ((i=0; i<llen; i++)); do
    val="${e[$i]}"
    echo ${val:-0}
  done
}


function distance() {
  (echo 'define abs(i) {
    if (i < 0) return (-i)
    return (i)
  }'; sed 's/^\([^,]\+\),\([^ ]\+\) \([^,]\+\),\(.*\)$/abs(\1-\3)+abs(\2-\4)/') \
    | bc
}

function sum() {
  paste -sd+ \
    | bc
}

declare -a erows
while IFS= read number; do
  erows+=("$number")
done < <(cat $FILE \
  | expand_universe)

declare -a ecols
while IFS= read number; do
  ecols+=("$number")
done < <(cat $FILE \
  | transpose \
  | expand_universe)

row=0
col=0
galaxy_list="$(while IFS= read -r line; do
  col=0
  while read -n1 char; do
    if [[ "$char" == "" ]]; then
      continue
    fi
    if [[ "$char" == "#" ]]; then
      echo "$row,$col"
    fi
    ((col++))
  done <<< "$line"
  ((row++))
done < "$FILE")"

function locate() {
  r=${1%,*}
  c=${1#*,}
  er=${erows[$r]}
  er=${er:-0}
  ec=${ecols[$c]}
  ec=${ec:-0}
  r=$((er*MULTIPLE+r-er))
  c=$((ec*MULTIPLE+c-ec))
  ret="$r,$c"
}
declare -a galaxies
while IFS= read -r line; do
  galaxies+=("$line")
done <<< "$galaxy_list"
len=${#galaxies[@]}
for ((i=0; i<len; i++)); do
  for ((j=i+1; j<len; j++)); do
    locate ${galaxies[i]}
    gi=$ret
    locate ${galaxies[j]}
    gj=$ret
    echo "$gi $gj"
  done
done \
  | distance \
  | sum
