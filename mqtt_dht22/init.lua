local app = require("app")
local creds = require("creds")

function setupWiFi()
print("setting up WiFi")

wifi.eventmon.register(wifi.eventmon.STA_CONNECTED,function(t) print("wifi connected");app.start() end)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(t) print("wifi disconnected:"..t.reason);app.stop() end)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(t) print("got ip: "..t.IP) end)

wifi.setmode(wifi.STATION)

config = {}
config.ssid=creds.ssid
config.pwd=creds.password
config.auto=true
config.save=false

ok = wifi.sta.config(config)
if not ok then
print("invalid configuration")
end
end

function init()
print('running init')
setupWiFi()
end

init()
