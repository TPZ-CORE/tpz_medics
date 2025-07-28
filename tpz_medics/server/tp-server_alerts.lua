local TPZ = exports.tpz_core:getCoreAPI()

local AlertArchives = {}

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    AlertArchives = nil
end)

-----------------------------------------------------------
--[[ General Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_medics:server:request_alerts")
AddEventHandler("tpz_medics:server:request_alerts", function()
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    
    if not xPlayer.loaded() then
        return
    end

    local currentJob = xPlayer.getJob()

    local isPermitted = false

    for index, job in pairs (Config.Jobs) do

        if job == currentJob then

            isPermitted = true
        end

    end

    if not isPermitted then
        return
    end

    TriggerClientEvent("tpz_medics:client:update_alerts", _source, { actionType = "REQUEST", data = AlertArchives })

end)

RegisterServerEvent("tpz_medics:server:alert")
AddEventHandler("tpz_medics:server:alert", function()
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    
    if not xPlayer.loaded() then
        return
    end

    local identifier          = xPlayer.getIdentifier()
    local characterIdentifier = xPlayer.getCharacterIdentifier()
    local fullname            = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
    local steamName           = GetPlayerName(_source)

    local currentTime = os.date("*t") -- Get current date and time as a table
    -- Modify only the year
    currentTime.year = Config.Year

    -- Get the new timestamp with modified year
    local modifiedTimestamp = os.time(currentTime)
    local formatted_date    = os.date("%d/%m/%Y %H:%M:%S", modifiedTimestamp)

    local ped               = GetPlayerPed(_source)
    local playerCoords      = GetEntityCoords(ped)
            
    
    local insert_data = { 
        fullname = fullname,
        source   = _source,
        coords   = playerCoords,
        signed   = 0,
        date     = formatted_date, 
    } 

    table.insert(AlertArchives, insert_data)

    -- update on jobs only. 
    TPZ.TriggerClientEventByJobs("tpz_medics:client:update_alerts", { actionType = "INSERT", data = insert_data }, Config.Jobs) 

    if Config.Webhooks['ALERTS'].Enabled then
		local title   = "🚑`New Unconsious Alert`"
		local message = string.format("The player with the online player id: `%s` and fullname as: `%s` is unconsious and sent an alert requesting for medical assistance.", _source, fullname)
		
		TPZ.SendToDiscord(Config.Webhooks['ALERTS'].Url, title, message, Config.Webhooks['ALERTS'].Color)
	end

end)

