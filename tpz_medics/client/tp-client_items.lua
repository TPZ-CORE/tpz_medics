local TPZ = exports.tpz_core:getCoreAPI()

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent('tpz_medics:client:use_antipoison')
AddEventHandler('tpz_medics:client:use_antipoison', function(itemName)
	local player = PlayerPedId()
	local coords = GetEntityCoords(player)

    LoadModel('s_rc_poisonedwater01x')

    local prop      = CreateObject(GetHashKey('s_rc_poisonedwater01x'), coords.x, coords.y, coords.z + 0.2, true, true, false, false, true)
    local boneIndex = GetEntityBoneIndexByName(player, 'MH_L_HandSide')

    local anim_data = { 
        dict = "mech_inventory@item@fallbacks@large_drink@left_handed", 
        name = "use_quick_left_hand", 
        blendInSpeed = 1.0, 
        blendOutSpeed = 1.0, 
        duration = -1, 
        flag = 24, 
        playbackRate = 0 
    }

    exports.tpz_core:getCoreAPI().PlayAnimation(player, anim_data)

    AttachEntityToEntity(prop, player, boneIndex, 0.03, -0.01, -0.03, 20.0, -0.0, 0.0, true, true, false, true, 1, true)

    TriggerServerEvent("tpz_medics:server:set_poisoned_state", nil, false)

    Wait(5000)

    RemoveEntityProperly(prop, GetHashKey('s_rc_poisonedwater01x') )
    ClearPedSecondaryTask(player)
end)

RegisterNetEvent('tpz_medics:client:use')
AddEventHandler('tpz_medics:client:use', function(itemName)
    local player = PlayerPedId()

    -- In case an item returns null, most probably it was an injection attempt.
    -- An item name was called which does not exist on the medical items.
    if Config.UsableItems[itemName] == nil then
        return
    end

    -- We clear all the ped tasks and remove carried weapon.
    SetCurrentPedWeapon(player, GetHashKey("WEAPON_UNARMED"), true, 0, false, false)
    ClearPedTasksImmediately(player)

    local itemData = Config.UsableItems[itemName]
    local animData = itemData.ApplyAnimation

    local finished   = false

    local isPermitted, wait = false, true

    local foundTargetSourceId = 0
    local notifyWarning       = nil

    -- We check if the specified item requires a player target to be used.
    if itemData.RequiredPlayerTarget then

        local nearestPlayers = TPZ.GetNearestPlayers(Config.CheckNearestPlayersForRevive)

        if TPZ.GetTableLength(nearestPlayers) > 0 then

            local targetPlayer    = nearestPlayers[1] -- We get the first result.
            local targetPlayerPed = GetPlayerPed(targetPlayer)

            foundTargetSourceId   = targetPlayer
            
            if itemData.RequiredUnconsiousPlayerTarget then
                    
                if IsEntityDead(targetPlayerPed) then
                    isPermitted = true
                    wait        = false
                else

                    notifyWarning = Locales['NO_PLAYER_DEAD']
                    isPermitted = false
                    wait        = false
                end

            else
                isPermitted = true
                wait        = false
            end

        else

            notifyWarning = Locales['NO_PLAYER_NEARBY']

            isPermitted = false
            wait        = false
        end

    else
        isPermitted = true
        wait        = false
    end

    while wait do
        Wait(50)
    end

    if not isPermitted then
        SendNotification(nil, notifyWarning)
        return
    end

    FreezeEntityPosition(player, true)

    if animData.Type == "SCENARIO" then
        TaskStartScenarioInPlace(player, GetHashKey(animData.Dict), -1)

    elseif animData.Type == "ANIMATION" then
        PlayAnimation(player, { dict = animData.Dict, base = animData.Base})

        if not itemData.ApplyingDisplayText then
            Wait(itemData.ApplyDuration)
        end
    end

    if itemData.ApplyingDisplayText and itemData.ApplyDuration > 0 then
        exports.tpz_core:getCoreAPI().DisplayProgressBar(itemData.ApplyDuration, animData.ApplyingDisplayText )
        -- In case you don't use our progressbar export, you have to add a wait based on @itemData.ApplyDuration
    end

    -- Clear animation and ped tasks.
	FreezeEntityPosition(player, false)
    ClearPedTasks(player)

    TriggerServerEvent("tpz_medics:server:use", itemName, foundTargetSourceId)
end)

