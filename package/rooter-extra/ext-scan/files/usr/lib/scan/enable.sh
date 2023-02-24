#!/bin/sh
. /lib/functions.sh

set=$1

uci set bandscan.info.enabled=$set
uci commit bandscan

if [ -e /etc/cronbase ]; then
	sed -i '/scan.sh/d' /etc/cronbase
fi
if [ $set = "1" ]; then
	repeat=$(uci -q get bandscan.info.repeat)
	tim=$(uci -q get bandscan.info.time)
	HOUR=${tim:0:2}
	MIN=${tim:3:2}
	if [ "$repeat" = "1" -o "$repeat" = "0" ]; then
		echo "$MIN $HOUR * * * /usr/lib/scan/scanchk.sh &" >> /etc/cronbase
	fi
	if [ "$repeat" = "2" ]; then
		dayweek=$(uci -q get bandscan.info.dayweek)
		echo "$MIN $HOUR * * "$dayweek" /usr/lib/scan/scanchk.sh &" >> /etc/cronbase
	fi
	if [ "$repeat" = "3" ]; then
		daymon=$(uci -q get bandscan.info.daymon)
		echo "$MIN $HOUR "$daymon" * * /usr/lib/scan/scanchk.sh &" >> /etc/cronbase
	fi
else
	result=`ps | grep -i "scan.sh" | grep -v "grep" | wc -l`
	if [ $result -lt 1 ]; then
		PID=$(ps | grep "scan.sh" | awk '{print $1}')
		if [ ! -z "$PID" ]; then
			kill -9 $PID
			retmask=$(head -n 2 /tmp/bmask)
			/usr/lib/rooter/luci/lock.sh "$retmask" 1
		fi
		uci set bandscan.info.running="1"
		uci commit bandscan
	fi
fi

/usr/lib/rooter/luci/croncat.sh