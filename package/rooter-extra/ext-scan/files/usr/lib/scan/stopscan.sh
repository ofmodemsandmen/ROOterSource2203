#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Scan Stop" "$@"
}

result=`ps | grep -i "scan.sh" | grep -v "grep" | wc -l`
if [ $result -gt 0 ]; then
	log " "
	log "Stopping Scan"
	log " "
	uci set bandscan.info.stopping="1"
	uci commit bandscan
	PID=$(ps |grep "scan.sh" | grep -v grep |head -n 1 | awk '{print $1}')
	kill -9 $PID
	if [ -e /tmp/scandata ]; then
		while IFS= read -r line; do
			retmask=$line
			read -r line
			retmask5g=$line
			read -r line
			sched=$line
			read -r line
			pingtest=$line
			read -r line
			netspeed=$line
			break
		done < /tmp/scandata
		CPORT=$(uci get modem.modem1.commport)
		while [ -z "$CPORT" ]
		do
			sleep 20
			CPORT=$(uci get modem.modem1.commport)
		done
		/usr/lib/rooter/luci/lock.sh "$retmask,$retmask5g" 1
		sleep 180
		conn=$(uci -q get modem.modem1.connected)
		if [ $conn != "1" ]; then
			sleep 120
		fi
		uci set shedule.reboot.enable=$sched
		uci commit schedule
		uci set ping.ping.enable=$pingtest
		uci commit ping
		netspeed="0"
		if [ $netspeed = "1" ]; then
			echo "0" > /etc/netspeed
		fi
	fi
	rm -f /etc/scantest
	rm -f /tmp/sclist
	rm -f /etc/sclist
	rm -f /tmp/scandata
	uci set bandscan.info.running="0"
	uci set bandscan.info.stopping="0"
	uci commit bandscan
fi