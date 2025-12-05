grep -|sort -n|(while IFS=- read a b
do((t+=a>c?b-a+1:c>b?0:b-c,b>c?c=b:0))done
echo $t)
