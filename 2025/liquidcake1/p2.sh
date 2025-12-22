#!/usr/bin/env bash

mapfile -t grid < grid$LOL
mapfile -t solved < <(tr '[a-z]' '.' < grid$LOL)
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

declare -A row
declare -A col
declare -A length
declare -A elfed

walk() {
  local -n _grid=$1
  local -n _elf=$2
  local flipped=$3
  local h="${#_grid[@]}"
  local w="${#_grid[0]}"
  local x y
  for ((y=0; y<h; y++)); do
      local line="${_grid[y]}${_grid[y]}"
      local wine="${_elf[y]}${_elf[y]}"
      local cur=
      local dur=
      local l=0
      local tmp="${_grid[y]//[a-zA-Z]/.}"
      local tmp2="${_grid[y]//[a-zA-Z]/.}"
      for ((x=0; x<w*2; x++)); do
        local wx=$((x%w))
        local c=${line:x:1}
        local e=${wine:x:1}
        if [[ $c != '.' ]]; then
          if [[ -z "$flipped" ]]; then
            row[$c]=$y
            col[$c]=$wx
          else
            col[$c]=$y
            row[$c]=$wx
          fi
          if [[ -n "$dur" ]]; then
            length[$cur]=$l

            if check_rule "$dur" "${rules[$cur]}"; then
              solved[y]="$tmp"
              echo "$cur is correct!"
              elfed[$cur]=1
              tmp2="$tmp"
            else
              tmp="$tmp2"
            fi
          fi
          l=0
          if [[ "$c" < "$cur" ]]; then
            break
          fi
          cur=$c
          dur=$e
          ((l++))
          local fk=$((${#tmp}-wx-1))
          tmp="${tmp:0:wx}"$e"${tmp:wx+1:fk}"
          continue
        else
          if [[ -z "$cur" ]]; then
            continue
          fi
          dur="$dur$e"
          local fk=$((${#tmp}-wx-1))
          tmp="${tmp:0:wx}"$e"${tmp:wx+1:fk}"
          ((l++))
        fi
      done
  done
}

walk grid elf

mapfile -t grid < <(uppercase grid)
mapfile -t grid < <(transpose grid)
mapfile -t solved < <(transpose solved)
mapfile -t elf < <(transpose elf)

walk grid elf flipped

mapfile -t solved < <(transpose solved)
print solved

p() {
  local depth=$1
  local odd=$2
  local acc=$3
  if [[ depth -eq 0 ]]; then
    if [[ "${acc:0:1}" != "0" ]]; then
      echo "$acc"
    fi
    return 0
  fi
  for next in {0..9}; do
    if [[ odd -eq 1 ]]; then
      p $((depth-1)) 0 $next
    else
      p $((depth-1)) 0 $next$acc$next
    fi
  done
}

generator() {
  local rule="$1"
  local len=$2
  case "$rule" in
    *palindrome)
      local half=$(((len+1)/2))
      local odd=$((len%2))
      p $half $odd
      ;;
    *multiple*)
      local m="${rule//[^0-9]/}"
      local i=1
      local j=$((m*i))
      while [[ ${#j} -le $len ]]; do
        ((j=m*(i++)))
        if [[ ${#j} -eq $len ]]; then
          echo "$j"
        fi
      done
    ;;
    *power*)
      local power="${rule//[^0-9]/}"
      local i=1
      local j=$((power**i))
      while [[ ${#j} -le $len ]]; do
        ((j=power**(i++)))
        if [[ ${#j} -eq $len ]]; then
          echo "$j"
        fi
      done
      ;;
    *square*)
      local i=1
      local j=$((i*i))
      while [[ ${#j} -le $len ]]; do
        ((j=i*(i++)))
        if [[ ${#j} -eq $len ]]; then
          echo "$j"
        fi
      done
      ;;
    *cube*)
      local i=1
      local j=$((i*i*i))
      while [[ ${#j} -le $len ]]; do
        ((j=i*i*(i++)))
        if [[ ${#j} -eq $len ]]; then
          echo "$j"
        fi
      done
      ;;
    *)
      print solved
      echo "NO GENERATOR FOR '$rule'" 1>&2
      exit 1
    ;;
  esac
}

height=${#grid[@]}
width=${#grid[0]}


mapfile -t order < <(for key in "${!rules[@]}"; do
  [[ -n "${elfed[$key]}" ]] && continue
  echo "$(generator "${rules[$key]}" "${length[$key]}" | wc -l) $key"
done | sort -n | cut -d' ' -f2)

declare -A dmap
set() {
  local row=$1
  local col=$2
  local c=$3
  local depth=$4
  local tmp="${solved[$row]}"
  local current="${tmp:col:1}"
  if [[ "$current" != "$c" && "$current" != "." ]]; then
    return 1
  fi
  if [[ "$current" == "$c" ]]; then
    return 0
  fi
  dmap[$row,$col]=$depth
  local fk=$((${#tmp}-col-1))
  local tmp="${tmp:0:col}"$c"${tmp:col+1:fk}"
  solved[row]="$tmp"
}
max_depth=0
solve() {
  local rid=$1
  if [[ rid -gt max_depth ]]; then
    echo "depth reached: $max_depth"
    print solved
    max_depth=$rid
  fi
  if [[ -z "${order[rid]}" ]]; then
    echo "we win"
    echo
    echo '    *'
    sed 's/[24680]/ /g' < <(print solved) \
      | tee /dev/stderr \
      | paste -sd+ | bc
    exit 0
  fi
  local rule="${order[rid]}"
  local guess
  local r=${row[$rule]}
  local c=${col[$rule]}
  local l=${length[$rule]}
  local guess
  local cucked_by=0
  local SUCCESS=0
  for guess in ${ generator "${rules[$rule]}" ${length[$rule]}; }; do
    local CANT=
    local -a backup=("${solved[@]}")
    if [[ "$rule" == [A-Z] ]]; then
      # column case
      local y wy
      for((y=0; y<l; y++)); do
        ((wy=(y+r)%height))
        if ! set $wy $c ${guess:y:1} $rid; then
          local fker="${dmap[$wy,$c]}"
          fker=${fker:-0}
          cucked_by=$((cucked_by>fker?cucked_by:fker))
          CANT=1
          break
        fi
      done
    else
      # row case
      local x wx
      for((x=0; x<l; x++)); do
        ((wx=(x+c)%width))
        if ! set $r $wx ${guess:x:1} $rid; then
          local fker="${dmap[$r,$wx]}"
          fker=${fker:-0}
          cucked_by=$((cucked_by>fker?cucked_by:fker))
          CANT=1
          break
        fi
      done
    fi

    if [[ -z "$CANT" ]]; then
      solve $((rid+1))
      local RES=$?
      if [[ $RES -ne 0 && $RES -lt $rid ]]; then
        solved=("${backup[@]}")
        return $RES
      fi
      ((SUCCESS++))
    fi
    solved=("${backup[@]}")
  done
  if [[ $SUCCESS -eq 0 ]]; then
    return $cucked_by
  fi
  if [[ $rid -eq 0 ]]; then
    return 1 # :(
  fi
}

echo "${order[@]}"

solve 0
echo no solution found
exit 1
