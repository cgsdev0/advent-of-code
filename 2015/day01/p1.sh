#!/bin/bash

. ../../misc/vardump

FILE="$1"
FILE=input.txt

A=$(tr -dc ')' < "$FILE" | wc -c)
B=$(tr -dc '(' < "$FILE" | wc -c)
echo $((B-A))
