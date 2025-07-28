local TPZ = exports.tpz_core:getCoreAPI()

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

    TriggerClientEvent("tpz_alerts:client:update_alerts", _source, { actionType = "REQUEST", data = AlertArchives })

end)

RegisterServerEvent("tpz_medics:server:alert")
AddEventHandler("tpz_medics:server:alert", function(unconscious)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    
    if not xPlayer.loaded() then
        return
    end

    local identifier          = xPlayer.getIdentifier()
    local characterIdentifier = xPlayer.getCharacterIdentifier()
    local fullname            = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
    local steamName           = GetPlayerName(_source)

    local ped                 = GetPlayerPed(_source)
    local coords              = GetEntityCoords(ped)

    if Config.tpz_alerts then

        for index, job in pairs (Config.Jobs) do
            exports.tpz_alerts:getAPI().createNewAlert(_source, job, Locales["UNCONSCIOUS_ALERT_DESC"])
        end

    end

    -- update on jobs only (for blips)
    TPZ.TriggerClientEventByJobs("tpz_medics:client:alert", { coords }, Config.Jobs) 

    -- tpz_notify

    if Config.Webhooks['ALERTS'].Enabled then
		local title   = "🚑`New Alert`"
		local message = string.format("The player with the online player id: `%s` and fullname as: `%s` is sent an alert requesting for medical assistance.\n\n**Description:** `%s`\n\n**Coordinates (X,Y,Z):** `%s`", _source, fullname, description, coords.x .. " " .. coords.y .. " " .. coords.z)

		TPZ.SendToDiscord(Config.Webhooks['ALERTS'].Url, title, message, Config.Webhooks['ALERTS'].Color)
	end

end)
