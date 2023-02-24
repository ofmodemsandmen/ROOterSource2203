-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

module("luci.controller.acs", package.seeall)

function index()
	local page

	page = entry({"admin", "adminmenu", "acs"}, cbi("acsset"), _("TR069 Settings"), 8)
	page.dependent = true
end
