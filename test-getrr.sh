#!/bin/sh

RICHRULE=$(echo $(firewall-cmd --list-rich-rules))
echo "${RICHRULE[*]}"

#echo $(awk 'NR==1' ./richrule.txt)
echo "number of rich-rules : $(cat ./richrule.txt | wc -l)"

echo "List of rich-rules : "
for (( i=0; i<=$(cat ./richrule.txt | wc -l); i++ ));
    do
    echo $(awk NR==$i ./richrule.txt)
    #firewall-cmd --remove-rich-rule="$(awk 'NR==$i' ./richrule.txt)"
done

exit