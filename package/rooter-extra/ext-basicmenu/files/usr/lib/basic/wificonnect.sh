#!/bin/sh
. /lib/functions.sh

/usr/lib/basic/disconnect.sh

data=$1"|"

cdata=$(echo "$data" | tr "|" ",")
freq=$(echo $cdata | cut -d, -f1)
ssid=$(echo $cdata | cut -d, -f2)
psk=$(echo $cdata | cut -d, -f3)
pass=$(echo $cdata | cut -d, -f4)

uci set basic.basic.ssid="$ssid"
uci set basic.basic.freq="$freq"
uci set basic.basic.password="$pass"
uci set basic.basic.psk="$psk"
uci set basic.basic.state='1'
uci commit basic

/usr/lib/basic/connect.sh
