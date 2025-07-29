local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_medics:server:alert")
AddEventHandler("tpz_medics:server:alert", function(unconscious)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    
    if not xPlayer.loaded() then
        return
    end

    local ped    = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)

    -- update on jobs only (for blips)
    TPZ.TriggerClientEventByJobs("tpz_medics:client:alert", { coords }, Config.Jobs) 

    local availableMedics = false

    for index, job in pairs (Config.Jobs) do

        local jobList = TPZ.GetJobPlayers(job)
        
        if jobList.count > 0 then
            availableMedics = true
        end

        if not Config.tpz_alerts then

            if jobList.count > 0 then

                for _, player in pairs (jobList.players) do
    
                    player.source = tonumber(player.source)

                    TriggerClientEvent("tpz_notify:sendNotification", player.source, Locales["ALERT_TITLE"], Locales["ALERT_DESCRIPTION"], "medical", "info", Config.NotifyAlertDuration, "left")
                end

            end

        else
            exports.tpz_alerts:getAPI().createNewAlert(_source, job, Locales["UNCONSCIOUS_ALERT_DESC"])
        end

    end

    if not availableMedics and Config.MedicNPCData.Enabled then
        -- spawn npc
        TriggerClientEvent("tpz_medics:client:start_npc_assistance", _source)

        if Config.MedicNPCData.ReviveCost.Amount > 0 then
            xPlayer.removeAccount(Config.MedicNPCData.ReviveCost.Account, Config.MedicNPCData.ReviveCost.Amount)
        end
        
    end

    if Config.Webhooks['ALERTS'].Enabled then

        local identifier          = xPlayer.getIdentifier()
        local characterIdentifier = xPlayer.getCharacterIdentifier()
        local fullname            = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
        local steamName           = GetPlayerName(_source)

		local title               = "🚑`New Alert`"
		local message             = string.format("The player with the online player id: `%s` and fullname as: `%s` is sent an alert requesting for medical assistance.\n\n**Coordinates (X,Y,Z):** `%s`", _source, fullname, coords.x .. " " .. coords.y .. " " .. coords.z)

		TPZ.SendToDiscord(Config.Webhooks['ALERTS'].Url, title, message, Config.Webhooks['ALERTS'].Color)
	end

end)


RegisterServerEvent("tpz_medics:server:send_medical_entity_net")
AddEventHandler("tpz_medics:server:send_medical_entity_net", function(coords, netId)
    coords = vector3(coords.x, coords.y, coords.z)
    TPZ.TriggerClientEventToCoordsOnly("tpz_medics:client:update_medical_entity_net", netId, coords, 150.0)
end)