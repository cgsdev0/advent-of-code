#!/usr/bin/env bash

clear

LOL=
mapfile -t grid < grid$LOL
mapfile -t elf < elf$LOL

declare -A cubes
declare -A squares
declare -A powers2
declare -A powers3
declare -A rules

while read -r letter rule; do
  rules[$letter]="$rule"
done < "rules$LOL"

for ((i=1; i<3200; i++)); do
  cubes[$((i*i*i))]=1
  squares[$((i*i))]=1
  powers2[$((2**i))]=1
  powers3[$((3**i))]=1
done

reverse() {
  local str=$1
  local len=${#str}
  local rev i
  for((i=$len-1;i>=0;i--)); do
    rev="$rev${str:$i:1}"
  done
  echo "$rev"
}

palindrome() {
  local str=$1
  local rev=${ reverse "$str"; }
  [[ "$str" == "$rev" ]]
  return $?
}

transpose() {
  local -n _grid=$1
  local h="${#_grid[@]}"
  local w="${#_grid[0]}"
  local x y
  for ((x=0; x<w; x++)); do
    for ((y=0; y<h; y++)); do
      local line="${_grid[y]}"
      echo -n "${line:x:1}"
    done
    echo
  done
}

print() {
  local -n _grid=$1
  local h="${#_grid[@]}"
  local w="${#_grid[0]}"
  local x y
  for ((y=0; y<h; y++)); do
      echo "${_grid[y]}"
  done
}

uppercase() {
  local -n _grid=$1
  local h="${#_grid[@]}"
  local w="${#_grid[0]}"
  local x y
  for ((y=0; y<h; y++)); do
      echo "${_grid[y]^^}"
  done
}

# print grid
# echo
# print elf
# echo

check_rule() {
  local n="$1"
  local rule="$2"
  case "$rule" in
    *cube)
      [[ -n "${cubes[$n]}" ]]
      return $?
      ;;
    *square)
      [[ -n "${squares[$n]}" ]]
      return $?
      ;;
    *palindrome)
      palindrome "$n"
      return $?
      ;;
    *power*)
      local power="${rule//[^0-9]/}"
      local -n p=powers${power}
      [[ -n "${p[$n]}" ]]
      return $?
      ;;
    *multiple*)
      local m="${rule//[^0-9]/}"
      ((n%m==0))
      return $?
      ;;
    *)
      echo "ERRORORRE $rule"
      exit 1
  esac
}
walk() {
  local -n _grid=$1
  local -n _elf=$2
  local h="${#_grid[@]}"
  local w="${#_grid[0]}"
  local x y
  for ((y=0; y<h; y++)); do
      local line="${_grid[y]}${_grid[y]}"
      local wine="${_elf[y]}${_elf[y]}"
      local cur=
      local dur=
      for ((x=0; x<w*2; x++)); do
        local wx=$((x%w))
        local c=${line:x:1}
        local e=${wine:x:1}
        if [[ $c != '.' ]]; then
          if [[ -n "$dur" ]]; then
            check_rule "$dur" "${rules[$cur]}" || echo "$dur"
          fi
          if [[ "$c" < "$cur" ]]; then
            break
          fi
          cur=$c
          dur=$e
          continue
        else
          if [[ -z "$cur" ]]; then
            continue
          fi
          dur="$dur$e"
        fi
      done
  done
}

{ walk grid elf

mapfile -t grid < <(uppercase grid)
mapfile -t grid < <(transpose grid)
mapfile -t elf < <(transpose elf)

walk grid elf
} | paste -sd+ | bc
