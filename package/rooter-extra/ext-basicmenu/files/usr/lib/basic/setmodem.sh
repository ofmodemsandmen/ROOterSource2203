#!/bin/sh
. /lib/functions.sh

ROOTER_LINK="/tmp/links"
ROOTER=/usr/lib/rooter

log() {
	logger -t "Enable/Disable Modem" "$@"
}

set=$1
cur=$(uci -q get basic.basic.modem)
if [ $set = $cur ]; then
	exit 0
fi

uci set basic.basic.modemh="1"
uci commit basic

if [ $set = "1" ]; then
	act=$(uci -q get modem.modem1.active)
	if [ "$act" = "1" ]; then
		/usr/lib/rooter/luci/restart.sh 1 &
	fi
	uci set basic.basic.modem="$set"
	uci set basic.basic.modemh="0"
	uci commit basic
else
	CPORT=$(uci -q get modem.modem1.commport)
	if [ ! -z $CPORT ]; then
		PROT=$(uci get modem.modem1.proto)
		uci set modem.modem1.connected=0
		uci commit modem
		INTER=$(uci get modem.modeminfo1.inter)

		jkillall create_proto1
		rm -f $ROOTER_LINK/create_proto1
		jkillall getsignal1
		rm -f $ROOTER_LINK/getsignal1
		jkillall con_monitor1
		rm -f $ROOTER_LINK/con_monitor1
		ifdown wan$INTER
		case $PROT in
		"30" )
			ATCMDD="AT+CFUN=0"
			$ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "1" "$ATCMDD"
			;;
		"3" )
			WDMNX=$(uci get modem.modem1.wdm)
			umbim -n -t 3 -d /dev/cdc-wdm$WDMNX disconnect
			;;
		* )
			$ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "reset.gcom" "1"
			;;
		esac
		$ROOTER/signal/status.sh 1 "Modem Present/Not Connected"
	fi
	log "Modem Disabled"
	uci set basic.basic.modem="$set"
	uci set basic.basic.modemh="0"
	uci commit basic
fi