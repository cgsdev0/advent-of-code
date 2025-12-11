# requries bash 5.3+
declare -A c;i=$1
f(){ local h=$1$2$3 fft=$2 dac=$3;[ $1 = out ]&&
c[$h]=$[$2&$3]||[ -z ${c[$h]} ]&&{ eval "(($1++))"
for x in `grep ^$1 $i|tail -c+6`;do((c[$h]+=${
f $x $fft $dac;}))done };echo $[c[$h]];};f svr
