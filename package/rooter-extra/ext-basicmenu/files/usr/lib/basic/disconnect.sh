#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Disconnect" "$@"
}

cfreq=$(uci -q get basic.basic.freq)
cstate=$(uci -q get basic.basic.cstate)
uci set basic.basic.state=''
uci set basic.basic.cstate=''
uci set basic.basic.ssid=''
uci set basic.basic.password=''
uci set basic.basic.freq=''
uci set basic.basic.disconnect='1'
uci commit basic

if [ ! -z "$cfreq" ]; then
	if [ ! -z "$cstate" ]; then
		PID=$(ps |grep "check.sh" | grep -v grep |head -n 1 | awk '{print $1}')
		if [ ! -z "$PID" ]; then
			kill -9 $PID
		fi
		uci -q set wireless.wwan$cfreq.disabled=1
		uci set wireless.wwan$cfreq.ssid="Not Selected"
		uci -q commit wireless
		/etc/init.d/network reload
	fi
fi


