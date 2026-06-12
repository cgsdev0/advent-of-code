#!/usr/bin/env bash

# rest in pieces: my sanity
sed -E 's/(one|two|three|four|five|six|seven|eight|nine)/_\1_\1/' \
  | sed -E 's/^(.*)(one|two|three|four|five|six|seven|eight|nine)/\1_\2_/' \
  | sed 's/_one_/1/g' \
  | sed 's/_two_/2/g' \
  | sed 's/_three_/3/g' \
  | sed 's/_four_/4/g' \
  | sed 's/_five_/5/g' \
  | sed 's/_six_/6/g' \
  | sed 's/_seven_/7/g' \
  | sed 's/_eight_/8/g' \
  | sed 's/_nine_/9/g' \
  | sed 's/^[^0-9]*\([0-9]\).*\([0-9]\)[^0-9]*$/\1\2/' \
  | sed 's/^[^0-9]*\([0-9]\)[^0-9]*$/\1\1/' \
  | paste -sd+ \
  | bc
