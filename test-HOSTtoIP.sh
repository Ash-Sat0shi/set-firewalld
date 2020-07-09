#!/bin/sh

#for firewall that applied based on hostname, not IP address.
#dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt to reflect current global IP list to ipList.txt 

hostname=(`cat ./hostnameList.txt|xargs`)
currentip=(`dig +short "${hostname[@]}" | sudo tee ./currentipList.txt`)
lastip=(`cat ipList.txt|xargs`)
num=$(cat ./currentipList.txt | wc -l)
lastnum=$(cat ./ipList.txt | wc -l)
#compare those arrays
echo "登録されているホスト名：
$(for (( i=1; i<=$num; i++ ));
        do echo "$(awk NR==$i ./hostnameList.txt)"
        done)"
echo "前回登録されたIPアドレス：
$(for (( i=1; i<=$lastnum; i++ ));
        do echo "$(awk NR==$i ./ipList.txt)"
        done)"
echo "現在のグローバルIPアドレス：
$(for (( i=1; i<=$num; i++ ));
    do echo "$(awk NR==$i ./currentipList.txt)"
    done)"

#find the difference between saved IP list and current IP address.
#if [ "${CURRENTIP[*]}" = "${LASTIP[*]}" ]; then
#    echo "NO Global IP address has changed. Thank God."
#else
#    echo "Global IP address has changed. Reflecting to ipList.txt ..."
    #get latest IP list and add them to firewalld...
    #get number of ip to set
#    echo "There are ${#LASTIP[*]} IP addresses need to be changed."
#done
#fi