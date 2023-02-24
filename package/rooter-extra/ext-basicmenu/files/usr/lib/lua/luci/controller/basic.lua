
module("luci.controller.basic", package.seeall)

I18N = require "luci.i18n"
translate = I18N.translate

function index()
	entry({"admin", "basic"}, firstchild(), translate("Menu Selection"), 1).dependent=false
	entry( {"admin", "basic", "basic"}, template("basic/basic"), _(translate("Easy Basic Menu")), 1 )
	
	entry({"admin", "basic", "getslide"}, call("action_getslide"))
	entry({"admin", "basic", "setmodem"}, call("action_setmodem"))
	entry({"admin", "basic", "setwifi"}, call("action_setwifi"))
	entry({"admin", "basic", "getmodem"}, call("action_getmodem"))
	entry({"admin", "basic", "getlist"}, call("action_getlist"))
	entry({"admin", "basic", "connect"}, call("action_connect"))
	entry({"admin", "basic", "setreconn"}, call("action_setreconn"))
	entry({"admin", "basic", "setkey"}, call("action_setkey"))
end

function file_exists(name)
	local f=io.open(name,"r")
	if f~=nil then io.close(f) return true else return false end
end

function getmodel()
	if file_exists("/etc/custom") then
		file = io.open("/etc/custom", "r")
		board = file:read("*line")
		model = file:read("*line")
		hostname = file:read("*line")
		file:close()
	else
		board = "Unknown"
		model = "Unknown"
	end
	return model
end

function action_getslide()
	local rv = {}
	
	rv['modem'] = luci.model.uci.cursor():get("basic", "basic", "modem")
	rv['wifi'] = luci.model.uci.cursor():get("basic", "basic", "wifi")
	rv['ssid'] = luci.model.uci.cursor():get("basic", "basic", "ssid")
	rv['state'] = luci.model.uci.cursor():get("basic", "basic", "state")
	rv['password'] = luci.model.uci.cursor():get("basic", "basic", "password")
	rv['freq'] = luci.model.uci.cursor():get("basic", "basic", "freq")
	rv['reconn'] = luci.model.uci.cursor():get("basic", "basic", "reconn")
	rv['hotspot'] = luci.model.uci.cursor():get("travelmate", "global", "state")
	if rv['hotspot'] == "" then
		rv['hotspot'] = "0"
	end
	os.execute("uci set basic.basic.modemh=0; uci commit basic")

	rv['model'] = getmodel()
	rv['time'] = os.date("%H:%M%p %A, %d %B %Y")
	
	os.execute("source /etc/codename; echo $CODENAME > /tmp/codename")
	file = io.open("/tmp/codename", "r")
	rv['firm'] = file:read("*line")
	file:close()
	
	rv['ip'] = luci.model.uci.cursor():get("network", "lan", "ipaddr")
	
	getmac = "mac1=$(/sbin/ifconfig | grep 'HWaddr' | tr -s ' ' | tr \" \" \",\");mac=$(echo $mac1 | cut -d, -f5);echo $mac > /tmp/mac"
	os.execute(getmac)
	file = io.open("/tmp/mac", "r")
	rv['mac'] = file:read("*line")
	file:close()
	
	os.execute("/usr/lib/basic/getwifi.sh")
	file = io.open("/tmp/bwireless", "r")
	rv['disable2'] = file:read("*line")
	rv['ssid2'] = file:read("*line")
	rv['channel2'] = file:read("*line")
	rv['disable5'] = file:read("*line")
	rv['ssid5'] = file:read("*line")
	rv['channel5'] = file:read("*line")
	file:close()
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setmodem()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/basic/setmodem.sh \"" .. set .. "\"")
end

function action_connect()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/basic/wificonnect.sh \"" .. set .. "\"")
end

function action_setwifi()
	local set = luci.http.formvalue("set")
	os.execute("uci set basic.basic.wifi=" .. set .. "; uci commit basic")
	if set == "0" then
		os.execute("/usr/lib/basic/disconnect.sh")
	else
		os.execute("/usr/lib/basic/connect.sh")
	end
