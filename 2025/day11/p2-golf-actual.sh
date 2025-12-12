# requries bash 5.3+
# ./p2-golf-actual.sh [input]
declare -A c;i=$1;f(){
local h=$1$2 z=$2;[ $1 = out ]&&c[$h]=$[z>1]||
${c[$h]}&&{ [[ $1 =~ fft|ac ]]&&$[z++]
for x in `grep ^$1 $i|tail -c+6`;do((c[$h]+=${
f $x $z;}))done };echo $[c[$h]];};f svr
