
-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:action")
AddEventHandler("tpz_medics:client:action", function(locationIndex, actionType)
    local player     = PlayerPedId()
    local PlayerData = GetPlayerData()

    TaskStartScenarioInPlace(PlayerData.ClosestDoctorNPC, GetHashKey("WORLD_HUMAN_CROUCH_INSPECT"), -1, true, false, false, false)

    exports.tpz_core:getCoreAPI().DisplayProgressBar(Config.NPCApplyDuration[actionType].ActionDuration * 1000, Locales[actionType] )

    ClearPedTasks(PlayerData.ClosestDoctorNPC)

    if actionType == 'FULL' then
            
        Wait(4000)
    
        PlayAnimation(PlayerData.ClosestDoctorNPC, { dict = "mech_revive@unapproved", base = "revive"})

        exports.tpz_core:getCoreAPI().DisplayProgressBar(3000, Locales['APPLYING'] )

        StopAnimTask(PlayerData.ClosestDoctorNPC, "mech_revive@unapproved", "revive", 1.0)
        TriggerServerEvent('tpz_medics:server:action_full', true)
    end

    TaskStandStill(player, 1)
    PlayerData.IsBusy = false
end)