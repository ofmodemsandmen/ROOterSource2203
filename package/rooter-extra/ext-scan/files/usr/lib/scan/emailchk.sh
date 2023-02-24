#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "ScanChkt" "$@"
}

eml=$(uci -q get bandscan.info.email)
if [ "$eml" = "1" ]; then
	result=`ps | grep -i "email.sh" | grep -v "grep" | wc -l`
	if [ $result -lt 1 ]; then
		/usr/lib/scan/email.sh &
	fi
fi