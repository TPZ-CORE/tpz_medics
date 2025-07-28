local AlertArchives = {}
local HasNUIActive  = false

-----------------------------------------------------------
--[[ Local Functions ]]--
-----------------------------------------------------------

local SendNUINotification = function(message, notificationType)

    local PlayerData = GetPlayerData()

    if PlayerData.HasNUIActive then
		local notify_color = Config.NotificationColors[notificationType]
		SendNUIMessage({ action = 'sendNotification', notification_data = {message = message, type = notificationType, color = notify_color} })
	end

end

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:update_alerts")
AddEventHandler("tpz_medics:client:update_alerts", function(cb)
    local actionType, data = cb.actionType, cb.data

    if actionType == "REQUEST" then
        AlertArchives = data[1]

    elseif actionType == "INSERT" then

        if Config.PigeonAlerts.Enabled then
            table.insert(AlertArchives, data)
        end
        -- create blip
        -- Wait()
        -- RemoveBlip

    elseif actionType == "SET_SIGNED" then
        
        for index, archive in pairs (AlertArchives) do

            -- @return data[1] : fullname of signed player.
            -- @return data[2] : the target archive by its registration date. 
            if archive.date == data[2] then
                archive.signed = data[1]
            end

        end

    end

end)


RegisterNetEvent("tpz_medics:client:alerts_nui_notify")
AddEventHandler("tpz_medics:client:alerts_nui_notify", function(message, actionType)
    SendNUINotification(message, actionType)
end)

-----------------------------------------------------------
--[[ Commands ]]--
-----------------------------------------------------------

if Config.PigeonAlerts.Enabled then

    RegisterCommand(Config.PigeonAlerts.CommandToReadPigeonAlerts, function(source, args, rawCommand)
        local PlayerData = GetPlayerData()

        if not PlayerData.Loaded then
            return
        end

        local isPermitted = false

        for index, job in pairs (Config.Jobs) do

            if job == PlayerData.Job then
                isPermitted = true
            end

        end

        if isPermitted then

            --OpenMedicalAlertArchives()

        else
            SendNotification(nil, Locales["NOT_REQUIRED_JOB"], "error")
        end

    end)

end