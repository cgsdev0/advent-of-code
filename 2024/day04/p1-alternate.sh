#!/usr/bin/env bash

function transpose() {
  awk '{
    split($0, chars, "")
    for(j=1; j<=length(chars); j++) {
      idx=(j)
      a[idx]=a[idx]chars[j]
    }
  }
  END{ for (i=1; i<=NR; i++) print a[i] }
    '
}

FILE=$1

SIZE=$(wc -l $FILE | cut -d' ' -f1)
A=$((SIZE+1))
B=$((SIZE-1))

{
  # horizontals
  cat $FILE | grep -o "XMAS" | wc -l
  cat $FILE | rev | grep -o "XMAS" | wc -l

  # verticals
  cat $FILE | transpose | grep -o "XMAS" | wc -l
  cat $FILE | transpose | rev | grep -o "XMAS" | wc -l

  # diagonals
  tac $FILE |  tr '\n' '.' | grep -oP "X(?=.{$A}M.{$A}A.{$A}S)" | wc -l
  cat $FILE |  tr '\n' '.' | grep -oP "X(?=.{$A}M.{$A}A.{$A}S)" | wc -l
  tac $FILE |  tr '\n' '.' | grep -oP "X(?=.{$B}M.{$B}A.{$B}S)" | wc -l
  cat $FILE |  tr '\n' '.' | grep -oP "X(?=.{$B}M.{$B}A.{$B}S)" | wc -l
} | paste -sd+ | bc
