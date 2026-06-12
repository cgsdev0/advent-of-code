#!/usr/bin/env bash

clear

FILE=input.txt

function add_type() {
  while read card bid; do
    counts=$(while read -n1 c; do
      [[ "$c" == "" ]] && continue
      echo $c
    done <<< $card \
      | sort \
      | uniq -c \
      | sort -nr \
      | tr -s ' ' \
      | cut -d' ' -f2 \
      | paste -sd,)
    case $counts in
      "5")
        type=0
        ;;
      "4,"*)
        type=1
        ;;
      "3,2")
        type=2
        ;;
      "3,"*)
        type=3
        ;;
      "2,2,"*)
        type=4
        ;;
      "2,"*)
        type=5
        ;;
      *)
        type=6
        ;;
    esac
    echo $type $card $bid
  done
}

cat $FILE \
  | tr 'T' 'B' \
  | tr 'J' 'C' \
  | tr 'Q' 'D' \
  | tr 'K' 'E' \
  | tr 'A' 'F' \
  | add_type \
  | sort -k1nr -k2b \
  | cat -n \
  | tr '\t' ' ' \
  | tr -s ' ' \
  | cut -d' ' -f2,5 \
  | tr ' ' '*' \
  | bc \
  | paste -sd+ \
  | bc
