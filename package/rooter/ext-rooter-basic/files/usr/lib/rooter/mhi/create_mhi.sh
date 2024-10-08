#!/bin/sh

ROOTER=/usr/lib/rooter
ROOTER_LINK="/tmp/links"

log() {
	modlog "Create Connection $CURRMODEM" "$@"
}

ifname1="ifname"
if [ -e /etc/newstyle ]; then
	ifname1="device"
fi

set_dns() {
	local pDNS1=$(uci -q get modem.modeminfo$CURRMODEM.dns1)
	local pDNS2=$(uci -q get modem.modeminfo$CURRMODEM.dns2)
	local pDNS3=$(uci -q get modem.modeminfo$CURRMODEM.dns3)
	local pDNS4=$(uci -q get modem.modeminfo$CURRMODEM.dns4)

	local aDNS="$pDNS1 $pDNS2 $pDNS3 $pDNS4"
	local bDNS=""

	echo "$aDNS" | grep -o "[[:graph:]]" &>/dev/null
	if [ $? = 0 ]; then
		log "Using DNS settings from the Connection Profile"
		pdns=1
		for DNSV in $(echo "$aDNS"); do
			if [ "$DNSV" != "0.0.0.0" ] && [ -z "$(echo "$bDNS" | grep -o "$DNSV")" ]; then
				[ -n "$(echo "$DNSV" | grep -o ":")" ] && continue
				bDNS="$bDNS $DNSV"
			fi
		done

		bDNS=$(echo $bDNS)
		if [ $DHCP = 1 ]; then
			uci set network.wan$INTER.peerdns=0
			uci set network.wan$INTER.dns="$bDNS"
		fi
		echo "$bDNS" > /tmp/v4dns$INTER

		bDNS=""
		for DNSV in $(echo "$aDNS"); do
			if [ "$DNSV" != "0:0:0:0:0:0:0:0" ] && [ -z "$(echo "$bDNS" | grep -o "$DNSV")" ]; then
				[ -z "$(echo "$DNSV" | grep -o ":")" ] && continue
				bDNS="$bDNS $DNSV"
			fi
		done
		echo "$bDNS" > /tmp/v6dns$INTER
	else
		log "Using Provider assigned DNS"
		pdns=0
		rm -f /tmp/v[46]dns$INTER
	fi
}

save_variables() {
	echo 'MODSTART="'"$MODSTART"'"' > /tmp/variable.file
	echo 'WWAN="'"$WWAN"'"' >> /tmp/variable.file
	echo 'USBN="'"$USBN"'"' >> /tmp/variable.file
	echo 'ETHN="'"$ETHN"'"' >> /tmp/variable.file
	echo 'WDMN="'"$WDMN"'"' >> /tmp/variable.file
	echo 'BASEPORT="'"$BASEPORT"'"' >> /tmp/variable.file
}

get_connect() {
	NAPN=$(uci get modem.modeminfo$CURRMODEM.apn)
	NUSER=$(uci get modem.modeminfo$CURRMODEM.user)
	NPASS=$(uci get modem.modeminfo$CURRMODEM.passw)
	NAUTH=$(uci get modem.modeminfo$CURRMODEM.auth)
	PINC=$(uci get modem.modeminfo$CURRMODEM.pincode)

	uci set modem.modem$CURRMODEM.apn=$NAPN
	uci set modem.modem$CURRMODEM.user=$NUSER
	uci set modem.modem$CURRMODEM.pass=$NPASS
	uci set modem.modem$CURRMODEM.auth=$NAUTH
	uci set modem.modem$CURRMODEM.pin=$PINC
	uci commit modem
}

CURRMODEM=$1
source /tmp/variable.file

MAN=$(uci get modem.modem$CURRMODEM.manuf)
MOD=$(uci get modem.modem$CURRMODEM.model)
BASEP=$(uci get modem.modem$CURRMODEM.baseport)
$ROOTER/signal/status.sh $CURRMODEM "$MAN $MOD" "Connecting"
PROT=$(uci get modem.modem$CURRMODEM.proto)

