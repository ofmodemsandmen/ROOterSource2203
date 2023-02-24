module("luci.controller.scanc", package.seeall) 

I18N = require "luci.i18n"
translate = I18N.translate

function index()
	local page
	local lock = luci.model.uci.cursor():get("custom", "menu", "full")
	local enable = luci.model.uci.cursor():get("custom", "menu", "enabled")
	local multilock = luci.model.uci.cursor():get("custom", "multiuser", "multi") or "0"
	local rootlock = luci.model.uci.cursor():get("custom", "multiuser", "root") or "0"
	if (multilock == "0") or (multilock == "1" and rootlock == "1") then
		if lock == "1" then
			if (multilock == "1" and rootlock == "1") then
				page = entry({"admin", "adminmenu", "scanc"}, template("scan/scan"), translate("Band Scan Testing"), 65)
				page.dependent = true
			else
				if enable == "1" then
					page = entry({"admin", "adminmenu", "scanc"}, template("scan/scan"), translate("---Band Scan Testing"), 65)
					page.dependent = true
				else
					page = entry({"admin", "adminmenu", "scanc"}, template("scan/scan"), translate("Band Scan Testing"), 65)
					page.dependent = true
				end
			end
		end
	end
	
	entry({"admin", "modem", "getdata"}, call("action_getdata"))
	entry({"admin", "modem", "scanenable"}, call("action_scanenable"))
	entry({"admin", "modem", "settime"}, call("action_settime"))
	entry({"admin", "modem", "scantest"}, call("action_scantest"))
	entry({"admin", "modem", "setrepeat"}, call("action_setrepeat"))
	entry({"admin", "modem", "setdayweek"}, call("action_setdayweek"))
	entry({"admin", "modem", "setdaymon"}, call("action_setdaymon"))
	entry({"admin", "modem", "stopscan"}, call("action_stopscan"))

end

function action_getdata()
	local rv = {}
	local bnd = {}
	
	os.execute("/usr/lib/scan/getdata.sh")
	ispcnt = luci.model.uci.cursor():get("bandscan", "info", "ispcnt") 
	rv['enabled'] = luci.model.uci.cursor():get("bandscan", "info", "enabled")
	rv['time'] = luci.model.uci.cursor():get("bandscan", "info", "time")
	rv['repeat'] = luci.model.uci.cursor():get("bandscan", "info", "repeat")
	rv['ispcnt'] = ispcnt
	rv['dayweek'] = luci.model.uci.cursor():get("bandscan", "info", "dayweek")
	rv['daymon'] = luci.model.uci.cursor():get("bandscan", "info", "daymon")
	rv['running'] = luci.model.uci.cursor():get("bandscan", "info", "running")
	rv['stopping'] = luci.model.uci.cursor():get("bandscan", "info", "stopping")
	
	file = io.open("/tmp/ispinfo", "r")
	if file ~= nil then
		indx = 0
		repeat
			line = file:read("*line")
			bnd[indx] = line
			indx = indx + 1
		until line == nil
		file:close()
		rv['isp'] = bnd
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_scanenable()
	local set = luci.http.formvalue("set")
	
	os.execute("/usr/lib/scan/enable.sh " .. set)
end

function action_settime()
	local set = luci.http.formvalue("set")
	
	os.execute("/usr/lib/scan/settime.sh " .. set)
end

function action_scantest()
	local file
	local rv ={}

	file = io.open("/etc/scantest", "r")
	if file ~= nil then
		local tmp = file:read("*all")
		rv["scantest"] = tmp
		file:close()
	else
		rv["scantest"] = "No Scan Done"
	end
	rv['enabled'] = luci.model.uci.cursor():get("bandscan", "info", "enabled")
	rv['running'] = luci.model.uci.cursor():get("bandscan", "info", "running")
	rv['stopping'] = luci.model.uci.cursor():get("bandscan", "info", "stopping")

	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setrepeat()
	local set = luci.http.formvalue("set")
	
	os.execute("uci set bandscan.info.repeat=" .. set .. ";uci commit bandscan")
end

function action_setdayweek()
	local set = luci.http.formvalue("set")
	
	os.execute("uci set bandscan.info.dayweek=" .. set .. ";uci commit bandscan")
end

function action_setdaymon()
	local set = luci.http.formvalue("set")
	
	os.execute("uci set bandscan.info.daymon=" .. set .. ";uci commit bandscan")
end

function action_stopscan()
	os.execute("/usr/lib/scan/stopscan.sh &")
end