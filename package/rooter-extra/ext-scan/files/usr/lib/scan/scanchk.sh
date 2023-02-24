#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "ScanChkt" "$@"
}

result=`ps | grep -i "scan.sh" | grep -v "grep" | wc -l`
if [ $result -lt 1 ]; then
	/usr/lib/scan/scan.sh $1 &
fi