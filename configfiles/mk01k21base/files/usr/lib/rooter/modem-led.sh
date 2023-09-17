#!/bin/sh

log() {
	logger -t "modem-led " "$@"
}

CURRMODEM=$1
COMMD=$2

	case $COMMD in
		"0" )
			echo none > /sys/class/leds/led:4gblue/trigger
			echo 0  > /sys/class/leds/led:4gblue/brightness
			echo none > /sys/class/leds/led:4gorange/trigger
			echo 0  > /sys/class/leds/led:4gorange/brightness
			echo none > /sys/class/leds/led:5gblue/trigger
			echo 0  > /sys/class/leds/led:5gblue/brightness
			echo none > /sys/class/leds/led:5gorange/trigger
			echo 0  > /sys/class/leds/led:5gorange/brightness
			;;
		"1" )
			echo timer > /sys/class/leds/led:4gorange/trigger
			echo 500  > /sys/class/leds/led:4gorange/delay_on
			echo 500  > /sys/class/leds/led:4gorange/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/led:4gorangetrigger
			echo 200  > /sys/class/leds/led:4gorange/delay_on
			echo 200  > /sys/class/leds/led:4gorange/delay_off
			;;
		"3" )
			echo timer > /sys/class/leds/led:4gorange/trigger
			echo 1000  > /sys/class/leds/led:4gorange/delay_on
			echo 0  > /sys/class/leds/led:4gorange/delay_off
			;;
		"4" )
			echo none > /sys/class/leds/led:4gblue/trigger
			echo 1  > /sys/class/leds/led:4gblue/brightness
			echo none > /sys/class/leds/led:4gorange/trigger
			echo 0  > /sys/class/leds/led:4gorange/brightness
			mode=0
			if [ -e /tmp/modnetwork ]; then
				mode=1
			fi
			if [ $mode = '1' ]; then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 1  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 0  > /sys/class/leds/led:5gorange/brightness
			else
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 0  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 1  > /sys/class/leds/led:5gorange/brightness
			fi
			exit 0
			sig2=$3
			if [ $sig2 -lt 18 -a $sig2 -gt 0 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 0  > /sys/class/leds/led:5gblue/brightness
				echo timer > /sys/class/leds/led:5gorange/trigger
				echo 500  > /sys/class/leds/led:5gorange/delay_on
				echo 500  > /sys/class/leds/led:5gorange/delay_off
			elif [ $sig2 -ge 18 -a $sig2 -lt 31 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 0  > /sys/class/leds/led:5gblue/brightness
				echo timer > /sys/class/leds/led:5gorange/trigger
				echo 150  > /sys/class/leds/led:5gorange/delay_on
				echo 150  > /sys/class/leds/led:5gorange/delay_off
			elif [ $sig2 -eq 31 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 0  > /sys/class/leds/led:5gorange/brightness
				echo timer > /sys/class/leds/led:5gblue/trigger
				echo 0  > /sys/class/leds/led:5gblue/delay_on
				echo 1000  > /sys/class/leds/led:5gblue/delay_off
			else
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 0  > /sys/class/leds/led:5gorange/brightness
				echo timer > /sys/class/leds/led:5gblue/trigger
				echo 950  > /sys/class/leds/led:5gblue/delay_on
				echo 950  > /sys/class/leds/led:5gblue/delay_off
			fi
			;;
	esac
