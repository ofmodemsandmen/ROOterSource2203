#!/bin/sh
. /lib/functions.sh

ROOTER_LINK="/tmp/links"
ROOTER=/usr/lib/rooter

log() {
	logger -t "WLAN" "$@"
}

set=$1
cur=$(uci -q get basic.basic.wifi)
if [ $set = $cur ]; then
	exit 0
fi
uci set basic.basic.wifi="$set"
uci commit basic