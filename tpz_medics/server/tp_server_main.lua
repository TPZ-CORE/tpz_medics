local TPZ = exports.tpz_core:getCoreAPI()

local Players = {}
local PoisonedPlayers = {}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetPoisonedPlayers()
  return PoisonedPlayers
end

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
  if (GetCurrentResourceName() ~= resourceName) then
    return
  end

  Players = nil
  PoisonedPlayers = nil
  
end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_medics:server:request_data")
AddEventHandler("tpz_medics:server:request_data", function()
  local _source        = source
  local xPlayer        = TPZ.GetPlayer(_source)
  local charIdentifier = xPlayer.getCharacterIdentifier()

  local isPoisoned = PoisonedPlayers[charIdentifier] and true or false

  TriggerClientEvent("tpz_medics:client:update_requested_data", _source, { isPoisoned })
end)

RegisterServerEvent("tpz_medics:server:set_poisoned_state")
AddEventHandler("tpz_medics:server:set_poisoned_state", function(targetSource, cb)
  local _source = source
  
  if targetSource then 
    _source = tonumber(targetSource)
  end

  local xPlayer        = TPZ.GetPlayer(_source)
  local charIdentifier = xPlayer.getCharacterIdentifier()

  local update = false

  if PoisonedPlayers[charIdentifier] == nil and cb then 
    PoisonedPlayers[charIdentifier] = 1
    update = true
  end

  if not cb and PoisonedPlayers[charIdentifier] then 
    PoisonedPlayers[charIdentifier] = nil 
    update = true
  end

  if update then
    TriggerClientEvent("tpz_medics:client:set_poisoned_state", _source, cb)
  end

end)


RegisterServerEvent("tpz_medics:server:alert")
AddEventHandler("tpz_medics:server:alert", function(unconscious)
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    local currentJob  = xPlayer.getJob()

    if not xPlayer.loaded() then
        return
    end

    local ped    = GetPlayerPed(_source)
    local coords = GetEntityCoords(ped)

    local availableMedics = false

    local isMedic, count = false, 0 

    for index, job in pairs (Config.Jobs) do

        local jobList = TPZ.GetJobPlayers(job)
        
        if jobList.count > 0 then
            availableMedics = true
        
            count = count + jobList.count
        end

        if job == currentJob then 
            isMedic = true
        end

        if not Config.tp_pigeon_notes then

            if jobList.count > 0 then

                for _, player in pairs (jobList.players) do
    
                    player.source = tonumber(player.source)

                    TriggerClientEvent("tpz_notify:sendNotification", player.source, Locales["ALERT_TITLE"], Locales["ALERT_DESCRIPTION"], "medical", "info", Config.NotifyAlertDuration, "left")
                end

                -- update on jobs only (for blips)
                TPZ.TriggerClientEventByJobs("tpz_medics:client:alert", { coords }, Config.Jobs) 

            end

        else
            exports.tp_pigeon_notes:createNewAlert(_source, job, Locales["UNCONSCIOUS_ALERT_DESC"], 0)
        end

    end

    -- If the one who alerted was a medic and was the only medic available, we set as false, in order for the 
    -- npc to provide assistance, otherwise the medic will not be assisted without this.
    if count == 1 and isMedic then 
        availableMedics = false
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

