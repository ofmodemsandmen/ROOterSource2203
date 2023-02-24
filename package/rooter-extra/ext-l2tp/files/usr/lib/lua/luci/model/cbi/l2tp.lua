local utl = require "luci.util"

local sys   = require "luci.sys"
local zones = require "luci.sys.zoneinfo"
local fs    = require "nixio.fs"
local conf  = require "luci.config"

m = Map("l2tp", translate("L2TP VPN Setup"), translate("Set up the L2TP VPN"))

m.on_after_save = function(self)
	luci.sys.call("/usr/lib/l2tp/l2tp-start.sh &")
end

d = m:section(TypedSection, "l2tp", " ")
d.anonymous = true

url = d:option(Value, "url", translate("Server URL :"), translate("URL of the L2TP server")); 
url.rmempty = true;
url.optional=false;

secret = d:option(Value, "secret", translate("Secret :"), translate("Predefined secret authenication")); 
secret.rmempty = true;
secret.optional=false;

usr = d:option(Value, "username", translate("User Name :"), translate("User name")); 
usr.rmempty = true;
usr.optional=false;

pass = d:option(Value, "password", translate("Password :"), translate("Password")); 
pass.rmempty = true;
pass.optional=false;


return m