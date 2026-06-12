#!/usr/bin/env bash

function parse() {
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

parse < input.txt \
  | sort -n \
  | head -n1
