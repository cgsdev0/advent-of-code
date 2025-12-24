#!/usr/bin/env bash

cd saves

reg=(0 0 0 0 0 0 0 0)
stack=()
pc=0
input=
has_input=
logging=false

load() {
  read pc
  read -a reg
  read stack_size
  unset stack
  declare -ga stack
  for((i=0; i<stack_size; i++)); do
    read num
    stack+=($num)
  done
  read mem_size
  unset mem
  declare -ga mem
  for((i=0; i<=mem_size; i++)); do
    read num
    mem+=($num)
  done
}

if [[ -n "$1" ]]; then
  load < "$1"
else
  mapfile -t mem < <(xxd -c2 -e ../challenge.bin | cut -d' ' -f2)
  for ((i=0; i<${#mem[@]}; i++)); do
    mem[i]=$((16#${mem[i]}))
  done
fi

save() {
  echo "$pc"
  echo "${reg[@]}"
  echo "${#stack[@]}"
  printf '%s\n' "${stack[@]}"
  keys=("${!mem[@]}")
  mem_size="${keys[-1]}"
  echo "$mem_size"
  for((i=0; i<=mem_size; ++i)); do
    echo "${mem[$i]:-0}"
  done
}

run_cmd() {
  case "$1" in
    save)
      echo "saving to $2..."
      save > "$2"
      echo "saved!"
      ;;
    load)
      echo "loading $2..."
      load < "$2"
      echo "loaded!"
      ;;
    w)
      echo "mem[$2]=$3"
      mem[$2]=$3
      ;;
    s)
      echo "stack[$2]=$3"
      stack[$2]=$3
      ;;
    stack)
      printf '%s\n' "${stack[@]}"
      ;;
    log)
      logging="${2:-true}"
      ;;
    reg)
      if [[ -z "$2" ]]; then
        echo "${reg[@]}"
      else
        if [[ -z "$3" ]]; then
          echo "${reg[$2]}"
        else
          reg[$2]=$3
          echo "reg[$2]=$3"
        fi
      fi
      ;;
    r)
      echo "mem[$2]=${mem[$2]}"
      ;;
    tphack)
      reg[7]="$2"
      mem[5507]=6 # idk
      mem[5511]=21 # noop
      mem[5512]=21 # noop
      input="use teleporter"
      has_input=1
      ;;
    invhack)
      mem[2692]=0 # 2339
      mem[2696]=0 # 2379
      mem[2700]=0 # 32767
      mem[2704]=0 # 32767
      mem[2708]=0 # 2439
      mem[2712]=0 # 2474
      mem[2716]=0 # 2495
      mem[2720]=0 # 2505
      mem[2724]=0 # 2490
      mem[2728]=0 # 2500
      mem[2732]=0 # 2485
      mem[2736]=0 # 2510
      mem[2740]=0 # 2645
      mem[2744]=0 # 2665
      mem[2748]=0 # 2510
      mem[2752]=0 # 2575
      ;;
    unhack)
      mem[2692]=2339
      mem[2696]=2379
      mem[2700]=32767
      mem[2704]=32767
      mem[2708]=2439
      mem[2712]=2474
      mem[2716]=2495
      mem[2720]=2505
      mem[2724]=2490
      mem[2728]=2500
      mem[2732]=2485
      mem[2736]=2510
      mem[2740]=2645
      mem[2744]=2665
      mem[2748]=2510
      mem[2752]=2575
      ;;
    *)
      echo "unknown command '$1'"
      ;;
  esac
}

indent=
print() {
  local pc="$1"
  echo -n "[$pc] "
  local op=${mem[pc]}
  local va=${mem[pc+1]:-0}
  local ra=$((va-32768))
  if [[ $va -gt 32767 ]]; then
    va="<$ra:${reg[ra]}>"
  fi
  ra="<$ra>"
  local vb=${mem[pc+2]:-0}
  local rb=$((vb-32768))
  if [[ $vb -gt 32767 ]]; then
    vb="<$rb:${reg[rb]}>"
  fi
  rb="<$rb>"
  local vc=${mem[pc+3]:-0}
  local rc=$((vc-32768))
  if [[ $vc -gt 32767 ]]; then
    vc="<$rc:${reg[rc]}>"
  fi
  rc="<$rc>"
  echo -n "$indent"

  case "$op" in
    0) # halt
      echo "halt"
      ;;
    1) # set
      echo "set $ra $vb"
      ;;
    2) # push
      echo "push $va"
      ;;
    3) # pop
      echo "pop $ra"
      ;;
    4) # eq
      echo "eq $ra $vb $vc"
      ;;
    5) # gt
      echo "gt $ra $vb $vc"
      ;;
    6) # jmp
      echo "jmp $va"
      ;;
    7) # jt
      echo "jt $va $vb"
      ;;
    8) # jf
      echo "jf $va $vb"
      ;;
    9) # add
      echo "add $ra $vb $vc"
      ;;
    10) # mult
      echo "mult $ra $vb $vc"
      ;;
    11) # mod
      echo "mod $ra $vb $vc"
      ;;
    12) # and
      echo "and $ra $vb $vc"
      ;;
    13) # or
      echo "or $ra $vb $vc"
      ;;
    14) # not
      echo "not $ra $vb"
      ;;
    15) # rmem
      echo "rmem $ra $vb"
      ;;
    16) # wmem
      echo "wmem $va $vb"
      ;;
    17) # call
      indent="${indent}  "
      echo "--call $va"
      ;;
    18) # ret
      indent="${indent:2}"
      echo "ret"
      ;;
    19) # out
      echo "out $va"
      ;;
    20) # in
      echo "in $ra"
      ;;
    21) # noop
      echo "noop"
      ;;
  esac
}

