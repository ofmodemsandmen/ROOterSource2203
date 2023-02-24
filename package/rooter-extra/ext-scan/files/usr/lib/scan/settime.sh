#!/bin/sh
. /lib/functions.sh

set=$1

uci set bandscan.info.time=$set
uci commit bandscan