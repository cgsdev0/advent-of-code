#!/bin/bash

. ../../misc/vardump

FILE="$1"
FILE=input.txt

count=0
i=0
while read -n 1 c; do
  ((++i))
  case "$c" in
    ')')
      ((count--))
      if [[ $count -lt 0 ]]; then
        echo $i
        exit 0
      fi
      ;;
    '(')
      ((count++))
      ;;
  esac
done < $FILE
