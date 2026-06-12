#!/usr/bin/env bash

FILE=input_4.txt

# parse the stuff
declare -A types
declare -A dests
declare -A state
while IFS= read -r line; do
  line="${line//[->,]/}"
  line="${line//  /#}"
  IFS=# read name dest <<< "${line}"
  type=${name:0:1}
  if [[ "$type" == "%" ]] || [[ "$type" == "&" ]]; then
    name=${name:1}
  else
    type=
  fi
  types[$name]="$type"
  case "$type" in
    "%") state[$name]=off ;;
  esac
  dests[$name]="${dest// /
}"
done < $FILE

types[button]=button
dests[button]=broadcaster

# map inputs for conjuctive bois
for key in "${!dests[@]}"
do
  while read d; do
    if [[ -z "${inputs[$d]}" ]]; then
      inputs[$d]=$key
    else
      inputs[$d]="${inputs[$d]}
$key"
    fi
    case "${types[$d]}" in
      "&") state["$key->$d"]=low ;;
    esac
  done <<< "${dests[$key]}"
done

counter=0
function press_button() {
  local -a queue
  ((counter++))
  queue+=("button low broadcaster")
  # echo "you pressed the button"
  while [[ ${#queue[@]} -gt 0 ]]; do
    item=${queue[0]}
    queue=("${queue[@]:1}")
    read from pulse dest <<< "${item}"
    if [[ "$dest" == "output" ]] && [[ "$pulse" == "low" ]]; then
      echo "$pulse $counter"
      echo $FILE
      exit 0
    fi
    # echo "button $pulse $dest"
    type=${types[$dest]}
    if [[ $type == "%" ]] && [[ $pulse == high ]]; then
      continue
    fi
    if [[ $type == "%" ]] && [[ $pulse == low ]]; then
      if [[ "${state[$dest]}" == "off" ]]; then
        state[$dest]=on
        pulse=high
      else
        state[$dest]=off
        pulse=low
      fi
    fi
    if [[ "$type" == "&" ]]; then
      state["$from->$dest"]=$pulse
      pulse=low
      while read input; do
        if [[ "${state["$input->$dest"]}" == "low" ]]; then
          pulse=high
          break
        fi
      done <<< "${inputs[$dest]}"
    fi
    while read d; do
      if [[ "$d" == "" ]]; then
        continue
      fi
      queue+=("$dest $pulse $d")
    done <<< "${dests[$dest]}"
  done
}

while true; do
  press_button
done
