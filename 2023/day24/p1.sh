#!/usr/bin/env bash

clear
FILE=input.txt

function permute() {
  local -a hailstone
  while IFS= read -r line; do
    hailstone+=("$line")
  done
  local len=${#hailstone[@]}
  local i
  for ((i=0; i<len; i++)); do
    for ((j=i+1; j<len; j++)); do
      echo "${hailstone[i]} ${hailstone[j]}"
    done
  done
}

BOX_A=200000000000000
BOX_B=400000000000000
# BOX_A=7
# BOX_B=27
function intersections() {
  while read a b; do
    IFS=, read ax ay avx avy <<< $a
    IFS=, read bx by bvx bvy <<< $b
    echo "scale=10; x=((($bvy*$bx/$bvx)-($avy*$ax/$avx)+$ay-$by) / (($bvy/$bvx)-($avy/$avx))); y=($avy/$avx*(x-$ax)+$ay); (x<$bx&&$bvx>0)+(x>$bx&&$bvx<0)+(x<$ax&&$avx>0)+(x>$ax&&$avx<0)+(x<$BOX_A)+(y<$BOX_A)+(x>$BOX_B)+(y>$BOX_B)"
  done
}

cat $FILE \
  | tr '@' ',' \
  | tr -d ' ' \
  | cut -d',' -f1,2,4,5 \
  | permute \
  | intersections \
  | bc \
  | grep -c '^0$'
