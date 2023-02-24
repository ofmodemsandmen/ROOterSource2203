#!/bin/sh
. /lib/functions.sh

freq=$(uci -q get travelmate.global.currrad)
rm -f /tmp/hotman
uci set travelmate.global.ssid="7"
uci commit travelmate
uci -q set wireless.wwan$freq.disabled=1
uci set wireless.wwan$freq.ssid="Hotspot Manager Interface"
uci -q commit wireless
#ifdown wwan
#ubus call network reload
/etc/init.d/network reload