DELAY=$(uci get modem.modem$CURRMODEM.delay)
if [ -z $DELAY ]; then
	DELAY=5
fi

idV=$(uci get modem.modem$CURRMODEM.idV)
idP=$(uci get modem.modem$CURRMODEM.idP)

DP=3
CP=2

$ROOTER/common/modemchk.lua "$idV" "$idP" "$DP" "$CP"
source /tmp/parmpass

CPORT=`expr $CPORT + $BASEP`
DPORT=`expr $DPORT + $BASEP`
uci set modem.modem$CURRMODEM.commport=$CPORT
uci set modem.modem$CURRMODEM.dataport=$DPORT
uci set modem.modem$CURRMODEM.service=$retval
uci commit modem

if [ -e $ROOTER/modem-led.sh ]; then
	$ROOTER/modem-led.sh $CURRMODEM 2
fi

log "MHI Comm Port : /dev/ttyUSB$CPORT"

if [ -z "$idV" ]; then
	idV=$(uci -q get modem.modem$CURRMODEM.idV)
fi
QUECTEL=false
if [ "$idV" = "2c7c" ]; then
	QUECTEL=true
elif [ "$idV" = "05c6" ]; then
	QUELST="9090,9003,9215"
	if [[ $(echo "$QUELST" | grep -o "$idP") ]]; then
		QUECTEL=true
	fi
fi

if [ -e $ROOTER/connect/preconnect.sh ]; then
	if [ "$RECON" != "2" ]; then
		$ROOTER/connect/preconnect.sh $CURRMODEM
	fi
fi

if $QUECTEL; then
	if [ "$RECON" != "2" ]; then
		ATCMDD="AT+CNMI?"
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		if `echo $OX | grep -o "+CNMI: [0-3],2," >/dev/null 2>&1`; then
			ATCMDD="AT+CNMI=0,0,0,0,0"
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		fi
		ATCMDD="AT+QINDCFG=\"smsincoming\""
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		if `echo $OX | grep -o ",1" >/dev/null 2>&1`; then
			ATCMDD="AT+QINDCFG=\"smsincoming\",0,1"
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		fi
		ATCMDD="AT+QINDCFG=\"all\""
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		if `echo $OX | grep -o ",1" >/dev/null 2>&1`; then
			ATCMDD="AT+QINDCFG=\"all\",0,1"
			OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		fi
		log "Quectel Unsolicited Responses Disabled"
	fi
	$ROOTER/connect/bandmask $CURRMODEM 1
	clck=$(uci -q get custom.bandlock.cenable$CURRMODEM)
	if [ $clck = "1" ]; then
		ear=$(uci -q get custom.bandlock.earfcn$CURRMODEM)
		pc=$(uci -q get custom.bandlock.pci$CURRMODEM)
		ear1=$(uci -q get custom.bandlock.earfcn1$CURRMODEM)
		pc1=$(uci -q get custom.bandlock.pci1$CURRMODEM)
		ear2=$(uci -q get custom.bandlock.earfcn2$CURRMODEM)
		pc2=$(uci -q get custom.bandlock.pci2$CURRMODEM)
		ear3=$(uci -q get custom.bandlock.earfcn3$CURRMODEM)
		pc3=$(uci -q get custom.bandlock.pci3$CURRMODEM)
		cnt=1
		earcnt=$ear","$pc
		if [ $ear1 != "0" -a $pc1 != "0" ]; then
			earcnt=$earcnt","$ear1","$pc1
			let cnt=cnt+1
		fi
		if [ $ear2 != "0" -a $pc2 != "0" ]; then
			earcnt=$earcnt","$ear2","$pc2
			let cnt=cnt+1
		fi
		if [ $ear3 != "0" -a $pc3 != "0" ]; then
			earcnt=$earcnt","$ear3","$pc3
			let cnt=cnt+1
		fi
		earcnt=$cnt","$earcnt
		ATCMDD="at+qnwlock=\"common/4g\""
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		log "$OX"
		if `echo $OX | grep "ERROR" 1>/dev/null 2>&1`
		then
			ATCMDD="at+qnwlock=\"common/lte\",2,$ear,$pc"
		else
			ATCMDD=$ATCMDD","$earcnt
		fi
		OX=$($ROOTER/gcom/gcom-locked "/dev/ttyUSB$CPORT" "run-at.gcom" "$CURRMODEM" "$ATCMDD")
		log "Cell Lock $OX"
		sleep 10
	fi
