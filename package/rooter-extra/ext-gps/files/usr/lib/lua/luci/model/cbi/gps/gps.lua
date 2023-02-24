local utl = require "luci.util"
local uci = require "luci.model.uci".cursor()
local sys   = require "luci.sys"

m = Map("gps", translate("GPS Information"),
	translate("View GPS information and configure sending reports"))

m.on_after_commit = function(self)
	luci.sys.call("/usr/lib/gps/change.sh &")
end
	
di = m:section(TypedSection, "configuration", translate(" "), translate(" "))
di.anonymous = true
di:tab("data", translate("GPS Information"))
di:tab("gpsconfig", translate("GPS Configuration"))
di:tab("config", translate("Report Configuration"))

this_tab = "data"

sx = di:taboption(this_tab, Value, "_dmy1", translate(" "))
sx.template = "gps/gps"

this_tab = "gpsconfig"

sxx = di:taboption(this_tab, Value, "_dmy2", translate(" "))
sxx.template = "gps/space"

c1 = di:taboption(this_tab, ListValue, "convert", translate("Latitude and Longitude Format"), translate("Use Degrees or Decimal format"));
c1:value("0", translate("Degrees/Minutes/Seconds"))
c1:value("1", translate("Decimal"))
c1.default=0

cd1 = di:taboption(this_tab, ListValue, "datefor", translate("Format of Date"), translate("Format used to display date"));
cd1:value("0", translate("Year-Month-Day"))
cd1:value("1", translate("Day/Month/Year"))
cd1.default=0

interval = di:taboption(this_tab, Value, "zoom", translate("Default Map Zoom"), translate("Zoom level of map from 1 (least) to 22 (most).")); 
interval.datatype = 'range(1,22)';
interval.default="15";

int = di:taboption(this_tab, Value, "refresh", translate("Information Refresh Interval"), translate("Amount of time in seconds between getting GPS information . Range is 10 to 500")); 
int.datatype = 'range(10,500)';
int.default="15";

--
-- Report Configuration
--

this_tab = "config"

sxx = di:taboption(this_tab, Value, "_dmy2", translate(" "))
sxx.template = "gps/space"

int = di:taboption(this_tab, Value, "name", translate("Identification Text"), translate("Optional text shown on reports for identification purposes")); 


sxx = di:taboption(this_tab, DummyValue, "_dmy2", translate(" "))
sxx = di:taboption(this_tab, DummyValue, "_dmy3", translate(" "))

sxx = di:taboption(this_tab, Value, "_dmy2", translate(" "))
sxx.template = "gps/station"

times = di:taboption(this_tab, ListValue, "times", translate("Number of Reports per Day"), translate("Times when reports are sent if position is stationary"))
times.rmempty = true
times:value("0", "None")
times:value("1", "1 times per day")
times:value("2", "2 times per day")
times:value("3", "3 times per day")
times:value("4", "4 times per day")
times:value("5", "5 times per day")
times.default = "0"

