#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "HOTSPOT" "$@"
}

f_check()
{
	mode="${1}"
	RADIO=$(uci get wireless.wwan$freq.device)
	ifname="$(ubus -S call network.wireless status | jsonfilter -l 1 -e "@.$RADIO.interfaces[@.config.mode=\"${mode}\"].ifname")"
	if [ "${mode}" = "sta" ]
	then
		trm_ifstatus="$(ubus -S call network.interface dump | jsonfilter -e "@.interface[@.device=\"${ifname}\"].up")"
	else
		trm_ifstatus="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.up')"
	fi
}

tryconnect() {
	for apx in 1 2
	do
		uci set travelmate.global.state='1'
		uci set travelmate.global.cstate='1'
		uci set travelmate.global.disconnect='0'
		uci set travelmate.global.ssid=">>> $ssid"
		uci commit travelmate
		wifi up $(uci -q get wireless.wwan$freq.device)
		ubus call network.interface.wwan up
		ubus call network reload

		sleep 5
		# wait and check for good connection
		f_check "ap"

		while [ "${trm_ifstatus}" != "true" ]; do
			sleep 1
			f_check "ap"
		done
		cnt=0
		delay=20
		f_check "sta"
		while [ "${trm_ifstatus}" != "true" ]; do
			sleep 1
			f_check "sta"
			let cnt=cnt+1
			if [ $cnt -ge $delay ]; then
				break
			fi
		done
		if [ "${trm_ifstatus}" = "true" ]; then
			uci set travelmate.global.state='2'
			uci set travelmate.global.cstate='2'
			uci set travelmate.global.disconnect='0'
			uci set travelmate.global.ssid="$ssid"
			uci commit travelmate
			result=`ps | grep -i "hotcheck.sh" | grep -v "grep" | wc -l`
			if [ $result -lt 1 ]; then
				/usr/lib/hotspot/hotcheck.sh $freq &
			fi
			
			exit 0
		else
			uci set travelmate.global.state='0'
			uci set travelmate.global.cstate='0'
			uci set travelmate.global.disconnect='1'
			uci set travelmate.global.ssid="3"
			uci commit travelmate
			log " "
			log "WLAN Connection failed"
			log " "
			uci -q set wireless.wwan$freq.disabled=1
			uci set wireless.wwan$freq.ssid="Not Selected"
			uci -q commit wireless
			ubus call network reload
		fi
	done
}

freq=$(uci -q get travelmate.global.currrad)

while IFS='|' read -r ssid psk pass visible
do
	if [ $visible = "1" ]; then
		log "$ssid"
		uci -q set wireless.wwan$freq.ssid="$ssid"
		uci -q set wireless.wwan$freq.encryption="$psk"
		uci -q set wireless.wwan$freq.key="$pass"
		uci -q set wireless.wwan$freq.disabled=0
		uci -q commit wireless
		tryconnect
	fi
	uci set travelmate.global.ssid="3"
	uci commit travelmate
done < /etc/hot	
uci set travelmate.global.ssid="5"
uci commit travelmate