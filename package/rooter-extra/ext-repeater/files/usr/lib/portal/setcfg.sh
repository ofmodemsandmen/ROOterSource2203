#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Save Portal" "$@"
}

sett=$1
ppass=$(echo $sett | cut -d, -f1)
time=$(echo $sett | cut -d, -f2)
boot=$(echo $sett | cut -d, -f3)

uci set portal.portal.portalpassword=$ppass
uci set portal.portal.time=$time
uci set portal.portal.boot=$boot
uci commit portal

/usr/lib/portal/update.sh
