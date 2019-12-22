DHT_PIN=2
MQTT_HOST="broker.hivemq.com"
MQTT_PORT="1883"
MQTT_TOPIC="/ak84/home162v"

function onTimer()
status,temp,hum = dht.read11(DHT_PIN)
if status == 0 then
msg = "temp:"..temp..",hum:"..hum
m:publish(MQTT_TOPIC, msg, 0, 0, function() print("sent "..msg) end)
end
end

timer = tmr.create()

function onConnect() 
print("mqtt connected")
timer:register(5000, tmr.ALARM_AUTO, onTimer)
timer:start() 
end

function onOffline()
print("mqtt offline")
timer:unregister()
end

m = mqtt.Client()
m:on("connect", onConnect)
m:on("offline", onOffline)

local handleError, doMqttConnect

function handleError(client, reason)
print("failed to connect: "..reason)
mqttOnline=false
tmr.create():alarm(5000, tmr.ALARM_SINGLE, doMqttConnect)
end

function doMqttConnect()
m:connect(MQTT_HOST, MQTT_PORT, 0, onConnect, handleError)
end

function doMqttDisconnect()
m:close()
end

local app = {}

function app.start()
doMqttConnect()
end

function app.stop()
doMqttDisconnect()
end

return app