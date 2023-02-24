-- Licensed to the public under the Apache License 2.0.

module("luci.controller.l2tpd", package.seeall)

function index()
	local lock = luci.model.uci.cursor():get("custom", "menu", "full")
	if lock == "1" then
		local page
		page = entry({"admin", "adminmenu", "l2tpd"}, cbi("l2tp"), _("---L2TP VPN"), 12)
		page.dependent = true
	end
end