function gethour(xsdhour)
	xsdhour:value("0", "12:00 AM")
	xsdhour:value("1", "12:15 AM")
	xsdhour:value("2", "12:30 AM")
	xsdhour:value("3", "12:45 AM")
	xsdhour:value("4", "01:00 AM")
	xsdhour:value("5", "01:15 AM")
	xsdhour:value("6", "01:30 AM")
	xsdhour:value("7", "01:45 AM")
	xsdhour:value("8", "02:00 AM")
	xsdhour:value("9", "02:15 AM")
	xsdhour:value("10", "02:30 AM")
	xsdhour:value("11", "02:45 AM")
	xsdhour:value("12", "03:00 AM")
	xsdhour:value("13", "03:15 AM")
	xsdhour:value("14", "03:30 AM")
	xsdhour:value("15", "03:45 AM")
	xsdhour:value("16", "04:00 AM")
	xsdhour:value("17", "04:15 AM")
	xsdhour:value("18", "04:30 AM")
	xsdhour:value("19", "04:45 AM")
	xsdhour:value("20", "05:00 AM")
	xsdhour:value("21", "05:15 AM")
	xsdhour:value("22", "05:30 AM")
	xsdhour:value("23", "05:45 AM")
	xsdhour:value("24", "06:00 AM")
	xsdhour:value("25", "06:15 AM")
	xsdhour:value("26", "06:30 AM")
	xsdhour:value("27", "06:45 AM")
	xsdhour:value("28", "07:00 AM")
	xsdhour:value("29", "07:15 AM")
	xsdhour:value("30", "07:30 AM")
	xsdhour:value("31", "07:45 AM")
	xsdhour:value("32", "08:00 AM")
	xsdhour:value("33", "08:15 AM")
	xsdhour:value("34", "08:30 AM")
	xsdhour:value("35", "08:45 AM")
	xsdhour:value("36", "09:00 AM")
	xsdhour:value("37", "09:15 AM")
	xsdhour:value("38", "09:30 AM")
	xsdhour:value("39", "09:45 AM")
	xsdhour:value("40", "10:00 AM")
	xsdhour:value("41", "10:15 AM")
	xsdhour:value("42", "10:30 AM")
	xsdhour:value("43", "10:45 AM")
	xsdhour:value("44", "11:00 AM")
	xsdhour:value("45", "11:15 AM")
	xsdhour:value("46", "11:30 AM")
	xsdhour:value("47", "11:45 AM")
	xsdhour:value("48", "12:00 PM")
	xsdhour:value("49", "12:15 PM")
	xsdhour:value("50", "12:30 PM")
	xsdhour:value("51", "12:45 PM")
	xsdhour:value("52", "01:00 PM")
	xsdhour:value("53", "01:15 PM")
	xsdhour:value("54", "01:30 PM")
	xsdhour:value("55", "01:45 PM")
	xsdhour:value("56", "02:00 PM")
	xsdhour:value("57", "02:15 PM")
	xsdhour:value("58", "02:30 PM")
	xsdhour:value("59", "02:45 PM")
	xsdhour:value("60", "03:00 PM")
	xsdhour:value("61", "03:15 PM")
	xsdhour:value("62", "03:30 PM")
	xsdhour:value("63", "03:45 PM")
	xsdhour:value("64", "04:00 PM")
	xsdhour:value("65", "04:15 PM")
	xsdhour:value("66", "04:30 PM")
	xsdhour:value("67", "04:45 PM")
	xsdhour:value("68", "05:00 PM")
	xsdhour:value("69", "05:15 PM")
	xsdhour:value("70", "05:30 PM")
	xsdhour:value("71", "05:45 PM")
	xsdhour:value("72", "06:00 PM")
	xsdhour:value("73", "06:15 PM")
	xsdhour:value("74", "06:30 PM")
	xsdhour:value("75", "06:45 PM")
	xsdhour:value("76", "07:00 PM")
	xsdhour:value("77", "07:15 PM")
	xsdhour:value("78", "07:30 PM")
	xsdhour:value("79", "07:45 PM")
	xsdhour:value("80", "08:00 PM")
	xsdhour:value("81", "08:15 PM")
	xsdhour:value("82", "08:30 PM")
	xsdhour:value("83", "08:45 PM")
	xsdhour:value("84", "09:00 PM")
	xsdhour:value("85", "09:15 PM")
	xsdhour:value("86", "09:30 PM")
	xsdhour:value("87", "09:45 PM")
	xsdhour:value("88", "10:00 PM")
	xsdhour:value("89", "10:15 PM")
	xsdhour:value("90", "10:30 PM")
	xsdhour:value("91", "10:45 PM")
	xsdhour:value("92", "11:00 PM")
	xsdhour:value("93", "11:15 PM")
	xsdhour:value("94", "11:30 PM")
end

t1hour = di:taboption(this_tab, ListValue, "time1", translate("Report Time #1"))
t1hour.rmempty = true
gethour(t1hour)
t1hour.default = "32"
t1hour:depends("times", "1")
t1hour:depends("times", "2")
t1hour:depends("times", "3")
t1hour:depends("times", "4")
t1hour:depends("times", "5")


