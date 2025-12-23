#!/usr/bin/env bash

mapfile -t mem < <(xxd -c2 -e challenge.bin | cut -d' ' -f2)
for ((i=0; i<${#mem[@]}; i++)); do
  mem[i]=$((16#${mem[i]}))
done
reg=(0 0 0 0 0 0 0 0)
stack=()
pc=0
step() {
  op=${mem[pc]}
  va=${mem[pc+1]}
  ra=$((va-32768))
  if [[ $va -gt 32767 ]]; then
    va=${reg[ra]}
  fi
  vb=${mem[pc+2]}
  rb=$((vb-32768))
  if [[ $vb -gt 32767 ]]; then
    vb=${reg[rb]}
  fi
  vc=${mem[pc+3]}
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
    7) #jt
      if [[ $va -ne 0 ]]; then
        pc=$vb
      else
        ((pc+=3))
      fi
      ;;
    8) #jf
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
      IFS= read -rn1 char
      eval "printf -v dec \"%d\n\" \'""$char"
      if [[ "$char" == " " ]]; then
        reg[ra]=32
      elif [[ $dec -eq 0 ]]; then
        reg[ra]=10
      else
        reg[ra]=$dec
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
