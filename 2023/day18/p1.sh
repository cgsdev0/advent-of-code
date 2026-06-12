#!/usr/bin/env bash

clear

FILE=input.txt

function color_corners() {
  local prev=""
  local dir len color
  while read dir len color; do
    case "$prev$dir" in
      RD) corner=R ;;
      RU) corner=L ;;
      LD) corner=L ;;
      LU) corner=R ;;
      UR) corner=R ;;
      UL) corner=L ;;
      DR) corner=L ;;
      DL) corner=R ;;
      *) corner=R
    esac
    prev=$dir
    echo "$corner" "$dir" "$len" "$color"
  done
}

function modify_lengths() {
  local -a prev
  local -a first
  local corner dir len color
  while read corner dir len color; do
    if [[ ${#first[@]} -eq 0 ]]; then
      first=($corner $dir $len $color $len)
    fi
    case "${prev[0]}$corner" in
      RR) ((prev[2]--)) ;;
      LL) ((prev[2]++)) ;;
    esac
    [[ ${#prev[@]} -gt 0 ]] && echo "${prev[@]}"
    prev=($corner $dir $len $color $len)
  done
  case "${first[0]}${prev[0]}" in
    RR) ((prev[2]--)) ;;
    LL) ((prev[2]++)) ;;
  esac
  echo "${prev[@]}"
}

function weird_algorithm() {
  local a d1 l1 c1 L1 L2
  local d2 l2 c2
  local R fh fv
  local edges=0
  while read a d1 l1 c1 L1; do
    if [[ -z "$fh" ]]; then
      fh=$d1
    fi
    read a d2 l2 c2 L2;
    if [[ -z "$fv" ]]; then
      fv=$d2
    fi
    if [[ $d1 == $fh ]]; then
      ((R+=l1))
    else
      ((R-=l1))
    fi
    if [[ $d2 == $fv ]]; then
      echo "$R*$l2"
    else
      echo "$R*(-$l2)"
    fi
    ((edges+=L1+L2))
  done
  echo "-$edges"
}

cat $FILE \
  | color_corners \
  | modify_lengths \
  | weird_algorithm \
  | paste -sd+ \
  | bc
