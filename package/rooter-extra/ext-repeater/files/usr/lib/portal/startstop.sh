#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Start/Stop Portal" "$@"
}

cmd=$1
log "Start/Stop Portal $cmd"

if [ $cmd = "1" ]; then
	uci set portal.portal.enabled=$cmd
	uci commit portal
	uci set nodogsplash.nodogsplash.enabled='1'
	uci commit nodogsplash
	/etc/init.d/nodogsplash start
	/usr/lib/portal/block 1
fi

if [ $cmd = "0" ]; then
	uci set portal.portal.enabled=$cmd
	uci commit portal
	uci set nodogsplash.nodogsplash.enabled='0'
	uci commit nodogsplash
	/etc/init.d/nodogsplash stop
	/usr/lib/portal/block 0
fi