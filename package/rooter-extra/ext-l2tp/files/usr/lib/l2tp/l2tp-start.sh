#!/bin/sh
. /lib/functions.sh

log() {
	logger -t "Start L2TP" "$@"
}

sleep 3

url=$(uci -q get l2tp.l2tp.url)
secret=$(uci -q get l2tp.l2tp.secret)
username=$(uci -q get l2tp.l2tp.username)
password=$(uci -q get l2tp.l2tp.password)

if [ -z $url ]; then
	exit 0
fi
if [ -z $username ]; then
	exit 0
fi
if [ -z $password ]; then
	exit 0
fi

l2tp=$(uci -q get network.L2TPVPN)
if [ -z $l2tp ]; then
	uci set network.L2TPVPN='interface'
	uci set network.L2TPVPN.proto='l2tp'
	uci set network.L2TPVPN.ipv6='auto'
	uci set network.L2TPVPN.defaultroute='0'
	uci set network.L2TPVPN.delegate='0'
	uci set network.L2TPVPN.server=$url
	uci set network.L2TPVPN.username=$username
	uci set network.L2TPVPN.password=$password
	uci commit network
	
	uci set firewall.l2tpzone='zone'
	uci set firewall.l2tpzone.name='L2TP'
	uci set firewall.l2tpzone.input='ACCEPT'
	uci set firewall.l2tpzone.output='ACCEPT'
	uci set firewall.l2tpzone.forward='REJECT'
	uci set firewall.l2tpzone.masq='1'
	uci add_list firewall.l2tpzone.network='L2TPVPN'
	
	uci set firewall.l2tpfwd='forwarding'
	uci set firewall.l2tpfwd.src='lan'
	uci set firewall.l2tpfwd.dest='L2TP'
	uci commit firewall
	
	/etc/init.d/network restart
	/etc/init.d/firewall restart
fi

STEMP="/tmp/stemp.l2tp"
STATUS="/usr/lib/l2tp/xl2tpd.conf"
SPSTATUS="/etc/xl2tpd/xl2tpd.conf"
rm -f $STEMP
cp $STATUS $STEMP
sed -i -e "s!##URL##!$url!g" $STEMP
mv $STEMP $SPSTATUS

STEMP="/tmp/stemp.l2tp"
STATUS="/usr/lib/l2tp/xl2tp-secrets"
SPSTATUS="/etc/xl2tpd/xl2tp-secrets"
rm -f $STEMP
cp $STATUS $STEMP
sed -i -e "s!##SECRET##!$secret!g" $STEMP
mv $STEMP $SPSTATUS

STEMP="/tmp/stemp.l2tp"
STATUS="/usr/lib/l2tp/myvpn.xl2tpd"
SPSTATUS="/etc/ppp/peers/myvpn.xl2tpd"
rm -f $STEMP
cp $STATUS $STEMP
sed -i -e "s!##USER##!$username!g" $STEMP
sed -i -e "s!##PASS##!$password!g" $STEMP
mv $STEMP $SPSTATUS

/etc/init.d/xl2tpd restart
echo "c myvpn" > /var/run/xl2tpd/l2tp-control
