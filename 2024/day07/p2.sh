#!/usr/bin/env bash

FILE="$1"

split() {
   IFS=$'\n' read -d "" -ra arr <<< "${1//$2/$'\n'}"
}

permute() {
  local ACC=${1:-0}
  local OP=${2:-+}
  local LEN=${#arr[@]}

  if [[ $ACC -gt $test_number ]]; then
    return
  fi

  local first=${arr[0]}

  case "$OP" in
    '+')
      ((ACC+=first))
      ;;
    '*')
      ((ACC*=first))
      ;;
    '|')
      ACC="${ACC}${first}"
      ;;
  esac

  if [[ $LEN -eq 1 ]]; then
    # base case
    echo $ACC
    return
  fi

  arr=(${arr[@]:1})
  permute $ACC '*'
  permute $ACC '|'
  permute $ACC '+'
  arr=($first "${arr[@]}")
}

main() {
  while IFS= read -r line; do
    test_number="${line%%:*}"
    rest="${line##*: }"
    split "$rest" " "
    permute \
      | grep "^$test_number$" \
      | head -n1
  done
}

# gotta go fast
if [[ ! -z "$DONT_FORK_BOMB_ME_BRO" ]]; then
  main
else
  export DONT_FORK_BOMB_ME_BRO=true
  <$FILE parallel --pipe -N 85 $0 \
    | paste -sd+ \
    | bc
fi
