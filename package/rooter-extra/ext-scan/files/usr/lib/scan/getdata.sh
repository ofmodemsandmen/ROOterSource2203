#!/bin/sh
. /lib/functions.sh

getisp() {
	local config=$1
	local name used single ca2 ca3

	config_get name $1 name
	config_get used $1 used
	config_get single $1 single
	config_get ca2 $1 ca2
	config_get ca3 $1 ca3
	if [ -z "$ca2" ]; then
		ca2="0"
	fi
	if [ -z "$ca3" ]; then
		ca3="0"
	fi
	config_get iccid $1 iccid
	echo "$name|$used|$single|$ca2|$ca3|$iccid" >> /tmp/ispinfo
	let ispcnt=ispcnt+1
}

rm -f /tmp/ispinfo
ispcnt=0
config_load bandscan
config_foreach getisp isp
uci set bandscan.info.ispcnt="$ispcnt"
uci commit bandscan