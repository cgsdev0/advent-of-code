#!/usr/bin/env bash

cd saves

mapfile -t mem < <(xxd -c2 -e challenge.bin | cut -d' ' -f2)
for ((i=0; i<${#mem[@]}; i++)); do
  mem[i]=$((16#${mem[i]}))
done
reg=(0 0 0 0 0 0 0 0)
stack=()
pc=0
input=
has_input=

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
    *)
      echo "unknown command '$1'"
      ;;
  esac
}

step() {
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
