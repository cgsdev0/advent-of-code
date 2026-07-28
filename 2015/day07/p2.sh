#!/usr/bin/env bash

clear
. ../../misc/vardump

FILE="$1"

declare -A rules

while IFS= read -r line; do
  IFS=':' read lhs rhs <<< "$line"
  rules[$rhs]=$lhs
done < <(sed 's/ -> /:/' "$FILE")

ordering=$(while IFS= read -r line; do
  IFS=':' read lhs rhs <<< "$line"
  read -a exp <<< "$lhs"
  case "${#exp[@]}" in
    1)
      # assignment
      echo "$lhs $rhs"
    ;;
    2)
      # NOT
      echo "${exp[1]} $rhs"
    ;;
    3)
      # the other ones
      echo "${exp[2]} $rhs"
      echo "${exp[0]} $rhs"
    ;;
  esac
done < <(sed 's/ -> /:/' "$FILE") \
  | tsort \
  | grep -v '^[0-9]*$')

evaulate() {
  while read -r next; do
    echo "evaulating $next"
    : "${rules[$next]}"
    : "${_//NOT /16*16*16*16-1-}"
    : "${_// LSHIFT /<<}"
    : "${_// RSHIFT />>}"
    : "${_// OR /|}"
    : "${_// AND /\&}"
    rule="${_}"
    eval "(($next=$rule))"
  done <<< "$ordering"
}

evaulate
for key in ${!rules[@]}; do
  echo "$key -> ${rules[$key]}"
done
rules[b]="$a"
echo
for key in ${!rules[@]}; do
  echo "$key -> ${rules[$key]}"
done
evaulate
echo "$a"
