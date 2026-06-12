#!/usr/bin/env bash

FILE="$1"

declare -A grid
declare -A visited

x=0
y=0
mx=0
my=0
sx=0
sy=0
dir=U
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

print_grid() {
  return
  clear
  local x
  local y
  for ((y=0; y<$my; y++)); do
    for ((x=0; x<$mx; x++)); do
      printf "%s" "${grid[$x,$y]}"
    done
    printf "\n"
  done
}

# cat "$FILE"
print_grid
# echo "START: $sx $sy"

x=$sx
y=$sy
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
  if [[ "${grid[$nx,$ny]}" == "#" ]]; then
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
    return
  fi
  grid["$x,$y"]=X
  visited["$x,$y"]=yup
  ((x+=dx))
  ((y+=dy))
  grid["$x,$y"]=^
  # echo "STEP $x $y"
  print_grid
}

until [[ $x -lt 0 || $y -lt 0 || $x -ge $mx || $y -ge $my ]]; do
  step
done

stuff=(${!visited[@]})
echo "${#stuff[@]}"
