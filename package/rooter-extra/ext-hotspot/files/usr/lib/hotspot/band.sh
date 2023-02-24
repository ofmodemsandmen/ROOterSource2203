#!/bin/sh 

log() {
	logger -t "band change" "$@"
}

BAND=$1
uci set travelmate.global.currrad=$BAND
uci commit travelmate
exit 0
