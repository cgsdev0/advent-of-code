#!/usr/bin/env bash

. ../../misc/vardump

FILE="$1"

read key < "$FILE"

seq 1000000000 \
  | sed "s/^/$key/" \
  | ./md5 \
  | grep ' 00000'
