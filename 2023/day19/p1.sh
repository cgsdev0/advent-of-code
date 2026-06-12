#!/usr/bin/env bash

clear

FILE=input.txt

declare -A workflows
function parse_rule() {
  IFS={ read key val <<< "$1"
  workflows[$key]="${val%\}}"
}

function parse_part() {
  IFS=, read x m a s <<< "${1//[\{xmas\}=]/}"
  workflow="${workflows[in]}"
  while [[ ! -z "$workflow" ]]; do
    rule=${workflow%%,*}
    if [[ "$rule" =~ .*:.* ]]; then
      # conditional rule
      IFS=: read condition dest <<< "$rule"
      if [[ $((condition)) -eq 1 ]]; then
        if [[ "$dest" == "R" ]]; then
          return
        fi
        if [[ "$dest" == "A" ]]; then
          echo "$x+$m+$a+$s"
          return
        fi
        workflow="${workflows[$dest]}"
        continue
      fi
    else
      if [[ "$rule" == "R" ]]; then
        return
      fi
      if [[ "$rule" == "A" ]]; then
        echo "$x+$m+$a+$s"
        return
      fi
      workflow="${workflows[$rule]}"
      continue
    fi
    # pop front
    if [[ "$workflow" =~ .*,.* ]]; then
      workflow=${workflow#*,}
    else
      workflow=""
    fi
  done
}

mode=
while IFS= read -r line; do
  if [[ "$line" == "" ]]; then
    mode=parts
    continue
  fi
  if [[ "$mode" == "parts" ]]; then
    parse_part "$line"
  else
    parse_rule "$line"
  fi
done < $FILE \
  | paste -sd+ \
  | bc
