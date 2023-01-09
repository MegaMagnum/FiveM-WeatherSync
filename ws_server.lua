AvailableWeatherTypes = {
    'EXTRASUNNY', 
    'CLEAR', 
    'NEUTRAL', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
    'THUNDER', 
    'SNOW', 
    'BLIZZARD', 
    'SNOWLIGHT', 
    'XMAS', 
    'HALLOWEEN',
}

ForceXMAS = false

DynamicWeather = {
    'EXTRASUNNY', 
    'EXTRASUNNY', 
    'EXTRASUNNY', 
    'EXTRASUNNY', 
    'EXTRASUNNY', 
    'EXTRASUNNY', 
    'CLEAR', 
    'SMOG', 
    'FOGGY', 
    'OVERCAST', 
    'OVERCAST', 
    'OVERCAST', 
    'CLOUDS', 
    'CLOUDS', 
    'CLOUDS', 
    'CLEARING', 
    'RAIN', 
}

Citizen.CreateThread(function()
    GlobalState.WeatherSyncing = 'EXTRASUNNY'
    GlobalState.TimeSyncing = 12
    GlobalState.TimeMinutesSyncing = 0
    GlobalState.FreezeTimeSyncing = false
    GlobalState.FreezeWeatherSyncing = false
    GlobalState.BlackoutSyncing = false
    if ForceXMAS then
        GlobalState.WeatherSyncing = 'XMAS'
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(2000)
        if not GlobalState.FreezeTimeSyncing then
            GlobalState.TimeMinutesSyncing = GlobalState.TimeMinutesSyncing + 1
            if GlobalState.TimeSyncing < 6 or GlobalState.TimeSyncing > 22 then
                GlobalState.TimeMinutesSyncing = GlobalState.TimeMinutesSyncing + 2
            end
            if GlobalState.TimeMinutesSyncing >= 60 then
                if GlobalState.TimeSyncing < 24 then
                    GlobalState.TimeSyncing = GlobalState.TimeSyncing + 1
                    if math.random(8) == 2 then
                        NextWeather()
                    end
                elseif GlobalState.TimeSyncing == 24 then
                    GlobalState.TimeSyncing = 0
                end
                GlobalState.TimeMinutesSyncing = 0
            end
        end
    end
end)


function IsIdAdmin(id)
    if id == 0 or IsPlayerAceAllowed(id, 'Weathersync.change') then
        return true
    else
        return false
    end
end

RegisterCommand('freezeweather', function(source) 
    if IsIdAdmin(source) then 
        if FrozenWeather then
            FrozenWeather = false
            GlobalState.FreezeWeatherSyncing = false
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Dynamic weather on!')
        else
            FrozenWeather = true
            GlobalState.FreezeWeatherSyncing = true
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Dynamic weahter off!')
        end
    end
end)

RegisterCommand('freezetime', function(source) 
    if IsIdAdmin(source) then 
        if FrozenTime then
            FrozenTime = false
            GlobalState.FreezeTimeSyncing = false
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Dynamic time on!')
        else
            FrozenTime = true
            GlobalState.FreezeTimeSyncing = true
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Dynamic time off!')
        end
    end
end)

RegisterCommand('weather', function(source, args) 
    if IsIdAdmin(source) then 
        if args[1] then
            if CheckWeatherArg(args[1]) then
                GlobalState.WeatherSyncing = string.upper(args[1])
                TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Weather is now: '..GlobalState.WeatherSyncing)
            else
                TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Weather type not in table')
            end
        else
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Enter in a type (/weather EXTRASUNNY)')
        end
    end
end)

RegisterCommand('time', function(source, args) 
    if IsIdAdmin(source) then 
        print(args[1], args[2])
        if args[1] and args[2] then
            if tonumber(args[1]) <= 24 and tonumber(args[2]) <= 60 then
                GlobalState.TimeSyncing = tonumber(args[1])
                GlobalState.TimeMinutesSyncing = tonumber(args[2])
                TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Time is now: '..GlobalState.TimeSyncing..' '..GlobalState.TimeMinutesSyncing)
                GlobalState.TimeMinutesSyncing = GlobalState.TimeMinutesSyncing + 1
            else
                TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Wrong format (/time 12)')
            end
        else
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Wrong format (/time 12 0)')
        end
    end
end)

RegisterCommand('blackout', function(source, args) 
    if IsIdAdmin(source) then 
        if GlobalState.BlackoutSyncing then
            GlobalState.BlackoutSyncing = false
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Blackout off!')
        else
            GlobalState.BlackoutSyncing = true
            TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Blackout on!')
        end
    end
end)

RegisterCommand('WeatherDebug', function(source) 
    TriggerClientEvent('WeatherSyncing:SendNotify', source, 'Current Sync: '..GlobalState.WeatherSyncing..' '..GlobalState.TimeSyncing..':'..GlobalState.TimeMinutesSyncing)
end)


function stringsplit(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
	return t
end

function CheckWeatherArg(arg)
    for i,wtype in ipairs(AvailableWeatherTypes) do
        if string.upper(arg) == wtype then
            return true
        end
    end
    return false
end

function NextWeather()
   if not GlobalState.FreezeWeatherSyncing and not ForceXMAS then
    GlobalState.WeatherSyncing = DynamicWeather[math.random(#DynamicWeather)]
   end
   if ForceXMAS then
    GlobalState.WeatherSyncing = 'XMAS'
   end
end