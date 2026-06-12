#!/usr/bin/env bash

clear

declare -a cards

FILE=input.txt
count=$(wc -l $FILE | cut -d' ' -f1)
for ((i=1;i<=count;i++)); do
  cards[$i]=1
done

i=1
while IFS= read -r line; do
  wins=$(echo "$line" \
    | tr -d '|' \
    | tr -s ' ' \
    | cut -d' ' -f3- \
    | sed 's/ /\n/g' \
    | sort -n \
    | uniq -d \
    | wc -l)
  for ((j=i+1;j<=count&&j<=i+wins;j++)); do
    ((cards[j]+=cards[i]))
  done
  ((i+=1))
done < $FILE

for ((i=1;i<=count;i++)); do
  echo ${cards[i]}
done | paste -sd+ | bc
