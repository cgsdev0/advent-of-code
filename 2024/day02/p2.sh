#!/usr/bin/env bash

FILE="$1"

split() {
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

safe=0
while IFS= read -r line; do
  split "$line" " "
  LEN="${#arr[@]}"
  for ((skip=0; skip<LEN; ++skip)); do
    unsafe=0
    idx=-1
    prev=
    sign=
    new_sign=
    for item in "${arr[@]}"; do
      ((idx++))
      [[ $idx -eq $skip ]] && continue
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
    if [[ $unsafe -eq 0 ]]; then
      ((safe++))
      break
    fi
  done
done < "$FILE"

echo $safe
