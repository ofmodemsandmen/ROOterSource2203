#!/bin/sh
. /lib/functions.sh

SET=$1

cr=$(uci -q get travelmate.global.currrad)

uci set travelmate.global.state=$SET
uci commit travelmate

if [ $SET = "1" ]; then
	uci set travelmate.global.ssid="8"
	uci commit travelmate
	uci -q set wireless.wwan$cr.encryption="none"
	uci -q set wireless.wwan$cr.key=
	uci set wireless.wwan$cr.ssid="Hotspot Manager Interface"
	uci -q commit wireless
	/usr/lib/hotspot/hotspot.sh &
else
	cfreq=$(uci -q get travelmate.global.currrad)
	cstate=$(uci -q get travelmate.global.cstate)
	if [ ! -z "$cfreq" ]; then
		if [ ! -z "$cstate" ]; then
			PID=$(ps |grep "hotcheck.sh" | grep -v grep |head -n 1 | awk '{print $1}')
			if [ ! -z "$PID" ]; then
				kill -9 $PID
			fi
			uci -q set wireless.wwan$cfreq.disabled=1
			uci set wireless.wwan$cfreq.ssid="Not Selected"
			uci -q commit wireless
			/etc/init.d/network reload
		fi
	fi
	rm -f /tmp/hotman
	uci set travelmate.global.ssid="7"
	uci set travelmate.global.state="0"
	uci set travelmate.global.cstate="0"
	uci commit travelmate
fi