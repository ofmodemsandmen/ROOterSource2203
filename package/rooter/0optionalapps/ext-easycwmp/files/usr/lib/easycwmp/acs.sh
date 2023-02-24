#!/bin/sh
. /lib/functions.sh

sleep 5

aip=$(uci -q get acs.acs.ip)
username=$(uci -q get acs.acs.username)
password=$(uci -q get acs.acs.password)
enable=$(uci -q get acs.acs.enable)

#server=""$aip":"$port
uci set easycwmp.@acs[0].url=$aip
uci set easycwmp.@acs[0].username=$username
uci set easycwmp.@acs[0].password=$password
uci set easycwmp.@local[0].enable=$enable
uci commit easycwmp
/etc/init.d/easycwmpd restart