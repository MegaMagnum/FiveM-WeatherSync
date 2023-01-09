AddEventHandler('playerSpawned', function()
    SetWeatherOwnedByNetwork(false)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(GlobalState.WeatherSyncing)
    SetWeatherTypeNow(GlobalState.WeatherSyncing)
    SetWeatherTypeNowPersist(GlobalState.WeatherSyncing)

    if value == 'XMAS' then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
    else
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    end
    NetworkOverrideClockTime(GlobalState.TimeSyncing, GlobalState.TimeMinutesSyncing, 0)
    FreezeTimeCheck()
end)

Citizen.CreateThread(function()
    while true do 
        Weer = stringsplit(GetWeatherTypeTransition(), " ")
        if Weer[1] ~= GetHashKey(GlobalState.WeatherSyncing) then
            ClearOverrideWeather()
            ClearWeatherTypePersist()
            SetWeatherTypeNowPersist(GlobalState.WeatherSyncing)
            SetWeatherTypeNow(GlobalState.WeatherSyncing)
            SetWeatherTypeNowPersist(GlobalState.WeatherSyncing)
        end
        Citizen.Wait(15 * 1000)
    end
end)

AddStateBagChangeHandler('WeatherSyncing', nil, function(bagName, key, value) 
    SetWeatherTypeOverTime(value, 15.0)
    Wait(15000)
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypeNowPersist(value)
    SetWeatherTypeNow(value)
    SetWeatherTypeNowPersist(value)

    if value == 'XMAS' then
        SetForceVehicleTrails(true)
        SetForcePedFootstepsTracks(true)
    else
        SetForceVehicleTrails(false)
        SetForcePedFootstepsTracks(false)
    end
end)

AddStateBagChangeHandler('TimeMinutesSyncing', nil, function(bagName, key, value) 
    if not GlobalState.FreezeTimeSyncing then
        NetworkOverrideClockTime(tonumber(GlobalState.TimeSyncing), tonumber(value), 0)
    end
end)

AddStateBagChangeHandler('FreezeTimeSyncing', nil, function(bagName, key, value) 
    FreezeTimeCheck()
end)

AddStateBagChangeHandler('BlackoutSyncing', nil, function(bagName, key, value) 
    SetBlackout(value)
end)

RegisterNetEvent('WeatherSyncing:SendNotify', function(msg)
    TriggerEvent('chat:addMessage',{
        template = '<div style="padding: 0.5vw; margin: 0.1vw; background-color: rgba(155, 21, 20, 1); border-radius: 3px;"><i class="fas fa-flag"></i> ^*^4[Weather Syncing]^r^7: {0}',
        args = { msg }
       })
end)

function FreezeTimeCheck()
    Citizen.CreateThread(function()
        while GlobalState.FreezeTimeSyncing do
            Citizen.Wait(3000)
            NetworkOverrideClockTime(GlobalState.TimeSyncing, GlobalState.TimeMinutesSyncing, 0)
        end
    end)
end

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