fi


$ROOTER/common/gettype.sh $CURRMODEM
$ROOTER/connect/get_profile.sh $CURRMODEM
get_connect
if [ -e $ROOTER/simlock.sh ]; then
	$ROOTER/simlock.sh $CURRMODEM
fi

if [ -e /tmp/simpin$CURRMODEM ]; then
	log " SIM Error"
	if [ -e $ROOTER/simerr.sh ]; then
		$ROOTER/simerr.sh $CURRMODEM
	fi
	exit 0
fi

if [ -e /usr/lib/gps/gps.sh ]; then
	/usr/lib/gps/gps.sh $CURRMODEM &
fi

INTER=$(uci get modem.modeminfo$CURRMODEM.inter)
if [ -z $INTER ]; then
	INTER=$CURRMODEM
else
	if [ $INTER = 0 ]; then
		INTER=$CURRMODEM
	fi
fi
log "Profile for Modem $CURRMODEM sets interface to WAN$INTER"
OTHER=1
if [ $CURRMODEM = 1 ]; then
	OTHER=2
fi
EMPTY=$(uci get modem.modem$OTHER.empty)
if [ $EMPTY = 0 ]; then
	OINTER=$(uci get modem.modem$OTHER.inter)
	if [ ! -z $OINTER ]; then
		if [ $INTER = $OINTER ]; then
			INTER=1
			if [ $OINTER = 1 ]; then
				INTER=2
			fi
			log "Switched Modem $CURRMODEM to WAN$INTER as Modem $OTHER is using WAN$OINTER"
		fi
	fi
fi


uci set modem.modem$CURRMODEM.inter=$INTER
uci commit modem
log "Modem $CURRMODEM is using WAN$INTER"

log "Connect via MHI"
if [ -e $ROOTER/modem-led.sh ]; then
	$ROOTER/modem-led.sh $CURRMODEM 2
fi

DEVICE="/dev/wwan0mbim0"
IFNAME="mhi_hwip0"
APN=$NAPN

#
# stop network
# setup data format
# set IP family
#
STOPNET=`qmicli -p -d $DEVICE --wds-stop-network=disable-autoconnect 2>/dev/null`
AUTODIS=`qmicli -p -d $DEVICE --wds-set-autoconnect-settings=disabled 2>/dev/null`
DEVICE_DATA_FORMAT_CMD="qmicli -p -d $DEVICE --wda-get-data-format"
DEVICE_DATA_FORMAT_OUT=`$DEVICE_DATA_FORMAT_CMD`
DEVICE_LLP=`echo "$DEVICE_DATA_FORMAT_OUT" | sed -n "s/.*Link layer protocol:.*'\(.*\)'.*/\1/p"`
SETFORM=`qmicli -p -d $DEVICE --wda-set-data-format="raw-ip" 2>/dev/null`

 
#
# start network
# check for failure
#
START_NETWORK_ARGS="apn='$APN'"
START_NETWORK_OUT=`qmicli -p -d $DEVICE --wds-start-network=$START_NETWORK_ARGS --client-no-release-cid 2>/dev/null`
CID=`echo "$START_NETWORK_OUT" | sed -n "s/.*CID.*'\(.*\)'.*/\1/p"`
if [ -z "$CID" ]; then
	log "error: network start failed, client not allocated"
	exit 0
fi
PDH=`echo "$START_NETWORK_OUT" | sed -n "s/.*handle.*'\(.*\)'.*/\1/p"`
if [ -z "$PDH" ]; then
    log "error: network start failed, no packet data handle"
	exit 0
fi

SIGNAL=`qmicli -p -d $DEVICE --nas-get-signal-info 2>/dev/null`
if [ -z "$SIGNAL" ]; then
    log "error: no cell connection"
	exit 0
