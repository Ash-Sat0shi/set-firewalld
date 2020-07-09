#!/bin/sh

#for firewall that applied based on hostname, not IP address.
#dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt to reflect current global IP list to ipList.txt 
cd `dirname $0`
HOSTNAME=(`cat ./hostnameList.txt|xargs`)
CURRENTIP=(`dig +short "${HOSTNAME[@]}"`)
lastip=(`cat ./ipList.txt|xargs`)
richrule=(`firewall-cmd --list-rich-rules`)

#find the difference between saved IP list and current IP address.
if [ "${CURRENTIP[*]}" = "${lastip[*]}" ]; then
    if [ "$(echo $(firewall-cmd --list-rich-rules) $?)" = "0" ]; then
        dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt
        #get latest IP list and add them to firewalld...
        lastip=(`cat ./ipList.txt|xargs`) 
        for (( i=0; i<$(cat ./ipList.txt | wc -l); i++ ));
        do echo "adding ${lastip[i]} to firewall rich-rule..."
        firewall-cmd --add-rich-rule="rule family=ipv4 source address=${lastip[i]} port port=5060 protocol=udp accept"  
        done
    else
    :
    fi
    
    echo "NO Global IP address has changed. Thank God."
    exit
    
else
    #reset rich-rule by reloading firewalld
    echo "resetting the firewall..."
    firewall-cmd --reload
    dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt
    #get latest IP list and add them to firewalld...
    lastip=(`cat ./ipList.txt|xargs`) 
    for (( i=0; i<$(cat ./ipList.txt | wc -l); i++ ));
    do echo "adding ${lastip[i]} to firewall rich-rule..."
    firewall-cmd --add-rich-rule="rule family=ipv4 source address=${lastip[i]} port port=5060 protocol=udp accept"  
    done
fi
exit