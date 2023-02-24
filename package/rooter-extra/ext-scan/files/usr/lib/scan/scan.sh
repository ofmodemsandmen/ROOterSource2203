#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Scan Test" "$@"
}

fixspeed() {
	sed 's/\(PROVIDER=[[:blank:]]*\)\(.*\)/\1'\''\2'\''/' /tmp/speed > /tmp/tspeed
}

geticcid() {
	local config=$1
	local iccid
	config_get iccid $1 iccid
	case $ICCID in
	"$iccid"*)
		config_get used $1 used
		config_get single $1 single
		config_get name $1 name
		isplist="$used"
		singlelist="$single"
		;;
	esac
}

readstatus() {
	while IFS= read -r line; do
		port="$line"
		read -r line
		csq="$line"
		read -r line
		per="$line"
		read -r line
		rssi="$line"
		read -r line
		modem="$line"
		read -r line
		cops="$line"
		read -r line
		mode="$line"
		read -r line
		lac="$line"
		read -r line
		lacn="$line"
		read -r line
		cid="$line"

		read -r line
		cidn="$line"
		read -r line
		mcc="$line"
		read -r line
		mnc="$line"
		read -r line
		rnc="$line"
		read -r line
		rncn="$line"
		read -r line
		down="$line"
		read -r line
		up="$line"
		read -r line
		ecio="$line"
		read -r line
		rscp="$line"
		read -r line
		ecio1="$line"

		read -r line
		rscp1="$line"
		read -r line
		netmode="$line"
		read -r line
		cell="$line"
		read -r line
		modtype="$line"
		read -r line
		conntype="$line"
		read -r line
		channel="$line"
		read -r line
		phone="$line"
		read -r line
		read -r line
		lband="$line"
		read -r line
		tempur="$line"

		read -r line
		proto="$line"
		read -r line
		pci="$line"
		read -r line
		sinr="$line"
		break
	done < /tmp/status$CURRMODEM.file
}

getsignal() {
	cops="-"
	while [ $cops = "-" ]
	do
		readstatus
		sleep 10
	done
	sleep 20
	lband=$(echo "$lband" | tr "(" ',' | tr ")" ',')
	lband=$(echo "$lband" | cut -d, -f2)
	echo "$lband" > /tmp/lband
	sed -i 's/Bandwidth //' /tmp/lband
	lband=$(cat /tmp/lband)
	rm -f /tmp/lband
	rnc=$(echo "$rnc" | tr "(" ',' | tr ")" ',')
	rnc=$(echo "$rnc" | cut -d, -f2)
	echo "     CSQ : $csq    Signal Strength : $per" >> /etc/scantest
	echo "     RSSI : $rssi    RSRQ : $ecio dB    SINR : $sinr" >> /etc/scantest
	echo "     Tower ID : $rnc    Bandwidth : $lband" >> /etc/scantest
	
	echo "$csq" >> /tmp/sclist
	echo "$per" >> /tmp/sclist
	echo "$rssi" >> /tmp/sclist
	echo "$ecio" >> /tmp/sclist
	echo "$sinr" >> /tmp/sclist
	echo "$rnc" >> /tmp/sclist
	echo "$lband" >> /tmp/sclist
}

testspeed() {
	speedtest --output text > /tmp/speed
	if [ -e /tmp/speed ]; then
		source /tmp/speed
		fixspeed
		if [ -e /tmp/tspeed ]; then
			source /tmp/tspeed
		fi
	fi
	echo "     Download Speed : $DOWNLOAD_SPEED Mbps" >> /etc/scantest
	echo "     Upload Speed : $UPLOAD_SPEED Mbps" >> /etc/scantest
	
	echo "$DOWNLOAD_SPEED" >> /tmp/sclist
	echo "$UPLOAD_SPEED" >> /tmp/sclist
}
	
