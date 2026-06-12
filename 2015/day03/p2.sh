#!/usr/bin/env bash

. ../../misc/vardump

declare -A house

FILE="$1"

x1=0
y1=0

x2=0
y2=0

flip=1

((house[0,0]++))

while read -n1 c; do
  if [ $flip -eq 1 ]; then
    flip=2
    declare -n x=x2
    declare -n y=y2
  else
    flip=1
    declare -n x=x1
    declare -n y=y1
  fi

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
