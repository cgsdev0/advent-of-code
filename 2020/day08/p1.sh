#!/usr/bin/env bash

. ../../misc/vardump

acc=0
pc=0
declare -A visited
declare -a program
FILE="$1"

while read -r line; do
  program+=("$line")
done < "$FILE"

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
    echo "$acc"
    exit 0
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
