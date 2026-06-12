#!/usr/bin/env bash

cat input.txt \
  | sed 's/blue/> 14/g' \
  | sed 's/green/> 13/g' \
  | sed 's/red/> 12/g' \
  | sed 's/[;,]/+/g' \
  | cut -d' ' -f3- \
  | tr -d ' ' \
  | sed 's/\([0-9]*>[0-9]*\)/(\1)/g' \
  | bc \
  | cat -n \
  | tr -d ' ' \
  | grep $'\t'"0$" \
  | cut -f1 \
  | paste -sd+ \
  | bc
