tr ,- \ |xargs -n2 seq|egrep '^(.+)\1+$'|paste -sd+|bc
