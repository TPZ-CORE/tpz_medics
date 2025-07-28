local AlertArchives = {}

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:update_alerts")
AddEventHandler("tpz_medics:client:update_alerts", function(cb)
    local actionType, data = cb.actionType, cb.data

    if actionType == "REQUEST" then
        AlertArchives = data[1]

    elseif actionType == "INSERT" then
        table.insert(AlertArchives, data)

    elseif actionType == "SET_SIGNED" then
        
        for index, archive in pairs (AlertArchives) do

            if archive.date == data[2] then
                archive.signed = data[1]
            end

        end

    end

end)

-----------------------------------------------------------
--[[ Commands ]]--
-----------------------------------------------------------

RegisterCommand(Config.CommandToReadAlerts, function(source, args, rawCommand)
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