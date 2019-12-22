local clock = require('clock')
local creds = require("creds")

function setupWiFi()
    print("setting up WiFi")

    wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(t)
        print("wifi connected")
        clock.enableNetwork()
    end)
    wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(t)
        print("wifi disconnected:" .. t.reason)
        clock.disableNetwork()
    end)
    wifi.eventmon.register(wifi.eventmon.STA_GOT_IP,
                           function(t) print("got ip: " .. t.IP) end)

    wifi.setmode(wifi.STATION)

    local config = {}
    config.ssid = creds.ssid
    config.pwd = creds.password
    config.auto = true
    config.save = false

    local ok = wifi.sta.config(config)
    if not ok then print("invalid configuration") end
end

function init()
    setupWiFi()
    clock.start()
end

init()