fi
sstat=`qmicli -p -d $DEVICE --wds-get-packet-service-status`
ssc=$(echo "$sstat" | grep "connected")
if [ -z "$ssc" ]; then
    log "error: network not connected"
	exit 0
fi
log "Network Connected"
START_NETWORK_ARGS="apn='$APN',ip-type=4"
START_NETWORK_OUT=`qmicli -p -d $DEVICE--wds-start-network=$START_NETWORK_ARGS --client-no-release-cid 2>/dev/null`
SET=`qmicli -p -d $DEVICE --wds-get-current-settings`

qmicli -p -d $DEVICE --wds-get-current-settings > /tmp/mhisettings
while IFS= read -r line; do
	ipf=$(echo "$line" | grep "IP Family:")
	if [ ! -z "$ipf" ]; then
		ipfam=$(echo "$ipf" | xargs | tr " " "," | cut -d, -f3)
		vs=$(echo "$ipfam" | grep "6")
		if [ ! -z "$vs" ]; then
			vs=6
		else
			vs=4
		fi
	fi
	ipaddr=$(echo "$line" | grep "$ipfam address:")
	if [ ! -z "$ipaddr" ]; then
		ipaddrf=$(echo "$ipaddr" | xargs | tr " " "," | cut -d, -f3)
	fi
	gateway=$(echo "$line" | grep "gateway address:")
	if [ ! -z "$gateway" ]; then
		gatewayf=$(echo "$gateway" | xargs | tr " " "," | cut -d, -f4 | tr "/" "," | cut -d, -f1)
	fi
	dns1=$(echo "$line" | grep "primary DNS:")
	if [ ! -z "$dns1" ]; then
		dns1f=$(echo "$dns1" | xargs | tr " " "," | cut -d, -f4)
	fi
	dns2=$(echo "$line" | grep "secondary DNS:")
	if [ ! -z "$dns2" ]; then
		dns2f=$(echo "$dns2" | xargs | tr " " "," | cut -d, -f4)
	fi
done < /tmp/mhisettings

log "IP Addr : $ipaddrf"
log "Gateway : $gatewayf"
log "DNS : $dns1f $dns2f"

INTER=1
log "Applying IP settings to wan$INTER"

if [ "$vs" = "6" ]; then
	log "Add 464xlat interface"
	uci delete network.xlatd$INTER
	uci set network.xlatd$INTER=interface
	uci set network.xlatd$INTER.proto='464xlat'
	uci set network.xlatd$INTER.tunlink='wan'$INTER
	uci set network.xlatd$INTER.ip6prefix='64:ff9b::/96'
	uci set network.xlatd$INTER.dns='1.1.1.1'
	uci set network.xlatd$INTER.metric=$INTER"0"
	uci set network.xlatd$INTER.ip4table='default'
	uci set network.xlatd$INTER.ip6table='default'
	ifup xlatd$INTER
fi
 
uci delete network.wan$INTER
uci set network.wan$INTER=interface
uci set network.wan$INTER.proto=static
uci set network.wan$INTER.device="$IFNAME"
uci set network.wan$INTER.metric=$INTER"0"
uci add_list network.wan$INTER.dns="$dns1f"
if [ ! -z "$dns2f" ]; then
	uci add_list network.wan$INTER.dns="$dns2f"
fi
if [ "$vs" = "6" ]; then
	uci set network.wan$INTER.ip6gw="$gatewayf"
	uci set network.wan$INTER.ip6addr="$ipaddrf"
else
	uci set network.wan$INTER.ipaddr="$ipaddrf"
	uci set network.wan$INTER.gateway="$gatewayf"
fi
uci commit network
ip link set dev $IFNAME arp off
ifup wan$INTER


ln -fs $ROOTER/signal/modemsignal.sh $ROOTER_LINK/getsignal$CURRMODEM
$ROOTER_LINK/getsignal$CURRMODEM $CURRMODEM $PROT &
rm -f /tmp/usbwait
log "Modem Connected"
if [ -e $ROOTER/modem-led.sh ]; then
	$ROOTER/modem-led.sh $CURRMODEM 3
fi
