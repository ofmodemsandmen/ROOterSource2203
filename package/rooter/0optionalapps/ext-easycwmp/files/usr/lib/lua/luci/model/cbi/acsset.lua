-- Copyright 2008 Yanira <forum-2008@email.de>
-- Licensed to the public under the Apache License 2.0.

require("nixio.fs")

m = Map("acs", "TR069 System",
	translate("Set values for using the TR069 System"))
		
m.on_after_save = function(self)
	luci.sys.call("/usr/lib/easycwmp/acs.sh &")
end

s = m:section(TypedSection, "acs", translate("Settings"))
s.anonymous = true

c1 = s:option(ListValue, "enable", translate("Enabled "));
c1:value("0", translate("Disabled"))
c1:value("1", translate("Enabled"))
c1.default=0

ip = s:option(Value, "ip", translate("Server IP Address and Port : "))

user = s:option(Value, "username", translate("CPE to ACS UserName : "))
user.default = ""

pass = s:option(Value, "password", translate("CPE to ACS Password : "))
pass.default = ""


return m
