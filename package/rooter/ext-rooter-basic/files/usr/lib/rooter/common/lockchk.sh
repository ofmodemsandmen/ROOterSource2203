#!/bin/sh

ROOTER=/usr/lib/rooter

log() {
	logger -t "Lock Provider" "$@"
}

setautocops() {
	case $NETMODE in
		"3")
			ATCMDD="AT+COPS=0,,,0" ;;
		"5")
			ATCMDD="AT+COPS=0,,,2" ;;
		"7")
			ATCMDD="AT+COPS=0,,,7" ;;
		"8")
			ATCMDD="AT+COPS=0,,,13" ;;
		"9")
			ATCMDD="AT+COPS=0,,,12" ;;
		*)
			ATCMDD="AT+COPS=0" ;;
	esac
	OX=$($ROOTER/gcom/gcom-locked "$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
	log "$OX"
	exit 0
}

CURRMODEM=$1
if [ -e /usr/lib/netroam/lock.sh ]; then
	if [ -e /tmp/rlock ]; then
		/usr/lib/netroam/lock.sh $CURRMODEM
		exit 0
	fi
fi
CPORT=/dev/ttyUSB$(uci get modem.modem$CURRMODEM.commport)
NETMODE=$(uci -q get modem.modem$CURRMODEM.netmode)
LOCK=$(uci -q get modem.modeminfo$CURRMODEM.lock)
if [ "$LOCK" = "2" ]; then
	LOCK="4"
fi
ATCMDD="AT+COPS=3,2;+COPS?"
OX=$($ROOTER/gcom/gcom-locked "$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
COPSMODE=$(echo $OX | grep -o "+COPS:[ ]\?[014]" | grep -o "[014]")
COPSPLMN=$(echo $OX | grep -o "[0-9]\{5,6\}")

if [ -z "$LOCK" -o "$LOCK" = "0" ]; then
	if [ "$COPSMODE" = "0" ]; then
		exit 0
	fi
	setautocops
fi
MCC=$(uci -q get modem.modeminfo$CURRMODEM.mcc)
LMCC=${#MCC}
if [ $LMCC -ne 3 ]; then
	setautocops
fi
MNC=$(uci -q get modem.modeminfo$CURRMODEM.mnc)
if [ -z "$MNC" ]; then
	setautocops
fi
LMNC=${#MNC}
if [ $LMNC -eq 1 ]; then
	MNC=0$MNC
fi
if [ "$COPSMODE$COPSPLMN" = "$LOCK$MCC$MNC" ]; then
	exit 0
fi
case $NETMODE in
	"3")
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\",0" ;;
	"5")
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\",2" ;;
	"7")
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\",7" ;;
	"8")
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\",13" ;;
	"9")
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\",12" ;;
	*)
		ATCMDD="AT+COPS=$LOCK,2,\"$MCC$MNC\"" ;;
esac

OX=$($ROOTER/gcom/gcom-locked "$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")

ERROR="ERROR"
if `echo ${OX} | grep "${ERROR}" 1>/dev/null 2>&1`
then
	log "Error While Locking to Provider"
else
	log "Locked to Provider $MCC $MNC"
fi