t2hour = di:taboption(this_tab, ListValue, "time2", translate("Report Time #2"))
t2hour.rmempty = true
gethour(t2hour)
t2hour.default = "36"
t2hour:depends("times", "2")
t2hour:depends("times", "3")
t2hour:depends("times", "4")
t2hour:depends("times", "5")

t3hour = di:taboption(this_tab, ListValue, "time3", translate("Report Time #3"))
t3hour.rmempty = true
gethour(t3hour)
t3hour.default = "40"
t3hour:depends("times", "3")
t3hour:depends("times", "4")
t3hour:depends("times", "5")

t4hour = di:taboption(this_tab, ListValue, "time4", translate("Report Time #4"))
t4hour.rmempty = true
gethour(t4hour)
t4hour.default = "44"
t4hour:depends("times", "4")
t4hour:depends("times", "5")

t5hour = di:taboption(this_tab, ListValue, "time5", translate("Report Time #5"))
t5hour.rmempty = true
gethour(t5hour)
t5hour.default = "48"
t5hour:depends("times", "5")


sxx = di:taboption(this_tab, DummyValue, "_dmy2", translate(" "))
sxx = di:taboption(this_tab, DummyValue, "_dmy3", translate(" "))

sxx = di:taboption(this_tab, Value, "_dmy2", translate(" "))
sxx.template = "gps/move"

pos = di:taboption(this_tab, ListValue, "type2", translate("Send Report with Change in Position"), translate("Send reports while GPS location is changing"))
pos.rmempty = true
pos:value("0", "No")
pos:value("1", "Yes")


intx = di:taboption(this_tab, Value, "minterval", translate("Interval in Minutes"), translate("Interval in minutes between sending reports when position is changing. Range is 1 to 300")); 
intx.datatype = 'range(1,300)';
intx.default="30";
intx:depends("type2", true)

ppos = di:taboption(this_tab, ListValue, "precision", translate("Movement Minimum"), translate("Minumum Position Change to Trigger a Report"))
ppos.rmempty = true
ppos:value("10", "10 M")
ppos:value("20", "20 M")
ppos:value("30", "30 M")
ppos:value("40", "40 M")
ppos:value("50", "50 M")
ppos:value("60", "60 M")
ppos:value("70", "70 M")
ppos:value("80", "80 M")
ppos:value("90", "90 M")
ppos:value("100", "100 M")
ppos:value("200", "200 M")
ppos:value("300", "300 M")
ppos:value("400", "400 M")
ppos:value("500", "500 M")
ppos.default="20";
ppos:depends("type2", true)

sxx = di:taboption(this_tab, DummyValue, "_dmy2", translate(" "))
sxx = di:taboption(this_tab, DummyValue, "_dmy3", translate(" "))

sxx = di:taboption(this_tab, Value, "_dmy2", translate(" "))
sxx.template = "gps/method"

cdz = di:taboption(this_tab, ListValue, "sendby", translate("Send By"), translate("Send report by these methods"));
cdz:value("0", translate("Text Message"))
cdz:value("1", translate("Email"))
cdz:value("2", translate("Text message and Email"))
cdz.default="2"

ph = di:taboption(this_tab, Value, "phone", translate("Phone Number :"));
ph.optional=false; 
ph.rmempty = true;
--ph.datatype = "phonedigit"
ph:depends("sendby", "0")
ph:depends("sendby", "2")
ph.default = "12223334444"

ph1 = di:taboption(this_tab, Value, "email", translate("Email Address :"));
ph1.optional=false; 
ph1.rmempty = true;
ph1:depends("sendby", "1")
ph1:depends("sendby", "2")
ph1.default = "jdoe@domain.com"

sxx = di:taboption(this_tab, DummyValue, "_dmy2", translate(" "))

btn = di:taboption(this_tab, Button, "_btn", translate(" "))
btn.inputtitle = translate("Send Test Text and/or Email")
btn.inputstyle = "apply"
function btn.write()
	luci.sys.call("/usr/lib/gps/sendreport.sh 3")
end

return m
