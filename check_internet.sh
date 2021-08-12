#!/bin/bash
#config provaider
ipBasic=127.0.0.1
checkPortBasic="20"
ipReserv=localhost
checkPortResrv="22"

#telegram config
Token="TOKEN_TELEGRAM"
Chat="CHATT_ID_TELEGRAM"
URL="https://api.telegram.org/bot$Token/sendMessage"

#message config
# _ITALIC_
# *BOLD*
Working=*Работает.*
notWorking="*НЕ РАБОТАЕТ.*"
basicInternet="_Основной интернет:_"
reservInternet="_Резервный интернет:_"
if [[ ! -e ./oldStatus.txt ]]
then
	touch ./oldStatus.txt
fi
curTime=$(date +%H)
if [ $curTime -gt  20 ] || [ $curTime -lt 8 ] ; then
	muteMod=True
else
	muteMod=False
fi

#Basic
ping -q -c5 $ipBasic > /dev/null
pingBasic=$?

if [ "$pingBasic" = 1 ]; then
	nc -z -w 5 $ipBasic $checkPortBasic
	portBasic=$?
	if [ "$portBasic" = 1 ]; then
		messageBasic="$basicInternet  $notWorking%0A"
		echo 0 > curStatus.txt
	fi
else
		messageBasic="$basicInternet  $Working%0A"
		echo 1 > curStatus.txt
fi


#Reserv
ping -q -c5 $ipReserv > /dev/null
pingReserv=$? 
if [ "$pingReserv" = 1 ]; then
	nc -z -w 5 $ipReserv $checkPortResrv
	portReserv=$?
	if [ "$portReserv" = 1 ]; then
		messageReserv="$reservInternet $notWorking%0A"
		echo 0 >> curStatus.txt
	fi
else
	messageReserv="$reservInternet $Working%0A"
	echo 1 >> curStatus.txt
fi

message="Состояние интернета:%0A$messageBasic$messageReserv"

cmp -s ./curStatus.txt ./oldStatus.txt
if [[ $? != 0 ]] ; then
	curl -s "https://api.telegram.org/bot$Token/sendMessage?chat_id=$Chat&parse_mode=markdown&text=$message&disable_notification=$muteMod" >/dev/null
	rm ./oldStatus.txt
	mv ./curStatus.txt ./oldStatus.txt
fi