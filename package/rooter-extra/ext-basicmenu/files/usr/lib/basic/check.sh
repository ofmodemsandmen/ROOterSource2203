#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Check Disconnect" "$@"
}

f_check()
{
	mode="${1}"
	RADIO=$(uci get wireless.wwan$cfreq.device)
	ifname="$(ubus -S call network.wireless status | jsonfilter -l 1 -e "@.$RADIO.interfaces[@.config.mode=\"${mode}\"].ifname")"
	if [ "${mode}" = "sta" ]
	then
		trm_ifstatus="$(ubus -S call network.interface dump | jsonfilter -e "@.interface[@.device=\"${ifname}\"].up")"
	else
		trm_ifstatus="$(ubus -S call network.wireless status | jsonfilter -l1 -e '@.*.up')"
	fi
}

cfreq=$1
f_check "sta"
while [ "${trm_ifstatus}" = "true" ]; do
	sleep 5
	f_check "sta"
done

discon=$(uci -q get basic.basic.disconnect)
reconn=$(uci -q get basic.basic.reconn)
log " "
log "Wifi Disconnect"
log " "
uci set basic.basic.disconnect='1'
uci commit basic
uci -q set wireless.wwan$cfreq.disabled=1
uci set wireless.wwan$cfreq.ssid="Not Selected"
uci -q commit wireless
ubus call network reload
uci set basic.basic.state='0'
uci set basic.basic.cstate='0'
uci commit basic
if [ "$reconn" = "1" ]; then
	if [ "$discon" = "0" ]; then
		log " "
		log "Automatic Reconnect"
		log " "
		/usr/lib/basic/connect.sh
	fi
fi
