#!/usr/bin/env bash

. ../../misc/vardump

acc=0
pc=0
declare -A visited
declare -a program
FILE="$1"

declare -a backup

restore() {
  acc=0
  pc=0
  unset visited
  declare -Ag visted
  program=("${backup[@]}")
}

while read -r line; do
  program+=("$line")
done < "$FILE"

backup=("${program[@]}")

try_one() {
  while :; do
    instr=${program[$pc]}
    if [[ -z $instr ]]; then
      break
    fi
    read -r opcode num <<< "$instr"
    key="$pc"
    if [[ -z "${visited[$key]}" ]]; then
      visited[$key]=1
    else
      return 1
    fi
    case "$opcode" in
      acc)
        eval "((acc+=$num))"
        ((pc++))
        ;;
      jmp)
        eval "((pc+=$num))"
        ;;
      nop)
        ((pc++))
        ;;
    esac
  done
  echo "$acc"
}

for ((i=0; i<${#program[@]}; i++)); do
  restore
  mod="${program[$i]}"
  read -r opcode num <<< "$mod"
  case "$opcode" in
    jmp)
      program[$i]="nop $num"
      ;;
    nop)
      program[$i]="jmp $num"
      ;;
    acc)
      continue
      ;;
  esac
  try_one && break
done
