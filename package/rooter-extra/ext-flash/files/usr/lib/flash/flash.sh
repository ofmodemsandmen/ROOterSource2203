#!/bin/sh
. /usr/share/libubox/jshn.sh

ROOTER=/usr/lib/rooter

log() {
	modlog "Flash Update : " "$@"
}

flashrouter() {
log "$model"
	json_init
	json_load_file /tmp/updaterouter
	json_select $model
	json_get_var firmware firmware
	if [ "$firmware" = 'yes' ]; then
		json_get_var version version
		json_get_var file file
		log "$version $file"
		json_get_var keepsettings keepsettings
		tst="Firmware/"
		if [ -e /etc/testflash ]; then
			tst="Test/"
		fi
		curl  $server$tst$file > /tmp/$file
		if [ "$CODENAME" != "$version" ]; then
			if [ -s /etc/config/zerotier ]; then
				gr_backup=`grep "^/etc/config/zerotier" /etc/sysupgrade.conf`
				[ -z $gr_backup ] && echo "/etc/config/zerotier" >> /etc/sysupgrade.conf
			fi
			if [ -s /etc/config/bwmon ]; then
				gr_backup=`grep "^/etc/config/bwmon" /etc/sysupgrade.conf`
				[ -z $gr_backup ] && echo "/etc/config/bwmon" >> /etc/sysupgrade.conf
			fi
			if [ -s /usr/lib/bwmon/data/monthly.data ]; then
				gr_backup=`grep "^/usr/lib/bwmon/data/monthly.data" /etc/sysupgrade.conf`
				[ -z $gr_backup ] && echo "/usr/lib/bwmon/data/monthly.data" >> /etc/sysupgrade.conf
			fi
			if [ -s /etc/config/flash ]; then
				gr_backup=`grep "^/etc/config/flash" /etc/sysupgrade.conf`
				[ -z $gr_backup ] && echo "/etc/config/flash" >> /etc/sysupgrade.conf
			fi
			if [ -s /etc/config/system ]; then
				gr_backup=`grep "^/etc/config/system" /etc/sysupgrade.conf`
				[ -z $gr_backup ] && echo "/etc/config/system" >> /etc/sysupgrade.conf
			fi
			if [ "$keepsettings" = 'no' ]; then
				rm -rf /lib/upgrade/keep.d
			fi
			sysupgrade /tmp/$file
			fault_code="$?"
			if [ "$fault_code" != "0" ]; then
				log "Flashing Error"
			else
				log "Flash Good"
			fi
		fi
	fi
}

mod=$(cat /tmp/sysinfo/board_name)
mak=$(cat /tmp/sysinfo/model)
mk=$(echo "$mak" | grep "Inter-Wave")
if [ ! -z "$mk" ]; then
	modmk="-Inter-Wave"
else
	modmk="-4G5Gstore"
fi
w16=$(echo "$mod" | grep "1608")
if [ ! -z "$w16" ]; then
	model="wg1608$modmk"
fi
w16=$(echo "$mod" | grep "oolite-v5.2")
if [ ! -z "$w16" ]; then
	model="we826q$modmk"
fi
w16=$(echo "$mod" | grep "mk01k21")
if [ ! -z "$w16" ]; then
	model="mk01k21$modmk"
fi

mfirm=""
modmodel=$(uci -q get modem.modem1.model)
modmodel=$(echo "$modmodel" | tr '[:upper:]' '[:lower:]')
CPORT=$(uci -q get modem.modem1.commport)
if [ ! -z "$modmodel" ]; then
	ATCMDD="ati"
	OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "1" "$ATCMDD")
	revs=$(echo $OX | grep -m 1 'Revision:')
	if [ ! -z "$revs" ]; then
		revs=$(echo $revs" " | tr " " ",")
		mfirm=$(echo $revs | cut -d, -f5)
	fi
fi

ip=$(uci -q get flash.flash.server)
server="ftp://$ip/files/"
source /etc/codename
curl  $server"updaterouter" > /tmp/updaterouter
if [ $? = '0' ]; then
log "Check for flash"
	json_init
	json_load_file /tmp/updaterouter
	if [ ! -z "$modmodel" -a ! -z "$mfirm" ]; then
		json_select $modmodel
		json_get_var firmware firmware
		if [ "$firmware" = 'yes' ]; then
			json_get_var version version
			json_get_var file file
			log "$version  $mfirm"
			if [ "$version" != "$mfirm" ]; then
				log "$server$file"
			else
				flashrouter
			fi
		else
			flashrouter
		fi
	else
		flashrouter
	fi
	
	
fi