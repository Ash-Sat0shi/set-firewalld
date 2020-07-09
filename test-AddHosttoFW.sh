#!/bin/sh

#for firewall that applied based on hostname, not IP address.
#dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt to reflect current global IP list to ipList.txt 

HOSTNAME=(`cat ./hostnameList.txt|xargs`)
CURRENTIP=(`dig +short "${HOSTNAME[@]}"`)
lastip=(`cat ipList.txt|xargs`)
richrule=(`firewall-cmd --list-rich-rules`)

#compare those arrays
echo "登録されているホスト名：$(echo "
$(cat ./hostnameList.txt)")"
echo "現在のグローバルIPアドレス：
    ${CURRENTIP[*]}"
echo "前回登録されたIPアドレス：
    ${lastip[*]}"
#echo "現在登録されているリッチルール${richrule[*]}"
#find the difference between saved IP list and current IP address.
if [ "${CURRENTIP[*]}" = "${lastip[*]}" ]; then
    echo "NO Global IP address has changed. Thank God."
    
    exit
else
    #reset rich-rule by reloading firewalld
    echo "resetting the firewall..."
    firewall-cmd --reload
    
    echo "
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        @@  Global IP address has changed. @@
        @@  Applying to ipList.txt ...     @@
        @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
        "
    dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt
    
    #get latest IP list and add them to firewalld...
    lastip=(`cat ipList.txt|xargs`)
    echo "There are $(cat ./ipList.txt | wc -l) IP addresses need to be changed."
       
    for (( i=0; i<$(cat ./ipList.txt | wc -l); i++ ));
    do echo "adding ${lastip[i]} to firewall rich-rule..."
    firewall-cmd --add-rich-rule="rule family=ipv4 source address=${lastip[i]} port port=5060 protocol=udp accept"
    
    
done
    richrule=(`firewall-cmd --list-rich-rules | sudo tee ./richrule.txt`)
    num=$(cat ./richrule.txt | wc -l)
    echo "here is rich-rules that is enabled now
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
$(for (( i=1; i<=$num; i++ ));
do echo "$(awk NR==$i ./richrule.txt)"
done)
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
"
fi

exit




#dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt