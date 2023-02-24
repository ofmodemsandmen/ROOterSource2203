#!/bin/sh

if [ -f "/etc/hot" ]; then
	rm -f /etc/hotspot
	while IFS='|' read -r ssid encrypt key flag
	do
		echo $ssid"|"$encrypt"|"$key >> /etc/hotspot
	done <"/etc/hot"
fi