end

function action_getmodem()
	local rv = {}
	
	rv['time'] = os.date("%H:%M%p %A, %d %B %Y")
	rv['ssid'] = luci.model.uci.cursor():get("basic", "basic", "ssid")
	rv['state'] = luci.model.uci.cursor():get("basic", "basic", "state")
	rv['password'] = luci.model.uci.cursor():get("basic", "basic", "password")
	rv['freq'] = luci.model.uci.cursor():get("basic", "basic", "freq")
	rv['hotspot'] = luci.model.uci.cursor():get("travelmate", "global", "state")
	if rv['hotspot'] == "" then
		rv['hotspot'] = "0"
	end
	
	status = luci.model.uci.cursor():get("basic", "basic", "modem")
	rv['modemh'] = luci.model.uci.cursor():get("basic", "basic", "modemh")
	if status == "0" then
		rv['status'] = "0"
	else
		empty = luci.model.uci.cursor():get("modem", "modem1","empty")
		if empty == "1" then
			rv['status'] = "1"
		else
			stat = "/tmp/simpin1"
			file = io.open(stat, "r")
			if file == nil then
				rv["simerr"] = "0"
			else
				typ = file:read("*line")
				if typ == "0" then
					rv["simerr"] = "1"
				else
					if typ == "1" then
						rv["simerr"] = "2"
					else
						if typ == "2" then
							rv["simerr"] = "3"
						else
							rv["simerr"] = "4"
						end
					end
				end
				file:close()
			end
			connect = luci.model.uci.cursor():get("modem", "modem1","connected")
			if connect == "0" then
				rv['status'] = "2"
			else
				cmode = luci.model.uci.cursor():get("modem", "modem1","cmode")
				if cmode ~= "1" then
					rv['status'] = "3"
				else
					rv['status'] = "4"
					local file
					stat = "/tmp/status1.file"
					file = io.open(stat, "r")
					rv["port"] = file:read("*line")
					rv["csq"] = file:read("*line")
					rv["per"] = file:read("*line")
					rv["rssi"] = file:read("*line")
					rv["modem"] = file:read("*line")
					rv["cops"] = file:read("*line")
					rv["mode"] = file:read("*line")
					rv["lac"] = file:read("*line")
					rv["lacn"] = file:read("*line")
					rv["cid"] = file:read("*line")
					rv["cidn"] = file:read("*line")
					rv["mcc"] = file:read("*line")
					rv["mnc"] = file:read("*line")
					rv["rnc"] = file:read("*line")
					rv["rncn"] = file:read("*line")
					rv["down"] = file:read("*line")
					rv["up"] = file:read("*line")
					rv["ecio"] = file:read("*line")
					rv["rscp"] = file:read("*line")
					rv["ecio1"] = file:read("*line")
					rv["rscp1"] = file:read("*line")
					rv["netmode"] = file:read("*line")
					rv["cell"] = file:read("*line")
					rv["modtype"] = file:read("*line")
					rv["conntype"] = file:read("*line")
					rv["channel"] = file:read("*line")
					rv["phone"] = file:read("*line")
					file:read("*line")
					rv["lband"] = file:read("*line")
					rv["tempur"] = file:read("*line")
					rv["proto"] = file:read("*line")
					rv["pci"] = file:read("*line")
					rv["sinr"] = file:read("*line")
					file:close()
				end
			end
		end
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_getlist()
	local rv = {}
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/basic/fetchssid.lua " .. set)
	file = io.open("/tmp/listssid", "r")
	if file == nil then
		rv['listssid'] = "0"
	else
		rv['listssid'] = file:read("*line")
		file:close()
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setreconn()
	local set = luci.http.formvalue("set")
	os.execute("uci set basic.basic.reconn=" .. set .. "; uci commit basic")
end

function action_setkey()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/basic/setkey.lua \"" .. set .. "\"")
end