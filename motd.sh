#Skript zur schnellen übersicht aller wichtigen Informationen
#Matthias van Gemmern
#2015.11.13

if [ "$USER" != 'root' ]
then
#!/bin/bash
echo --------------------------------------------------------------------------------
echo HOST
hostname -f
echo --------------------------------------------------------------------------------
echo VERSION
#cat /etc/*ease|tail -n 1
if [ "`cat /etc/*ease|tail -n 1|grep '6.7'`" != 0 ] || [ "`cat /etc/*ease|tail -n 1|grep '5.11'`" != 0 ] || [ "`cat /etc/*ease|tail -n 1|grep '7.2'`" != 0 ]
 then
  echo -en "\033[0;32m"
  cat /etc/*ease|tail -n 1
 else
  echo -en "\033[0;31m"
  cat /etc/*ease|tail -n 1
fi
echo -en "\033[0;35m\033[1;35m\033[0;31m\033[1;33m\033[0m"
echo --------------------------------------------------------------------------------
echo USER
APC=`w|sed '1d'|sed '1d'|tr -s " "|cut -d " " -f 1,3|cut -d "." -f 1|sed 's/ /|/g'`
for SRC in $APC
 do
 RECHNER=`echo $SRC|cut -d "|" -f 2`
 USER=`echo $SRC|cut -d "|" -f 1`
 if [ "`cat /mitarbeiterliste |grep $RECHNER|sed s/' '/''/g`" != "" ]
  then
  if [ `w|sed '1d'|sed '2d'|wc -l` -gt 1 ]
   then
   echo -en "\033[0;31m"
   echo "$USER `cat /mitarbeiterliste |grep $RECHNER|sed s/' '/''/g|cut -d "|" -f 2`"
   else
   echo -en "\033[0;32m"
   echo "$USER `cat /mitarbeiterliste |grep $RECHNER|sed s/' '/''/g|cut -d "|" -f 2`"
  fi
 fi
done
echo -en "\033[0;35m\033[1;35m\033[0;31m\033[1;33m\033[0m"
echo --------------------------------------------------------------------------------
echo SPACE
echo -en "\033[0;31m"
df -Ph | awk '+$5 >= 80 {print}'
echo -en "\033[0;35m\033[1;35m\033[0;31m\033[1;33m\033[0m"
echo --------------------------------------------------------------------------------
echo DATE
if [ "`pgrep ntpd`" != 0 ]
 then
  echo -en "\033[0;32m"
  date
fi
echo -en "\033[0;35m\033[1;35m\033[0;31m\033[1;33m\033[0m"
fi
