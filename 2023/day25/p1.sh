#!/usr/bin/env bash

FILE=input.txt

while IFS= read line; do
  key=${line%:*}
  rest=${line##*: }
  while read val; do
    echo $key -- $val
  done <<< "${rest// /
}"
done < $FILE
