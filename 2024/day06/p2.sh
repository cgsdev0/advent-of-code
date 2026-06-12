#!/usr/bin/env bash

FILE="$1"

declare -A grid

x=0
y=0
mx=0
my=0
sx=0
sy=0
while IFS= read -r -n1 c; do
  if [[ "$c" == "" ]]; then
    ((y++))
    mx=$x
    x=0
    continue
  fi
  grid["$x,$y"]=$c
  if [[ "$c" == "^" ]]; then
    sx=$x
    sy=$y
  fi
  ((x++))
done < "$FILE"

my=$y

count=0

STUCK=0

step() {
  dx=0
  dy=0
  case "$dir" in
    U)
      dy=-1
      ;;
    L)
      dx=-1
      ;;
    R)
      dx=1
      ;;
    D)
      dy=1
      ;;
  esac

  nx=$((x+dx))
  ny=$((y+dy))
  if [[ "${grid[$nx,$ny]}" == "#" ]] || [[ $ox -eq $nx && $oy -eq $ny ]]; then
    case "$dir" in
      U)
        dir=R
        ;;
      R)
        dir=D
        ;;
      L)
        dir=U
        ;;
      D)
        dir=L
        ;;
    esac
    # does this matter?
    # if [[ -n ${visited[$x,$y,$dir]} ]]; then
    #   return 1
    # fi
    # visited["$x,$y,$dir"]=yup
    ((STUCK++))
    if [[ $STUCK -gt 4 ]]; then
      return 1
    fi
    return 0
  fi
  STUCK=0
  if [[ -n ${visited[$x,$y,$dir]} ]]; then
    return 1
  fi
  visited["$x,$y,$dir"]=yup
  ((x+=dx))
  ((y+=dy))
  return 0
}

check_for_loop() {
  local STUCK=0
  local -A visited

  ox=$1
  oy=$2
  c="${grid[$ox,$oy]}"
  if [[ c == "#" || c == "^" ]]; then
    return
  fi

  echo "Checking $ox $oy"
  # cat "$FILE"
  # echo "START: $sx $sy"

  dir=U
  local x=$sx
  local y=$sy


  until [[ $x -lt 0 || $y -lt 0 || $x -ge $mx || $y -ge $my ]]; do
    step
    if [[ $? -eq 1 ]]; then
      ((count++))
      return
    fi
  done
}

do_the_part1() {
  ox=-100
  oy=-100
  dir=U
  x=$sx
  y=$sy
  until [[ $x -lt 0 || $y -lt 0 || $x -ge $mx || $y -ge $my ]]; do
    step
  done
}

declare -A visited
do_the_part1
stuff=("${!visited[*]}")
coords="$(for coord in ${stuff[@]}; do
  echo "$coord"
done | cut -d, -f1-2 | sort -u)"
for coord in $coords; do
  x=${coord%,*}
  y=${coord##*,}
  check_for_loop $x $y
done
echo $count
