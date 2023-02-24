#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Check Disconnect" "$@"
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

freq=$(uci -q get basic.basic.freq)
if [ -z $freq ]; then
	exit 0
fi
ssid=$(uci -q get basic.basic.ssid)
if [ -z $ssid ]; then
	exit 0
fi
psk=$(uci -q get basic.basic.psk)
if [ -z $psk ]; then
	exit 0
fi
pass=$(uci -q get basic.basic.password)


uci -q set wireless.wwan$freq.ssid="$ssid"
uci -q set wireless.wwan$freq.encryption="$psk"
uci -q set wireless.wwan$freq.key="$pass"
uci -q set wireless.wwan$freq.disabled=0
uci -q commit wireless

for apx in 1 2
do
	uci set basic.basic.state='1'
	uci set basic.basic.cstate='1'
	uci set basic.basic.disconnect='0'
	uci commit basic
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
		uci set basic.basic.state='2'
		uci set basic.basic.cstate='2'
		uci set basic.basic.disconnect='0'
		uci commit basic
		result=`ps | grep -i "check.sh" | grep -v "grep" | wc -l`
		if [ $result -lt 1 ]; then
			/usr/lib/basic/check.sh $freq &
		fi
		
		exit 0
	else
		uci set basic.basic.state='0'
		uci set basic.basic.cstate='0'
		uci set basic.basic.disconnect='1'
		uci commit basic
		log " "
		log "WLAN Connection failed"
		log " "
		uci -q set wireless.wwan$freq.disabled=1
		uci set wireless.wwan$freq.ssid="Not Selected"
		uci -q commit wireless
		#wifi up $(uci -q get wireless.wwan$freq.device)
		#ubus call network.interface.wwan up
		ubus call network reload
	fi
done

									