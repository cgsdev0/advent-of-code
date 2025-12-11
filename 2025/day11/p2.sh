#!/bin/bash

. ../../misc/vardump

FILE="$1"

declare -A graph


declare -A c

count=0
function dfs() {
  local start=$1
  local end=$2
  local fft=$3
  local dac=$4
  # printf "%${depth}s" 1>&2
  # printf "%s\n" "$start" 1>&2
  if [[ "$start" == "$end" ]]; then
    ((count++))
    # if [[ $fft -eq 1 && dac -eq 1 ]]; then
    #   ((count++))
    # fi
    return
  fi
  if [[ "$start" == "fft" ]]; then
    fft=1
  fi
  if [[ "$start" == "dac" ]]; then
    dac=1
  fi
  local -a conns=(${graph[$start]})
  local i
  for ((i=0;i<${#conns[@]};++i)); do
    dfs "${conns[i]}" "$end" $fft $dac
  done
}

count_paths() {
  local end=$1
  shift
  local -a starts=($@)
  local total=0
  local start
  for start in "${starts[@]}"; do
    count=0
    echo dfs "$start" "$end" 0 0
    dfs "$start" "$end" 0 0
    ((total+=c[$start]*count))
  done
  echo $total
}

load_the_cannon() {
  while IFS= read -r line; do
    eval "$line"
  done
  c[omn]=1032
  c[zyw]=823
  c[kzo]=1010
  c[ziu]=855
  c[fft]=$((3*c[omn]+2*c[zyw]+3*c[kzo]+3*c[ziu]))
  # layer 1 bridges
  # graph[omn]=
  # graph[zyw]=
  # graph[kzo]=
  # graph[ziu]=

  # layer 2 bridges
  c[coc]=$((c[fft]*2))
  c[qmi]=$((c[fft]*1))
  c[qia]=$((c[fft]*1))
  c[eiz]=$((c[fft]*2))
  c[ysm]=$((c[fft]*2))
  # graph[coc]=
  # graph[qmi]=
  # graph[qia]=
  # graph[eiz]=
  # graph[ysm]=

  # layer 3 bridges
  # graph[dev]=
  # graph[qzd]=
  # graph[ksk]=

  c[dev]=8507351
  c[qzd]=9272289
  c[ksk]=9592736

  # layer 4 bridges
  c[xbq]=3496283510
  c[mlu]=3772302084
  c[uvw]=4086960364
  c[vkk]=5026521305

  # layer 5 bridges
  graph[qve]=
  graph[iix]=
  graph[you]=
  c[dac]=116011199996
  c[out]=$((3460*c[dac]))
  echo "${c[out]}"
}

cat "$FILE" \
  | sed 's/^/graph[/;s/: /]="/;s/$/"/' \
  | load_the_cannon
