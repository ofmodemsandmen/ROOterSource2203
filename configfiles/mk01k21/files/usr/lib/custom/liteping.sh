#!/bin/sh

. /lib/functions.sh
 
ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	logger -t "Top Lite Ping Test " "$@"
}

CURRMODEM=1
while [ true ]
do
	conn=$(uci -q get modem.modem$CURRMODEM.connected)
	if [ "$conn" = "0" ]; then
		rm -f /tmp/liteping
		if [ -e /tmp/toplite ]; then
			# blue off
			echo none > /sys/class/leds/top:5gblue/trigger
			echo 1  > /sys/class/leds/top:5gblue/brightness
			# red on
			echo none > /sys/class/leds/top:5gred/trigger
			echo 1  > /sys/class/leds/top:5gred/brightness
		fi
	else
		echo 1 > /tmp/liteping
		if [ -e /tmp/toplite ]; then
			mode=0
			if [ -e /tmp/modnetwork ]; then
				mode=1
			fi
			if [ $mode = '1' ]; then
				echo none > /sys/class/leds/top:5gblue/trigger
				echo 0  > /sys/class/leds/top:5gblue/brightness
				# red off
				echo none > /sys/class/leds/top:5gred/trigger
				echo 0  > /sys/class/leds/top:5gred/brightness
			else
				echo none > /sys/class/leds/top:5gblue/trigger
				echo 0  > /sys/class/leds/top:5gblue/brightness
				# red off
				echo none > /sys/class/leds/top:5gred/trigger
				echo 1  > /sys/class/leds/top:5gred/brightness
			fi
		fi
	fi
	sleep 20
done