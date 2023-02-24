#!/bin/sh
. /lib/functions.sh

email() {
	email=$(uci -q get custom.texting.email)
		
	host=$(uci -q get custom.texting.smtp)
	user=$(uci -q get custom.texting.euser)	
	pass=$(uci -q get custom.texting.epass)

	STEMP="/tmp/eemail"
	MSG="/usr/lib/scan/msmtprc"
	DST="/etc/msmtprc"
	rm -f $STEMP
	cp $MSG $STEMP
	sed -i -e "s!#HOST#!$host!g" $STEMP
	sed -i -e "s!#USER#!$user!g" $STEMP
	sed -i -e "s!#PASS#!$pass!g" $STEMP
	mv $STEMP $DST

	STEMP="/tmp/emailmsg"
	MSG="/usr/lib/scan/message"
	rm -f $STEMP
	cp $MSG $STEMP
	ident="Scanning"
	message=$(cat /etc/scantest)
	echo " " >> /tmp/emailmsg
	echo " " >> /tmp/emailmsg
	sed -i -e "s!#EMAIL#!$email!g" $STEMP
	sed -i -e "s!#IDENT#!$ident!g" $STEMP
	echo "$message" >> /tmp/emailmsg
	mess=$(cat /tmp/emailmsg)
	echo "$mess" > /tmp/emailmsg
	echo -e "$mess" | msmtp --read-envelope-from --read-recipients
}

sleep 300
conn=$(uci -q get modem.modem1.connected)
if [ $conn = "1" ]; then
	email
else
	/usr/lib/rooter/luci/restart.sh 1
	sleep 500
	conn=$(uci -q get modem.modem1.connected)
	if [ $conn = "1" ]; then
		email
		uci set bandscan.info.email="0"
		uci commit bandscan
	else
		uci set bandscan.info.email="1"
		uci commit bandscan
		reboot -f
	fi
fi