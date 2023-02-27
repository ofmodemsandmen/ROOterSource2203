#!/bin/sh

log() {
	modlog "modem-led " "$@"
}

CURRMODEM=$1
COMMD=$2

DEV=$(uci get modem.modem$CURRMODEM.device)
if [ $COMMD -lt 4 ]; then
	log "$COMMD $DEV"
fi
if [ $DEV = "2-1.2" -o $DEV = "1-1.2" ]; then
	case $COMMD in
		"0" )
			uci -q delete system.5g1
			uci commit system
			/etc/init.d/led restart
			echo none > /sys/class/leds/5g1/trigger
			echo 1  > /sys/class/leds/5g1/brightness
			;;
		"1" )
			echo timer > /sys/class/leds/5g1/trigger
			echo 500  > /sys/class/leds/5g1/delay_on
			echo 500  > /sys/class/leds/5g1/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/5g1/trigger
			echo 200  > /sys/class/leds/5g1/delay_on
			echo 200  > /sys/class/leds/5g1/delay_off
			;;
		"3" )
			echo none > /sys/class/leds/5g1/trigger
			echo 0  > /sys/class/leds/5g1/brightness
			INTER=$(uci get modem.modem$CURRMODEM.interface)
			uci set system.5g1=led
			uci set system.5g1.name="5g1"
			uci set system.5g1.sysfs="5g1"
			uci set system.5g1.trigger="netdev"
			uci set system.5g1.dev="$INTER"
			uci set system.5g1.mode="link tx rx"
			uci commit system
			/etc/init.d/led restart
			;;
	esac
else
	case $COMMD in
		"0" )
			uci -q delete system.5g2
			uci commit system
			/etc/init.d/led restart
			echo none > /sys/class/leds/5g2/trigger
			echo 1  > /sys/class/leds/5g2/brightness
			;;
		"1" )
			echo timer > /sys/class/leds/5g2/trigger
			echo 500  > /sys/class/leds/5g2/delay_on
			echo 500  > /sys/class/leds/5g2/delay_off
			;;
		"2" )
			echo timer > /sys/class/leds/5g2/trigger
			echo 200  > /sys/class/leds/5g2/delay_on
			echo 200  > /sys/class/leds/5g2/delay_off
			;;
		"3" )
			echo none > /sys/class/leds/5g2/trigger
			echo 0  > /sys/class/leds/5g2/brightness
			INTER=$(uci get modem.modem$CURRMODEM.interface)
			uci set system.5g2=led
			uci set system.5g2.name="5g2"
			uci set system.5g2.sysfs="5g2"
			uci set system.5g2.trigger="netdev"
			uci set system.5g2.dev="$INTER"
			uci set system.5g2.mode="link tx rx"
			uci commit system
			/etc/init.d/led restart
			;;
	esac
fi