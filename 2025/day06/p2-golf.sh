set -f;mapfile -t a;for((h=${#a[@]}-1;r<${#a};++r))
do n=${a[h]:r:2};$n||o=$_;${n:1}||o=_;for((c=0;c<h;))
do printf ${a[c++]:r:1};done;printf $o
done|sed 's>. *_>+>g;s<$<0\n<'|bc
