module("luci.controller.flash", package.seeall)

I18N = require "luci.i18n"
translate = I18N.translate

function index()
	local lock = luci.model.uci.cursor():get("custom", "menu", "full")
	local multilock = luci.model.uci.cursor():get("custom", "multiuser", "multi") or "0"
	local rootlock = luci.model.uci.cursor():get("custom", "multiuser", "root") or "0"
	if (multilock == "0") or (multilock == "1" and rootlock == "1") then
		if lock == "1" then
			entry({"admin", "adminmenu", "flash"}, template("flash/flash"), translate("Automatic Update"), 16)
		else
			entry({"admin", "adminmenu", "flash"}, template("flash/flash"), translate("---Automatic Update"), 16)
		end
	end
	
	entry({"admin", "adminmenu", "settime"}, call("action_settime"))
	entry({"admin", "adminmenu", "getflash"}, call("action_getflash"))
	entry({"admin", "adminmenu", "setip"}, call("action_setip"))
	entry({"admin", "adminmenu", "setrandom"}, call("action_setrandom"))
end

function action_settime()
	local set = luci.http.formvalue("set")
	
	os.execute("/usr/lib/flash/settime.sh " .. set)
end

function action_setip()
	local set = luci.http.formvalue("set")
	
	os.execute("/usr/lib/flash/setip.sh " .. set)
end

function action_setrandom()
	local set = luci.http.formvalue("set")
	
	os.execute("/usr/lib/flash/setrandom.sh " .. set)
end

function action_getflash()
	local rv = {}
	
	rv['time'] = luci.model.uci.cursor():get("flash", "flash", "time")
	rv['server'] = luci.model.uci.cursor():get("flash", "flash", "server")
	rv['random'] = luci.model.uci.cursor():get("flash", "flash", "random")
	if rv['random'] == nil then
		rv['random'] = '0'
	end
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end