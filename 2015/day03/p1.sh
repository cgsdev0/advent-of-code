#!/usr/bin/env bash

. ../../misc/vardump

declare -A house

FILE="$1"

x=0
y=0

((house[$x,$y]++))

while read -n1 c; do
  case "$c" in
    ^)
      ((y-=1))
      ;;
    v)
      ((y+=1))
      ;;
    '<')
      ((x-=1))
      ;;
   '>')
      ((x+=1))
      ;;
  esac
  ((house[$x,$y]++))
done < "$FILE"

arr=("${!house[@]}")
echo "${#arr[@]}"
