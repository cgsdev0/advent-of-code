declare -A g;y=1;while read -n1 c;do
g[$((++x)),$y]=$c;[ -z $c ]&&((x=0,n=++y));done
z(){ for ((m=i=0;i<n*n;));do ((y=i/n,x=i++%n))
[ "${g[$x,$y]}" = @ ]&&{ c=0;for a in {0..8};do
[ "${g[$((x-1+a/3)),$((y-1+a%3))]}" = @ ]&&((c++))
done;[ $c -lt 5 ]&&g[$x,$y]=.&&((m++))}
done;echo $m;[ $m = 0 ]||z;}
z|paste -sd+|bc
