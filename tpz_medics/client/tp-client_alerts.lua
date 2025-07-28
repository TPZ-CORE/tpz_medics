local AlertArchives = {}

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:update_alerts")
AddEventHandler("tpz_medics:client:update_alerts", function(cb)
    local actionType, data = cb.actionType, cb.data

    if actionType == "REQUEST" then
        AlertArchives = data[1]
    end

end)