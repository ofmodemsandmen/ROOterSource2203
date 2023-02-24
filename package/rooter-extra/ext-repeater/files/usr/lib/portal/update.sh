#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Portal Auth" "$@"
}

lang=$(uci -q get luci.main.lang)
if [ $lang = "de" ]; then
	STATUS="/usr/lib/portal/splash-de.html"
	STATUS1="/usr/lib/portal/status-de.html"
else
	STATUS="/usr/lib/portal/splash-en.html"
	STATUS1="/usr/lib/portal/status-en.html"
fi

STEMP="/tmp/stemp.html"
SPSTATUS="/etc/nodogsplash/htdocs/splash.html"
rm -f $STEMP
cp $STATUS $STEMP

time=$(uci -q get portal.portal.time)
let time=time/3600
sed -i -e "s!#TIME#!$time!g" $STEMP
mv $STEMP $SPSTATUS

SPSTATUS="/etc/nodogsplash/htdocs/status.html"
rm -f $STEMP
cp $STATUS1 $STEMP
mv $STEMP $SPSTATUS