#!/usr/bin/env bash

FILE="$1"

sed 's/\([^ ]*\)/\1 \1/g;
     s/^[^ ]* //;
     s/ [^ ]*$/ /;
     s/\([^ ]*\) \([^ ]*\) /\1-\2 /g;
     s/ /\n/g' $FILE \
  | sed 's/^$/print "A\n"/' \
  | bc \
  | paste -sd' ' \
  | sed 's/A/\n/g' \
  | sed 's/^ //' \
  | grep -vE '[1-9]\d( |$)|(^| )0( |$)|[4-9]( |$)' \
  | sed -r 's/(^| )([0-9])/\1+\2/g;s/[0-9]//g' \
  | grep -vEc '^$|\+ -|- \+'

# reddit version

# sed 's/\([^ ]*\)/\1 \1/g;s/^[^ ]* //;
#   s/ [^ ]*$/ /;s/\([^ ]*\) \([^ ]*\) /\1-\2 /g;s/ /\n/g' $FILE \
#   | sed 's/^$/print "A\n"/' | bc | paste -sd' ' | sed 's/A/\n/g' \
#   | sed 's/^ //' | grep -vE '[1-9]\d( |$)|(^| )0( |$)|[4-9]( |$)' \
#   | sed -r 's/(^| )([0-9])/\1+\2/g;s/[0-9]//g' | grep -vEc '^$|\+ -|- \+'


# tweetable version

# sed 's/\([^ ]*\)/\1 \1/g;s/^[^ ]* //;s/ [^ ]*$/ /;s/\([^ ]*\) \([^ ]*\) /\1-\2 /g;s/ /\n/g' $1|sed 's/^$/print "A\n"/'|bc|paste -sd' '|sed 's/A/\n/g'|sed 's/^ //'|grep -vE '[1-9]\d( |$)|(^| )0( |$)|[4-9]( |$)'|sed -r 's/(^| )([0-9])/\1+\2/g;s/[0-9]//g'|grep -vEc '^$|\+ -|- \+'