step() {
  if $logging; then
    print "$pc" >> log
  fi
  op=${mem[pc]}
  va=${mem[pc+1]:-0}
  ra=$((va-32768))
  if [[ $va -gt 32767 ]]; then
    va=${reg[ra]}
  fi
  vb=${mem[pc+2]:-0}
  rb=$((vb-32768))
  if [[ $vb -gt 32767 ]]; then
    vb=${reg[rb]}
  fi
  vc=${mem[pc+3]:-0}
  rc=$((vc-32768))
  if [[ $vc -gt 32767 ]]; then
    vc=${reg[rc]}
  fi
  # echo "op: $op"
  # echo "pc: $pc"
  case "$op" in
    0) # halt
      exit 0 ;;
    1) # set
      reg[ra]=$vb
      ((pc+=3))
      ;;
    2) # push
      stack+=($va)
      ((pc+=2))
      ;;
    3) # pop
      reg[ra]=${stack[-1]}
      unset 'stack[-1]'
      ((pc+=2))
      ;;
    4) # eq
      reg[ra]=$((vb==vc ? 1 : 0 ))
      ((pc+=4))
      ;;
    5) # gt
      reg[ra]=$((vb > vc ? 1 : 0))
      ((pc+=4))
      ;;
    6) # jmp
      pc=$va ;;
    7) # jt
      if [[ $va -ne 0 ]]; then
        pc=$vb
      else
        ((pc+=3))
      fi
      ;;
    8) # jf
      if [[ $va -eq 0 ]]; then
        pc=$vb
      else
        ((pc+=3))
      fi
      ;;
    9) # add
      reg[ra]=$(((vb + vc) % 32768))
      ((pc+=4))
      ;;
    10) # mult
      reg[ra]=$(((vb * vc) % 32768))
      ((pc+=4))
      ;;
    11) # mod
      reg[ra]=$((vb % vc))
      ((pc+=4))
      ;;
    12) # and
      reg[ra]=$((vb & vc))
      ((pc+=4))
      ;;
    13) # or
      reg[ra]=$((vb | vc))
      ((pc+=4))
      ;;
    14) # not
      reg[ra]=$((2**15 - vb - 1))
      ((pc+=3))
      ;;
    15) # rmem
      loaded=${mem[vb]}
      reg[ra]=${loaded:-0}
      ((pc+=3))
      ;;
    16) # wmem
      mem[va]=$vb
      ((pc+=3))
      ;;
    17) # call
      ((pc+=2))
      stack+=($pc)
      pc=$va
      ;;
    18) # ret
      if [[ ${#stack[@]} -eq 0 ]]; then
        exit 0
      fi
      pc=${stack[-1]}
      unset 'stack[-1]'
      ;;
    19) # out
      printf -v hex "%x" "$va"
      printf "\x${hex}"
      ((pc+=2))
      ;;
    20) # in
      if [[ -z "$has_input" ]]; then
        input='/'
        while [[ "${input:0:1}" == "/" ]]; do
          IFS= read -re input
          if [[ "${input:0:1}" == "/" ]]; then
            run_cmd ${input:1}
          fi
        done
        has_input=1
      fi
      if [[ "${#input}" -gt 0 ]]; then
        char="${input:0:1}"
        input="${input:1}"
        printf -v dec '%d' "'$char"
        if [[ "$char" == " " ]]; then
          reg[ra]=32
        else
          reg[ra]=$dec
        fi
      else
        has_input=
        reg[ra]=10 # enter
      fi
      ((pc+=2))
      ;;
    21) # noop
      ((pc++))
      ;;
    *)
      echo "OP: $op"
      exit 1
      ((pc++))
      ;;
  esac
}

while true; do
  step
done
