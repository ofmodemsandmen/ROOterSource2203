#!/bin/sh

LED=0
SM=$(uci get system.wifi2)
if [ -z $SM ]; then
	uci set system.wifi2=led
	uci set system.wifi2.name="2Ghzwifi"
	uci set system.wifi2.sysfs="wifi2"
	uci set system.wifi2.trigger="netdev"
	uci set system.wifi2.dev="wlan0"
	uci set system.wifi2.mode="link tx rx"
	
	uci set system.wifi5=led
	uci set system.wifi5.name="5Ghzwifi"
	uci set system.wifi5.sysfs="wifi5"
	uci set system.wifi5.trigger="netdev"
	uci set system.wifi5.dev="wlan1"
	uci set system.wifi5.mode="link tx rx"
	
	uci set system.net=led
	uci set system.net.name="net"
	uci set system.net.sysfs="net"
	uci set system.net.trigger="default-on"
	
	uci set system.5g1=led
	uci set system.5g1.name="5g1"
	uci set system.5g1.sysfs="5g1"
	uci set system.5g1.trigger="default-on"
	
	uci set system.5g2=led
	uci set system.5g2.name="5g2"
	uci set system.5g2.sysfs="5g2"
	uci set system.5g2.trigger="default-on"
	
	uci set system.mesh=led
	uci set system.mesh.name="mesh"
	uci set system.mesh.sysfs="mesh"
	uci set system.mesh.trigger="default-on"
	
	uci commit system
	/etc/init.d/led restart
fi

