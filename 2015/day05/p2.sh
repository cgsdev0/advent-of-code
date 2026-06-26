#!/usr/bin/env bash

. ../../misc/vardump

FILE="$1"

cat "$FILE" \
  | grep -P '(..).*\1' \
  | grep -P '(.).\1' \
  | wc -l
