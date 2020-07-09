#!/bin/sh

lastip=(`cat ipList.txt|xargs`)
HOSTNAME=(`cat ./hostnameList.txt|xargs`)
currentip=(`dig +short "${HOSTNAME[@]}"`)


#とりあえず過去にこのプログラム実行したかどうかに関わらず現在のIPと過去のIP取得して比較。
#過去IPと現在IP同じだけどrich-ruleがなかったら再起動直後でfirewall読み込まれ直した可能性ありなので
if [ "${currentip[*]}" = "${lastip[*]}" ]; then
    if [ "$(echo $(firewall-cmd --list-rich-rules) $?)" = "0" ]; then
        read -p "There is no rich-rule already exists. Do you want to modyfi firewall? (y/N): "
        case "$yn" in
        #if it's yes
            [yY]*) 
            echo "Reloading ipList.txt　..."
            dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt
            lastip=(`cat ./ipList.txt|xargs`)
            for (( i=0; i<$(cat ./ipList.txt | wc -l); i++ ));
                do echo "adding ${lastip[i]} to firewall rich-rule..."
                firewall-cmd --add-rich-rule="rule family=ipv4 source address=${lastip[i]} port port=5060 protocol=udp accept"  
            done ;;
        #if it's no, do those below...
            *) echo "Nothing has changed.  Quitting　..."
            pause ; exit ;;
        esac

    else
    echo "NO Global IP address has changed. Nothing to do."
    read -p "Do you want to remove all the rich-rules already exists? (y/N): " yn
                case "$yn" in 
                    [yY]*)
                    num=$(cat ./richrule.txt | wc -l)
                    for (( i=1; i<=$num; i++ ));
                        do echo "    removing $(awk NR==$i ./richrule.txt) from firewall..."
                        firewall-cmd --remove-rich-rule="$(awk NR==$i ./richrule.txt)"
                    done
                    exit ;;
                    #if it's no, do those below...
                    *) echo "Nothing has changed." ; exit ;;
                esac
    fi
    
#もし現在IPが過去IPから変わっていたら
else
    #現在の状況表示
    num=$(cat ./currentipList.txt | wc -l)
    echo "登録されているホスト名：
$(for (( i=1; i<=$num; i++ ));
        do echo "$(awk NR==$i ./hostnameList.txt)"
        done)"
    
    echo "前回登録されたIPアドレス：
$(for (( i=1; i<=$num; i++ ));
        do echo "$(awk NR==$i ./ipList.txt)"
        done)"
    dig +short ${HOSTNAME[*]} | sudo tee ./currentipList.txt
    echo "現在のグローバルIPアドレス：
$(for (( i=1; i<=$num; i++ ));
    do echo "$(awk NR==$i ./currentipList.txt)"
    done)"
    
    #ファイアウォールに変更を加えますか？
    read -p "Do you really want to add those IP to Firewall rich-rules? (y/N): " yn
    case "$yn" in
        #if it's yes
        [yY]*) 
            for (( i=0; i<${#currentip[*]}; i++ ));
                do echo "    adding ${currentip[i]} to firewall..."
                firewall-cmd --add-rich-rule="rule family=ipv4 source address=${currentip[i]} port port=5060 protocol=udp accept"
            done
            dig +short ${HOSTNAME[*]} | sudo tee ./ipList.txt
            read -p "This program is going to REMOVE all the rich-rules you added, in case you accidently pressed y. Is that ok? (y/N): " yn
            case "$yn" in 
                [yY]*) 
                    richrule=(`firewall-cmd --list-rich-rules | sudo tee ./richrule.txt`)
                    num=$(cat ./richrule.txt | wc -l)
                    for (( i=1; i<=$num; i++ ));
                        do echo "    removing $(awk NR==$i ./richrule.txt) from firewall..."
                        firewall-cmd --remove-rich-rule="$(awk NR==$i ./richrule.txt)"
                    done ;;
            
                *) echo "these are the rich-rules applied to the system.
$(firewall-cmd --list-rich-rules)" ; exit ;;

            esac ;;
    
        #if it's no, do those below...
        *) richrule=(`firewall-cmd --list-rich-rules | sudo tee ./richrule.txt`)
            echo "these are the rich-rules already applied to the system." 
            $(for (( i=1; i<=$num; i++ ));
            do echo "$(awk NR==$i ./richrule.txt)"
            done);
            #ask to remove
            read -p "Do you want to remove all the rich-rules already exists? (y/N): " yn
                case "$yn" in 
                    [yY]*)
                    num=$(cat ./richrule.txt | wc -l)
                    for (( i=1; i<=$num; i++ ));
                        do echo "    removing $(awk NR==$i ./richrule.txt) from firewall..."
                        firewall-cmd --remove-rich-rule="$(awk NR==$i ./richrule.txt)"
                    done
                    exit ;;
                    #if it's no, do those below...
                    *) echo "Nothing has changed." ; exit ;;
                esac
    
    ;;
    esac
    



    
    
fi    

echo "these are the rich-rules applied to the system.
$(firewall-cmd --list-rich-rules)"

exit
#for i in $(seq 0 ${#LASTIP[*]});