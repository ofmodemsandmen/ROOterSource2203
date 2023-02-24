#!/bin/sh
ROOTER=/usr/lib/rooter

. /lib/functions/network.sh
. /usr/share/libubox/jshn.sh
. /lib/functions.sh

trm_fetch="$(command -v curl)"
trm_captiveurl="http://detectportal.firefox.com"
trm_useragent="Mozilla/5.0 (Linux x86_64; rv:90.0) Gecko/20100101 Firefox/90.0"
trm_maxwait="30"

f_getgw() {
	local result wan4_if wan4_gw wan6_if wan6_gw

	network_flush_cache
	network_find_wan wan4_if
	network_find_wan6 wan6_if
	network_get_gateway wan4_gw "${wan4_if}"
	network_get_gateway6 wan6_gw "${wan6_if}"
	if [ -n "${wan4_gw}" ] || [ -n "${wan6_gw}" ]; then
		result="${wan4_gw} ${wan6_gw}"
	fi
	printf "%s" "${result}"
}

f_net() {
	local err_msg raw html_raw html_cp json_raw json_ec json_rc json_cp json_ed result="net nok"

	raw="$(${trm_fetch} --user-agent "${trm_useragent}" --referer "http://www.example.com" --header "Cache-Control: no-cache, no-store, must-revalidate, max-age=0" --write-out "%{json}" --silent --max-time $((trm_maxwait / 6)) "${trm_captiveurl}")"
	json_raw="${raw#*\{}"
	html_raw="${raw%%\{*}"
	if [ -n "${json_raw}" ]; then
		json_ec="$(printf "%s" "{${json_raw}" | jsonfilter -q -l1 -e '@.exitcode')"
		json_rc="$(printf "%s" "{${json_raw}" | jsonfilter -q -l1 -e '@.response_code')"
		json_cp="$(printf "%s" "{${json_raw}" | jsonfilter -q -l1 -e '@.redirect_url' | awk 'BEGIN{FS="/"}{printf "%s",tolower($3)}')"
		echo "json_ec $json_ec json_rc $json_rc json_cp $json_cp"
		if [ "${json_ec}" = "0" ]; then
			if [ -n "${json_cp}" ]; then
				result="net cp '${json_cp}'"
			else
				if [ "${json_rc}" = "200" ] || [ "${json_rc}" = "204" ]; then
					html_cp="$(printf "%s" "${html_raw}" | awk 'match(tolower($0),/^.*<meta[ \t]+http-equiv=["]*refresh.*[ \t;]url=/){print substr(tolower($0),RLENGTH+1)}' | awk 'BEGIN{FS="[:/]"}{printf "%s",$4;exit}')"
					if [ -n "${html_cp}" ]; then
						result="net cp '${html_cp}'"
					else
						result="net ok"
					fi
				fi
			fi
		else
			err_msg="$(printf "%s" "{${json_raw}" | jsonfilter -q -l1 -e '@.errormsg')"
			json_ed="$(printf "%s" "{${err_msg}" | awk '/([[:alnum:]_-]{1,63}\.)+[[:alpha:]]+$/{printf "%s",tolower($NF)}')"
			if [ "${json_ec}" = "6" ]; then
				if [ -n "${json_ed}" ] && [ "${json_ed}" != "${trm_captiveurl#http*://*}" ]; then
					result="net cp '${json_ed}'"
				fi
			elif [ "${json_ec}" = "28" ]; then
				if [ -n "$(f_getgw)" ]; then
					result="net ok"
				fi
			fi
		fi
	fi
	printf "%s" "${result}"
}

# f_check()

dev_status="$(ubus -S call network.wireless status 2>/dev/null)"
ifname="$(printf "%s" "${dev_status}" | jsonfilter -q -l1 -e '@.*.interfaces[@.config.mode="sta"].ifname')"
trm_ifstatus="$(ubus -S call network.interface dump 2>/dev/null | jsonfilter -q -l1 -e "@.interface[@.device=\"${ifname}\"].up")"
if [ "${trm_ifstatus}" = "true" ]; then
	result="$(f_net)"
	cp_domain="$(printf "%s" "${result}" | awk -F '['\''| ]' '/^net cp/{printf "%s",$4}')"
fi
echo "$result"
echo "$cp_domain"
if [ -x "/etc/init.d/dnsmasq" ] && [ -f "/etc/config/dhcp" ] &&
	[ -n "${cp_domain}" ] && ! uci_get "dhcp" "@dnsmasq[0]" "rebind_domain" | grep -q "${cp_domain}"; then
		uci_add_list "dhcp" "@dnsmasq[0]" "rebind_domain" "${cp_domain}"
		uci_commit "dhcp"
		/etc/init.d/dnsmasq reload
		echo "Add to Whitelist"
fi
/usr/lib/hotspot/generic-login.sh "admin" "admin" "$cp_domain"
exit 0
