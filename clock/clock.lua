local display = require('tm1637')
local sntp = require('sntp')
local rtctime = require('rtctime')
local networkEnabled = false
local ticker = true
local hour, minute = 12, 34
local timeServers = {
    '0.ua.pool.ntp.org', '1.ua.pool.ntp.org', '2.ua.pool.ntp.org',
    '3.ua.pool.ntp.org'
}

function initDisplay()
    print('initializing display')
    display.init(5, 6)
    display.set_brightness(3)
    display.write_string('12.34')
end

function updateDisplay()
    print('updating display')
    local epochTime = rtctime.get()
    print('epoch time ' .. epochTime)
    if epochTime == 0 then return end
    local calTime = rtctime.epoch2cal(epochTime)
    hour, minute = calTime['hour'], calTime['min']
    print(hour .. ' ' .. minute)
    local timeStr = string.format('%d%s%d', hour, ticker and '.' or '', minute)
    display.write_string(timeStr)
    ticker = not ticker
end

local ntpErrors = {
    'DNS lookup failed', 'Memory allocation failure', 'UDP send failed',
    'Timeout, no NTP response received'
}

function updateTime()
    print('updating time')
    if networkEnabled then
        print('syncing time with server')
        sntp.sync(timeServers, function() print('ntp sync success') end,
                  function(errType, details)
            print('ntp sync failed:', ntpErrors[errType], details)
        end)
    end
end

local displayTimer
local timeTimer

local M = {}

function M.start()
    print('starting clock')
    initDisplay()

    displayTimer = tmr.create()
    displayTimer:register(1000, tmr.ALARM_AUTO, updateDisplay)
    displayTimer:start()

    timeTimer = tmr.create()
    timeTimer:register(30 * 60 * 1000, tmr.ALARM_AUTO, updateTime)
    timeTimer:start()

end

function M.stop()
    print('stopping clock')
    display.clear()
    displayTimer:unregister()
    timeTimer:unregister()
end

function M.enableNetwork()
    networkEnabled = true
    updateTime()
end

function M.disableNetwork() networkEnabled = false end

return M
