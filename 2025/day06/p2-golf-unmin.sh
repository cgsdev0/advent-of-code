# noglob creates problems because of '*' in input,
# so we turn it off
set -o noglob

# read our input line by line into an array
mapfile -t arr

# find dimensions of puzzle
width=${#arr}
height=${#arr[@]}-1
symbol_row=$height

for((row=0; row<width; ++row))
do
  # peek ahead at the symbols row
  next=${arr[symbol_row]:row:2}

  # gross hacks that make lots of warnings but work fine
  $next || operator=$_

  # we set operator to '_' which is a placeholder for newline later
  ${next:1} || operator=_

  # loop over all the columns
  for((col=0; col<height; col++))
  do
    # print the number without a line break
    printf ${arr[col]:row:1}
  done

  # join the column with an operator
  printf $operator
done \
  | sed 's/. *_/+/g' \
  | sed 's/$/0\n/' \
  | bc
