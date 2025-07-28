local TPZ = exports.tpz_core:getCoreAPI()

local AlertArchives = {}

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local function toProperCase(str)
    return str:lower():gsub("(%a)(%w*)", function(first, rest)
        return first:upper() .. rest
    end)
end

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    AlertArchives = nil
end)

-----------------------------------------------------------
--[[ General Events ]]--
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
AddEventHandler("tpz_medics:server:alert", function(unconscious, description)
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
    local formatted_date = os.date("%d/%m/%Y %H:%M:%S", modifiedTimestamp)

    local ped = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)
            
    local insert_data = { 
        fullname    = fullname,
        source      = _source,
        description = description,
        coords      = coords,
        signed      = 0,
        date        = formatted_date, 
    } 

    table.insert(AlertArchives, insert_data)

    -- update on jobs only. 
    TPZ.TriggerClientEventByJobs("tpz_medics:client:update_alerts", { actionType = "INSERT", data = insert_data }, Config.Jobs) 

    if Config.Webhooks['ALERTS'].Enabled then
		local title   = "🚑`New Alert`"
		local message = string.format("The player with the online player id: `%s` and fullname as: `%s` is sent an alert requesting for medical assistance.\n\n**Description:** `%s`\n\n**Coordinates (X,Y,Z):** `%s`", _source, fullname, description, coords.x .. " " .. coords.y .. " " .. coords.z)
		
        if unconscious then
            description = Locales["UNCONSCIOUS_ALERT_DESCRIPTION"]
        end

		TPZ.SendToDiscord(Config.Webhooks['ALERTS'].Url, title, message, Config.Webhooks['ALERTS'].Color)
	end

end)

RegisterServerEvent("tpz_medics:server:sign_alert")
AddEventHandler("tpz_medics:server:sign_alert", function(targetDate)
    local _source    = source
    local xPlayer    = TPZ.GetPlayer(_source)

    local firstname  = xPlayer.getFirstName()
    local lastname   = xPlayer.getLastName()
    local fullname   = toProperCase(firstname .. " " .. lastname)

    local isSignedAlready = false 

    for index, archive in pairs(AlertArchives) do

        if archive.date == targetDate then

            if archive.signed == 0 then
                archive.signed = fullname
            else
                isSignedAlready = true
            end

        end

    end

    if not isSignedAlready then
        TPZ.TriggerClientEventByJobs("tpz_medics:client:update_alerts", { actionType = "SET_SIGNED", data = { fullname, targetDate }, Config.Jobs) 
    else
        TriggerClientEvent("tpz_medics:client:alerts_nui_notify", Locales["ARCHIVE_ALERT_ALREADY_SIGNED"], "error")
    end

end)

