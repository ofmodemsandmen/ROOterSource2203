#!/usr/bin/lua


local sys = require "luci.sys"
local utl = require "luci.util"

key = arg[1]
ssid = {}
keys = {}

s, e = key:find("|")
keyssid = key:sub(0, s-1)
keykey = key:sub(e+1)
			
file = io.open("/etc/ssidkeys", "r")
if file == nil then
	local tfile = io.open("/etc/ssidkeys", "w")
	tfile:write(key, "\n")
	tfile:close()
else
	i = 0
	repeat
		line = file:read("*line")
		if line == nil then
			break
		else
			s, e = line:find("|")
			ssid[i] = line:sub(0, s-1)
			keys[i] = line:sub(e+1)
			i = i + 1
		end
	until 1==0
	file:close()
	flag = 0
	for m=0, i-1 do
		if keyssid == ssid[m] then
			flag = 1
			keys[m] = keykey
			break
		end
	end
	if flag == 0 then
		ssid[i] = keyssid
		keys[i] = keykey
		i = i + 1
	end
	
	local tfile = io.open("/etc/ssidkeys", "w")
	for m=0, i-1 do
		data = ssid[m] .. "|" .. keys[m]
		tfile:write(data, "\n")
		print(data)
	end
	tfile:close()
end