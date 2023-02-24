-- Licensed to the public under the Apache License 2.0.

module("luci.controller.portal", package.seeall)

I18N = require "luci.i18n"
translate = I18N.translate

function index()
		local page
		page = entry({"admin", "services", "portal"}, template("portal/portconfig"), _(translate("Captiive Portal")), 16)
		page.dependent = true
		
		entry({"admin", "portal", "getcfg"}, call("action_getcfg"))
		entry({"admin", "portal", "setcfg"}, call("action_setcfg"))
		entry({"admin", "portal", "set_portal"}, call("action_set_portal"))
end

function action_getcfg()
	local rv ={}
	
	rv['portalpassword'] = luci.model.uci.cursor():get("portal", "portal", "portalpassword")
	rv['time'] = luci.model.uci.cursor():get("portal", "portal", "time")
	rv['boot'] = luci.model.uci.cursor():get("portal", "portal", "boot")
	rv['enabled'] = luci.model.uci.cursor():get("portal", "portal", "enabled")
	rv['password'] = luci.model.uci.cursor():get("portal", "portal", "password")
	
	luci.http.prepare_content("application/json")
	luci.http.write_json(rv)
end

function action_setcfg()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/portal/setcfg.sh " .. set)
end

function action_set_portal()
	local set = luci.http.formvalue("set")
	os.execute("/usr/lib/portal/startstop.sh " .. set)
end