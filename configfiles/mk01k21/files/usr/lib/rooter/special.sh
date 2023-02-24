#!/bin/sh

LED=0
SM=$(uci get system.led_wifi0)
if [ -z $SM ]; then
	uci set system.led_wifi0=led
	uci set system.led_wifi0.name="WIFI"
	uci set system.led_wifi0.sysfs="blue:wifi"
	uci set system.led_wifi0.trigger="netdev"
	uci set system.led_wifi0.dev="wlan0"
	uci set system.led_wifi0.mode="link tx rx"
	LED=1
fi

if [ $LED -eq 1 ]; then
	uci commit system
	/etc/init.d/led restart
fi

i=496
echo $i > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio$i/direction
echo "1" > /sys/class/gpio/gpio$i/value
sleep 5
echo "0" > /sys/class/gpio/gpio$i/value

/usr/lib/custom/liteping.sh &
