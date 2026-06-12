#!/usr/bin/env bash

FILE="$1"

split() {
   # Usage: split "string" "delimiter"
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

safe=0
while IFS= read -r line; do
  split "$line" " "
  unsafe=
  prev=
  sign=
  new_sign=
  for item in "${arr[@]}"; do
    if [[ ! -z "$prev" ]]; then
      new_diff=$((prev - item))
      abs_diff=${new_diff//-/}
      new_sign=${new_diff//[0-9]/}
      new_sign=${new_sign:-+}
      if [[ ! -z "$sign" && $new_sign != $sign ]]; then
        unsafe=1
      fi
      if [[ $abs_diff -lt 1 || $abs_diff -gt 3 ]]; then
        unsafe=1
      fi
    fi
    sign=$new_sign
    prev=$item
  done
  [[ -z $unsafe ]] && ((safe++))
done < "$FILE"

echo $safe