manual=$1
CURRMODEM=1
isplist=""
singlelist=""
bitmask='00000000000000000000000000000000000000000000000000000000000000000000000'
conn=$(uci -q get modem.modem$CURRMODEM.connected)
if [ "$conn" = "1" ]; then
	L1=$(uci -q get modem.modem$CURRMODEM.L1)
	if [ ! -z "$L1" ]; then
		uci set bandscan.info.running="1"
		uci commit bandscan
		ICCID=$(uci -q get modem.modem$CURRMODEM.iccid)
		config_load bandscan
		config_foreach geticcid isp
		if [ ! -z "$isplist" ]; then
			rm -f /etc/scantest
			rm -f /etc/sclist
			isplist=$isplist
			enb=$(uci -q get custom.bandlock.enabled)
			if [ ! -e /tmp/bmask ]; then
				uci set custom.bandlock.enabled=1
				uci commit custom
				/usr/lib/rooter/luci/mask.sh
				uci set custom.bandlock.enabled=$enb
				uci commit custom
			fi
			sched=$(uci -q get shedule.reboot.enable)
			if [ -z "$sched" ]; then
				sched="0"
			fi
			uci set shedule.reboot.enable="0"
			uci commit schedule
			pingtest=$(uci -q get ping.ping.enable)
			uci set ping.ping.enable="0"
			uci commit ping
			netspeed="0"
			if [ -e /etc/netspeed ]; then
				rm -f /etc/netspeed
				netspeed="1"
			fi
			
			while IFS= read -r line; do
				#bmask=${line:0:72}
				read -r line
				read -r line
				bmask=${line:0:72}
				retmask=$line
				read -r line
				retmask5g=$line
				break
			done < /tmp/bmask

			echo "$retmask" > /tmp/scandata
			echo "$retmask5g" >> /tmp/scandata
			echo "$sched" >> /tmp/scandata
			echo "$pingtest" >> /tmp/scandata
			echo "$netspeed" >> /tmp/scandata
			band=0
			wlist=""
			while [ true ]
			do
				bit=${bmask:$band:1}
				let band=band+1
				if [ -z "$bit" ]; then
					break
				fi
				if [ "$bit" = "1" ]; then
					for is in $isplist
					do
						if [ "$is" = "$band" ]; then
							wlist="$wlist"$band" "
						fi
					done
				fi
			done
			single=$(echo "$singlelist" | tr " " ",")",OK,"
			mlist=$(echo "$wlist" | tr " " ",")",OK,"
			scntr=1
			truelist=""
			while [ true ]
			do
				bnd=$(echo "$mlist" | cut -d, -f"$scntr")
				if [ "$bnd" = "OK" -o -z "$bnd" ]; then
					break
				fi
				mcntr=1
				while [ true ]
				do
					mbnd=$(echo "$single" | cut -d, -f"$mcntr")
					if [ "$mbnd" = "OK" -o -z "$mbnd" ]; then
						break
					fi
					if [ "$bnd" = "$mbnd" ]; then
						truelist="$truelist"$bnd" "
						break
					fi
					let mcntr=mcntr+1
				done
				let scntr=scntr+1
			done
			mac=$(ip link show br-lan | awk -e '/^\s*link\//{print $2}')
			imei=$(uci -q get modem.modem$CURRMODEM.imei)
			echo "Modem IMEI : $imei" > /etc/scantest
			ID=$(uci -q get zerotier.zerotier.secret)
			if [ -z $ID ]; then
				ID="xxxxxxxxxx"
			else
				ID=${ID:0:10}
			fi
			echo "Router ID : $ID" >> /etc/scantest
			echo "ISP : $name" >> /etc/scantest
			currentDate=`date`
			echo " Start Time - $currentDate" >> /etc/scantest
			
			echo "$imei" > /tmp/sclist
			echo "$ID" >> /tmp/sclist
			echo "$name" >> /tmp/sclist
			echo "$currentDate" >> /tmp/sclist
			
			echo " " >> /etc/scantest
			for is in $truelist
			do
				let pos=is
				echo "  Band B$pos" >> /etc/scantest
				
				echo "$pos" >> /tmp/sclist
				
				mask=$(echo "$bitmask" | sed -e "s/\<\+/1/$pos")
				/usr/lib/rooter/luci/lock.sh "$mask" 1
				sleep 300
				conn=$(uci -q get modem.modem$CURRMODEM.connected)
				if [ $conn != "1" ]; then
					sleep 180
				fi
				conn=$(uci -q get modem.modem$CURRMODEM.connected)
				if [ $conn = "1" ]; then
					getsignal
					testspeed
				else
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "Not Connected" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "-" >> /tmp/sclist
					echo "     Not Connected" >> /etc/scantest
				fi
				#break # single band test
			done
			currentDate=`date`
			echo " " >> /etc/scantest
			echo " End Time - $currentDate" >> /etc/scantest
			
			echo "$currentDate" >> /tmp/sclist
			mv /tmp/sclist /etc/sclist
			
			/usr/lib/rooter/luci/lock.sh "$retmask,$retmask5g" 1
			sleep 300
			conn=$(uci -q get modem.modem$CURRMODEM.connected)
			if [ $conn != "1" ]; then
				sleep 180
			fi
			repeat=$(uci -q get bandscan.info.repeat)
			if [ "$repeat" = "1" ]; then
				if [ -z "$manual" ]; then
					uci set bandscan.info.enabled='0'
					uci commit bandscan
				fi
			fi
			smtp=$(uci -q get custom.texting.smtp)
			if [ ! -z "$smtp" ]; then
				/usr/lib/scan/email.sh &
			fi

			uci set shedule.reboot.enable=$sched
			uci commit schedule
			uci set ping.ping.enable=$pingtest
			uci commit ping
			netspeed="0"
			if [ $netspeed = "1" ]; then
				echo "0" > /etc/netspeed
			fi
			uci set bandscan.info.running="0"
			uci commit bandscan
		fi
	fi
fi
exit 0
