#!/usr/bin/env bash

clear

FILE=input.txt

declare -A workflows
function parse_rule() {
  IFS={ read key val <<< "$1"
  workflows[$key]="${val%\}}"
}

function traverse() {
  local workflow=$1
  local x1 x2 m1 m2 a1 a2 s1 s2
  local rule rules dest condition
  local amt var
  IFS=, read x1 x2 <<< "$2"
  IFS=, read m1 m2 <<< "$3"
  IFS=, read a1 a2 <<< "$4"
  IFS=, read s1 s2 <<< "$5"
  condition="$6"
  if [[ ! -z "$condition" ]]; then
    local var=${condition:0:1}
    local direction=${condition:1:1}
    local amt=${condition:2}
    case $direction in
      ">")
        ((amt+=1))
        printf -v "${var}1" '%s' $(("${var}1>${amt}?${var}1:${amt}"))
        ;;
      "<")
        ((amt-=1))
        printf -v "${var}2" '%s' $(("${var}2<${amt}?${var}2:${amt}"))
        ;;
    esac
  fi
  if [[ $workflow == R ]]; then
    return
  fi
  if [[ $workflow == A ]]; then
    if [[ $x2 -lt $x1 ]] \
     || [[ $m2 -lt $m1 ]] \
     || [[ $a2 -lt $a1 ]] \
     || [[ $s2 -lt $s1 ]]; then
    return
    fi
    echo "($x2-$x1+1)*($m2-$m1+1)*($a2-$a1+1)*($s2-$s1+1)"
    return
  fi
  rules=${workflows[$workflow]}
  while [[ ! -z "$rules" ]]; do
    rule=${rules%%,*}
    if [[ "$rule" =~ .*:.* ]]; then
      # conditional rule
      IFS=: read condition dest <<< "$rule"
      traverse $dest $x1,$x2 $m1,$m2 $a1,$a2 $s1,$s2 $condition
      local var=${condition:0:1}
      local direction=${condition:1:1}
      local amt=${condition:2}
      case $direction in
        ">")
          printf -v "${var}2" '%s' $(("${var}2<${amt}?${var}2:${amt}"))
          ;;
        "<")
          printf -v "${var}1" '%s' $(("${var}1>${amt}?${var}1:${amt}"))
          ;;
      esac
    else
      traverse $rule $x1,$x2 $m1,$m2 $a1,$a2 $s1,$s2
    fi
    # pop front
    if [[ "$rules" =~ .*,.* ]]; then
      rules=${rules#*,}
    else
      rules=""
    fi
  done
  # traverse in $x1,$x2 $m1,$m2 $a1,$a2 $s1,$s2
}

while IFS= read -r line; do
  if [[ "$line" == "" ]]; then
    traverse in 1,4000 1,4000 1,4000 1,4000
    break
  fi
  parse_rule "$line"
done < $FILE \
  | paste -sd+ \
  | bc
