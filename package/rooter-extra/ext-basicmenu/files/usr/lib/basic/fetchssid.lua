#!/usr/bin/lua


local sys = require "luci.sys"
local utl = require "luci.util"

wifi = {}
scan = {}
ssidx = {}
keysx = {}
numnet = 0
resource = "<%=media%>/basic/img"
lfile = io.open("/etc/config/luci", "r")
lline = lfile:read("*all")
lfile:close()
s, e = lline:find("option lang 'de'")
if s ~= nil then
	lang = "de"
else
	lang = "en"
end

printf = function(s,...)
	io.write(s:format(...))
	local ss = s:format(...)
end

function translate(english, german)
	if lang == "de" then
		return german
	else
		return english
	end
end

function trim(s)
  	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

function guess_wifi_signal(info)
	local scale = scan[info]["quality"]
	local icon
	if scale < 15 then
		icon = "/luci-static/resources/basic/img/signal-0.png"
	elseif scale < 35 then
		icon = "/luci-static/resources/basic/img/signal-0-25.png"
	elseif scale < 55 then
		icon = "/luci-static/resources/basic/img/signal-25-50.png"
	elseif scale < 75 then
		icon = "/luci-static/resources/basic/img/signal-50-75.png"
	else
		icon = "/luci-static/resources/basic/img/signal-75-100.png"
	end
	return icon
end

function scan_open(rrx, rry)
	rony = 1
	if rry["encrypt"] == "Open" then
		rony = 0
	end
	ronx = 1
	if rrx["encrypt"] == "Open" then
		ronx = 0
	end
	if ronx < rony then
		return true
	end
	if ronx > rony then
		return false
	end
	ronx = rrx["quality"]
	rony = rry["quality"]
	if ronx > rony then
		return true
	end
	return false
end

function partition(arr, left, right)
	local i = left
	local j = right
	local pivot = math.floor((left + right) / 2)
	local tmp
		while i <= j do
		while scan_open(arr[i], arr[pivot]) do
			i = i + 1
		end
		while scan_open(arr[pivot], arr[j]) do
			j = j - 1
		end
		if i <= j then
			tmp = arr[i]
			arr[i] = arr[j]
			arr[j] = tmp
			i = i + 1
			j = j - 1
		end
	end
	return i, arr
end

function  quicksort(arr, left, right)
	index, arr = partition(arr, left, right)
	if left < (index - 1) then
		quicksort(arr, left, index-1)
	end
	if index < right then
		quicksort(arr, index, right)
	end
	return arr
end

function build_scan(j, k)
	scan[k]["channel"] = wifi[j]["channel"]
	scan[k]["essid"] = wifi[j]["essid"]
	scan[k]["signal"] = tonumber(wifi[j]["signal"])
	qc = tonumber(wifi[j]["quality"])
	qm = tonumber(wifi[j]["quality_max"])
	scan[k]["quality"] = math.floor((100 / qm) * qc)
	scan[k]["ekey"] = wifi[j]["ekey"]
	if wifi[j]["ekey"] == "none" then
		scan[k]["encrypt"] = "Open"
		scan[k]["encryption"] = wifi[j]["encryption"]
	else
		scan[k]["encrypt"] = wifi[j]["ekey"]
		scan[k]["encryption"] = wifi[j]["encryption"]	
	end
end 

