#!/bin/sh

log() {
	logger -t "modem-led " "$@"
}

CURRMODEM=$1
COMMD=$2
sig2=$3

	case $COMMD in
		"0" )
			echo none > /sys/class/leds/led:5gblue/trigger
			echo 0  > /sys/class/leds/led:5gblue/brightness
			echo none > /sys/class/leds/led:5gorange/trigger
			echo 0  > /sys/class/leds/led:5gorange/brightness
			echo none > /sys/class/leds/led:4gblue/trigger
			echo 0  > /sys/class/leds/led:4gblue/brightness
			echo none > /sys/class/leds/led:4gorange/trigger
			echo 0  > /sys/class/leds/led:4gorange/brightness
			;;
		"4" )
			if [ $sig2 -lt 10 -a $sig2 -ge 0 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 1  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 0  > /sys/class/leds/led:5gorange/brightness
				echo none > /sys/class/leds/led:4gblue/trigger
				echo 0  > /sys/class/leds/led:4gblue/brightness
				echo none > /sys/class/leds/led:4gorange/trigger
				echo 0  > /sys/class/leds/led:4gorange/brightness
			elif [ $sig2 -ge 10 -a $sig2 -lt 15 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 1  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 1  > /sys/class/leds/led:5gorange/brightness
				echo none > /sys/class/leds/led:4gblue/trigger
				echo 0  > /sys/class/leds/led:4gblue/brightness
				echo none > /sys/class/leds/led:4gorange/trigger
				echo 0  > /sys/class/leds/led:4gorange/brightness
			elif [ $sig2 -ge 15 -a $sig2 -lt 20 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 1  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 1  > /sys/class/leds/led:5gorange/brightness
				echo none > /sys/class/leds/led:4gblue/trigger
				echo 1  > /sys/class/leds/led:4gblue/brightness
				echo none > /sys/class/leds/led:4gorange/trigger
				echo 0  > /sys/class/leds/led:4gorange/brightness
			elif [ $sig2 -ge 20 -a $sig2 -le 31 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 1  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 1  > /sys/class/leds/led:5gorange/brightness
				echo none > /sys/class/leds/led:4gblue/trigger
				echo 1  > /sys/class/leds/led:4gblue/brightness
				echo none > /sys/class/leds/led:4gorange/trigger
				echo 1  > /sys/class/leds/led:4gorange/brightness
			elif [ $sig2 -gt 31 ] 2>/dev/null;then
				echo none > /sys/class/leds/led:5gblue/trigger
				echo 0  > /sys/class/leds/led:5gblue/brightness
				echo none > /sys/class/leds/led:5gorange/trigger
				echo 0  > /sys/class/leds/led:5gorange/brightness
				echo none > /sys/class/leds/led:4gblue/trigger
				echo 0  > /sys/class/leds/led:4gblue/brightness
				echo none > /sys/class/leds/led:4gorange/trigger
				echo 0  > /sys/class/leds/led:4gorange/brightness
			fi
			;;
	esac
