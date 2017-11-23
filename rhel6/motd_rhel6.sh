#Short Motd Script
#tested in rhel6
#Matthias van Gemmern
#2017.07.03
#!/bin/bash

if [ "$USER" != 'root' ]
    color_on="\033[0;31m"
        color_off="\033[0;35m\033[1;35m\033[0;31m\033[1;33m\033[0m"
    then
    echo --------------------------------------------------------------------------------
        #HOSTNAME
    echo "HOSTNAME:" `hostname -f`

        #RELEASE
    echo -n "RELEASE: "
        cat /etc/*ease|tail -n 1
        #USER
    if [ `w|sed '1,2d'|tr -s " "|cut -d " " -f 1|uniq|wc -l` -gt 1 ] && [ `w|sed '1,2d'|tr -s " "|cut -d " " -f 3|uniq|wc -l` -gt 1 ] #Wenn mehr als ein einzigartiger user UND mehr als ein APC verbunden
    then
        USERS=`w|sed '1,2d'|tr -s " "|cut -d " " -f 1|uniq`
        for USER in $USERS
        do
            echo -e $color_on"USER: $USER"$color_off
        done
        fi
        #HARDDRIVE
        if [ ! -z `df -Ph | awk '+$5 >= 90 {print}'|awk '{ print $1 }'` ]
        then
                echo -en $color_on"SPEICHER: "
                df -Ph | awk '+$5 >= 90 {print}'  #Speicher belegt über 90%
                echo -en $color_off
        fi

        if [ ! -z `df -Pi | awk '+$5 >= 90 {print}'|awk '{ print $1 }'` ];
        then
                echo -en $color_on"INODES: "
                df -Pi | awk '+$5 >= 90 {print}'  #Inodes belegt über 90%
                echo -en $color_off
        fi
        #NTP
        if [ -z `pgrep ntpd` ]
        then
                echo DATE
                echo -e $color_on`date`$color_off
        fi
        #FIREWALL
        #/sbin/lsmod|grep ip_tables/sbin/lsmod|grep ip_tables rhel only
        echo --------------------------------------------------------------------------------
fi
