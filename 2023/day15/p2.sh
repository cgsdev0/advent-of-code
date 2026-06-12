#!/usr/bin/env bash

clear

FILE=$(pwd)/input.txt

DIR=/tmp/day15
rm -rf $DIR
mkdir $DIR

cd $DIR

function hash_label() {
  total=0
  label=${1%-*}
  label=${label%=*}
  while read -n1 char; do
    [[ "$char" == "" ]] && continue
    add=$(LC_CTYPE=C printf '%d' "'$char")
    total=$(((total+add) * 17 % 256))
  done <<< "$label"
}

while read -d, str; do
  hash_label "$str"
  box=$((total+1))
  touch $box
  if [[ "$str" =~ .*- ]]; then
      sed -i '/^'$label' .*$/d' $box
  elif [[ "$str" =~ .*=(.) ]]; then
    focal_length=${BASH_REMATCH[1]}
    if grep -q "^$label " $box; then
      sed -i 's/^\('$label'\) .*$/\1 '$focal_length'/' $box
    else
      echo "$label $focal_length" >> $box
    fi
  fi
done < "$FILE"

grep -no '[0-9]' * \
  | tr ':' '*' \
  | paste -sd+ \
  | bc
