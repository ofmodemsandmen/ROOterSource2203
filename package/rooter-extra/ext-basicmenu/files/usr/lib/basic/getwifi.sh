#!/bin/sh
. /lib/functions.sh

do_radio() {
	local config=$1
	local hwmode
	local channel

	config_get hwmode $1 hwmode
	config_get channel $1 channel
	config_get disabled $1 disabled
	if [ $hwmode = "11g" ]; then
		radio2=$config
		channel2=$channel
		disabled2=$disabled
	else
		radio5=$config
		channel5=$channel
		disabled5=$disabled
	fi

}

radio5="--"
channel5="--"
disabled5="--"
		
config_load wireless
config_foreach do_radio wifi-device
ssid2=$(uci -q get wireless.default_$radio2.ssid)
ssid5=$(uci -q get wireless.default_$radio5.ssid)
if [ -z "$ssid5" ]; then
	ssid5="--"
fi

echo "$disabled2" > /tmp/bwireless
echo "$ssid2" >> /tmp/bwireless
echo "$channel2" >> /tmp/bwireless
echo "$disabled5" >> /tmp/bwireless
echo "$ssid5" >> /tmp/bwireless
echo "$channel5" >> /tmp/bwireless
echo "0" >> /tmp/bwireless