module("luci.controller.scanr", package.seeall) 

I18N = require "luci.i18n"
translate = I18N.translate

function index()
	local page
	local lock = luci.model.uci.cursor():get("custom", "menu", "full")
	local multilock = luci.model.uci.cursor():get("custom", "multiuser", "multi") or "0"
	local rootlock = luci.model.uci.cursor():get("custom", "multiuser", "root") or "0"
	page = entry({"admin", "adminmenu", "report"}, template("scan/report"), translate("Band Scan Report"), 66)
	page.dependent = true
	entry({"admin", "modem", "getreportdata"}, call("action_getreportdata"))
	entry({"admin", "modem", "getrunning"}, call("action_getrunning"))
	entry({"admin", "modem", "running"}, call("action_running"))
end

function action_getreportdata()
	local rv = {}
	local band = {}
	
	rv['running'] = luci.model.uci.cursor():get("bandscan", "info", "running")
	rv['stopping'] = luci.model.uci.cursor():get("bandscan", "info", "stopping")
	file = io.open("/etc/sclist", "r")
	if file == nil then
		rv['numbands'] = "0"
	else
		rv['imei'] = file:read("*line")
		rv['routerid'] = file:read("*line")
		rv['isp'] = file:read("*line")
		rv['starttime'] = file:read("*line")

		i = 0
		repeat
			data = ""
			line1 = file:read("*line")
			data = data .. line1 .. "!"
			line = file:read("*line")
			if line ==nil then
				rv['endtime'] = line1
				break
			end
			data = data .. line .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line") .. "!"
			data = data .. file:read("*line")
			band[i] = data
			i = i + 1
		until 1 == 0
		rv['numbands'] = i
		rv['bands'] = band
		file:close()
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_getrunning()
	local rv = {}
	
	rv['running'] = luci.model.uci.cursor():get("bandscan", "info", "running")
	rv['stopping'] = luci.model.uci.cursor():get("bandscan", "info", "stopping")
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end	

function action_running()
	os.execute("/usr/lib/scan/scanchk.sh 1 &")
end