function get_networks(bnd)
	luci.util.exec("/usr/lib/basic/getssid.sh " .. bnd)
	file = io.open("/tmp/ssidlist", "r")
	if file == nil then
		numnet = 0
		return
	end
	i = 0
	cont = 2
	line = file:read("*line")
	repeat
		if line == nil then
			cont = 0
		else
			s, e = line:find("Cell ")
			if s ~= nil then
				cont = 1
				essid=nil
				i = i + 1
				wifi[i] = {}
				encryption = "none"
				repeat
					line = file:read("*line")
					if line == nil then
						cont = 0
						break
					else
						s, e = line:find("Cell ")
						if s ~= nil then
							break
						else
							s, e = line:find("ESSID:")
							if s ~= nil then
								ee = line:len()
								essid = trim(line:sub(e+3, ee-1))
							end
							s, e = line:find("Mode:")
							if s ~= nil then
								line1 = trim(line:sub(e+1))
								bs, be = line1:find(" ", 1)
								mode = trim(line1:sub(1, bs))
								cs, ce = line1:find(" ")
								line2 = trim(line1:sub(ce+1))
								s, e = line2:find("Channel:")
								channel = trim(line2:sub(e+2))
							end
							s, e = line:find("Signal:")
							if s ~= nil then
								line1 = trim(line:sub(e+1))
								bs, be = line1:find(" ", 1)
								signal = trim(line1:sub(1, bs))
								cs, ce = line1:find(" ")
								line2 = trim(line1:sub(ce+1))
								s, e = line2:find("Quality:")
								cs, ce = line2:find("/", e)
								quality = trim(line2:sub(e+1, ce-1))
								quality_max = trim(line2:sub(ce+1))
							end
							s, e = line:find("Encryption:")
							if s ~= nil then
								cs, ce = line:find("WEP")
								if cs == nil then
									encrypt = trim(line:sub(e+2))
									s, e = encrypt:find("none")
									if s ~= nil then
										encryption = "none"
									else
										s, e = encrypt:find("mixed")
										if s ~= nil then
											encryption = "psk-mixed"
										else
											s, e = encrypt:find("WPA2")
											if s ~= nil then
												encryption = "psk2"
											else
												encryption = "psk"
											end
										end
									end
								else
									cont = 2
									i = i - 1
									break
								end
							end
						end
				end
				until 1==0
			else
				line = file:read("*line")
			end
		end
		if cont < 2 then
			if i > 0 then
				if essid ~= nil and mode == "Master" then
					wifi[i]["essid"] = essid
					wifi[i]["channel"] = channel
					wifi[i]["signal"] = signal
					wifi[i]["quality"] = quality
					wifi[i]["quality_max"] = quality_max
					wifi[i]["ekey"] = encrypt
					wifi[i]["encryption"] = encryption
				end
			end
		end
		if cont == 0 then
			break
		end
		cont = 2
	until 1==0
	file:close()

	k = 0
	if i > 0 then
		for j=1, i do
			if wifi[j]["essid"] ~= nil and tonumber(wifi[j]["quality"]) > 0 then
				if k < 1 then
					k = k+1
					scan[k] = {}
					build_scan(j, k)
				else
					flag = 0
					for l=1, k do
						if wifi[j]["essid"] == scan[l]["essid"] and wifi[j]["channel"] == scan[l]["channel"]  and wifi[j]["ekey"] == scan[l]["ekey"] then
							qc = tonumber(wifi[j]["quality"])
							qm = tonumber(wifi[j]["quality_max"])
							qual = math.floor((100 / qm) * qc)
							if qual > scan[l]["quality"] then
								build_scan(j, l)
							end
							flag = 1
							break
						end
					end
					if flag == 0 then
						k = k+1
						scan[k] = {}
						build_scan(j, k)
					end
				end
			end
		end
		scan = quicksort(scan, 1, k)
	end
	numnet = k
end

function get_keys()
	local i = 0
	local kfile = io.open("/etc/ssidkeys", "r")
	if kfile ~= nil then
		repeat
			line = kfile:read("*line")
			if line == nil then
				break
			else
				s, e = line:find("|")
				ssidx[i] = line:sub(0, s-1)
				keysx[i] = line:sub(e+1)
				i = i + 1
			end
		until 1==0
		kfile:close()
	end
	return i
end

function search_keys(ssids, ix)
	if ix > 0 then
		for mm=0, ix-1 do
			if ssids == ssidx[mm] then
				return keysx[mm]
			end
		end
	end
	return nil
end

lblpass = translate("Save Password", "Passwort Speichern")
lblconn = translate("Connect", "Verbinden")
lblencr = translate("Encryption", "Verschlüsselung")
lblkey = translate("Password", "Passwort")
lblchan = translate("Channel", "Kanal")


str1 = '<table width="550"  border="0"><tr><td class="cbi-value-field" style="width:32px; padding:3px;font-size:16px;"><abbr><img src="'
str2 = '" /><br />'
str3 = '</abbr></td><td class="cbi-value-field" style="vertical-align:middle; text-align:left; padding:3px;font-size:20px;"><strong>'
str4 = '</strong><br /><strong>'
str4a = ':</strong>'
str5 = '<br><strong>'
str5a = ':</strong> '
str6 = '</br><br><div><label for="pwd"><strong>'
str6a = ' : &nbsp;&nbsp;&nbsp;</strong></label><input type="text" style="font-size:18px;" id="'
str7 = '" value="'
str7b = '" /><input type="button" id="'
str7a = '" class="cbi-button cbi-button-action" value="'
str7c = '"  style="font-size:16px;" onclick="return addkey(this.id)" /><div><td class="cbi-value-field" style="vertical-align:middle; text-align:right; padding:3px"><input type="button" id="'
str8 = '" class="cbi-button cbi-button-link" value="'
str8a = '"  style="font-size:20px;" onclick="return addlist(this.id)" /></td></tr></table>'
bnd = arg[1]
get_networks(bnd)
os.remove("/tmp/listssid")
wtab = ""
savedkeys = get_keys()

if numnet > 0 then 
	for m=1, numnet do 
	
		value = search_keys(scan[m]["essid"], savedkeys)
		if value == nil then
			value = str7 .. str7b
		else
			value = str7 .. value .. str7b
		end
		
		data = scan[m]["essid"] .. "|" .. scan[m]["encryption"]
		tab = str1 .. guess_wifi_signal(m) .. str2 .. scan[m]["quality"] .. "%" .. str3 .. scan[m]["essid"] .. str4 .. lblchan .. str4a .. scan[m]["channel"]
		tab = tab .. str5 .. lblencr .. str5a .. scan[m]["encrypt"] .. str6 .. lblkey .. str6a .. "pass" .. scan[m]["essid"] .. value .. "add|" .. data .. str7a .. lblpass .. str7c .. data .. str8 .. lblconn .. str8a
		wtab = wtab ..tab
	end
	local tfile = io.open("/tmp/listssid", "w")
	tfile:write(wtab, "\n")
	tfile:close()
end

