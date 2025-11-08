local PlayerData = { 
    IsBusy           = false, 
    Job              = nil, 
    ClosestDoctorNPC = nil, 
    IsPoisoned       = false,
    HasEffect        = false,
    DamageCooldown   = 0,
    EffectCooldown   = 0,
    Loaded           = false,
}

-----------------------------------------------------------
--[[ Functions ]]--
-----------------------------------------------------------

function GetPlayerData()
    return PlayerData
end

-----------------------------------------------------------
--[[ Base Events & Threads ]]--
-----------------------------------------------------------


AddEventHandler('onResourceStop', function(resource)

	if resource ~= GetCurrentResourceName() then
		return
	end
    
    if PlayerData.IsPoisoned then 

        if Config.SnakePoisons.ScreenEffect ~= false then 
            AnimpostfxStop(Config.SnakePoisons.ScreenEffect)
        end

    end

end)

-- Requests when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()

    Wait(2000)
    
    local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

    if data == nil then
        return
    end

    TriggerServerEvent("tpz_medics:server:request_data")

    PlayerData.Job = data.job
    PlayerData.Loaded = true
end)

if Config.DevMode then

    Citizen.CreateThread(function ()
        
        Wait(2000)

        local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

        if data == nil then
            return
        end

        TriggerServerEvent("tpz_medics:server:request_data")

        PlayerData.Job = data.job
        PlayerData.Loaded = true
    end)

end

RegisterNetEvent("tpz_core:isPlayerRespawned")
AddEventHandler("tpz_core:isPlayerRespawned", function()

    if PlayerData.IsPoisoned then 
        TriggerServerEvent("tpz_medics:server:set_poisoned_state", nil, false)
    end

end)

-- Updates the player job.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job = data.job
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:update_requested_data")
AddEventHandler("tpz_medics:client:update_requested_data", function(data)
    PlayerData.IsPoisoned = data[1]

    if data[1] == true then 
        TriggerEvent("tpz_medics:client:run_poison_tasks")
    end

end)

RegisterNetEvent("tpz_medics:client:set_poisoned_state")
AddEventHandler("tpz_medics:client:set_poisoned_state", function(cb)
    PlayerData.HasEffect = false 

    if PlayerData.IsPoisoned and not cb then 

        if Config.SnakePoisons.ScreenEffect ~= false then 
            AnimpostfxStop(Config.SnakePoisons.ScreenEffect)
        end

    end

    if not PlayerData.IsPoisoned and cb then 
        TriggerEvent("tpz_medics:client:run_poison_tasks")

        if Config.SnakePoisons.ScreenEffect ~= false then 
            AnimpostfxPlay(Config.SnakePoisons.ScreenEffect)
            AddEntityToEntityMaskWithIntensity(player, 2, 1.0)

            PlayerData.HasEffect = true
        end

    end

    PlayerData.IsPoisoned     = cb
    PlayerData.DamageCooldown = 0
    PlayerData.EffectCooldown = 0
end)


RegisterNetEvent("tpz_medics:client:setBusy")
AddEventHandler("tpz_medics:client:setBusy", function(cb)
    PlayerData.IsBusy = cb
end)

---------------------------------------------------------------
-- Threads
---------------------------------------------------------------

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(0)

        local sleep  = true

        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local isDead = IsEntityDead(player)

        if PlayerData.Loaded and not PlayerData.IsBusy then

            for index, officeConfig in pairs(Config.Locations) do

                local coordsDist  = vector3(coords.x, coords.y, coords.z)
                local coordsStore = vector3(officeConfig.Coords.x, officeConfig.Coords.y, officeConfig.Coords.z)
                local distance    = #(coordsDist - coordsStore)

                if ( distance > Config.NPCRenderingDistance ) then
                    
                    if Config.Locations[index].NPC then
                        RemoveEntityProperly(Config.Locations[index].NPC, joaat(Config.Locations[index].Model))
                        Config.Locations[index].NPC = nil
                    end

                end

                if distance <= Config.NPCRenderingDistance and not Config.Locations[index].NPC then
                    SpawnNPC(index)
                end

                if distance <= officeConfig.DrawTextRenderDistance then
                    sleep = false

                    DrawText3D(officeConfig.Coords.x, officeConfig.Coords.y, officeConfig.Coords.z + 1.0, officeConfig.DrawText)
                    DrawText3D(officeConfig.Coords.x, officeConfig.Coords.y, officeConfig.Coords.z + 0.92, officeConfig.DrawText2)
                
                    PlayerData.ClosestDoctorNPC = officeConfig.NPC

                    if IsControlPressed(2, Config.Keys['WOUNDS']) then 

                        if distance <= officeConfig.ActionDistance then

                            if not isDead then
                                PlayerData.IsBusy = true
                                TaskStandStill(player, -1)
    
                                TriggerServerEvent("tpz_medics:server:action", index, "WOUNDS")
                           
                            else
                                SendNotification(nil, Locales['DEAD'])
                            end
                        else

                            SendNotification(nil, Locales['NOT_CLOSE_FOR_ACTION'])
                        end

                    end

                    if IsControlPressed(2, Config.Keys['FULL']) then 

                        if distance <= officeConfig.ActionDistance then

                            if isDead then
                                PlayerData.IsBusy = true
                                TaskStandStill(player, -1)
    
                                TriggerServerEvent("tpz_medics:server:action", index, "FULL")

                            else
                                SendNotification(nil, Locales['NOT_DEAD'])
                            end
                        else

                            SendNotification(nil, Locales['NOT_CLOSE_FOR_ACTION'])
                        end

                    end

                
                end

                
            end
        end

        if sleep then
            Citizen.Wait(1000)
        end
    end
end)


if Config.SnakePoisons.Enabled then 

    Citizen.CreateThread(function()

        while true do

            local sleep = 1
            local size = GetNumberOfEvents(0)   

            if PlayerData.IsPoisoned then
                sleep = 2000
                goto END
            end
            
            if size > 0 then 
                for i = 0, size - 1 do
                    local eventAtIndex = GetEventAtIndex(0, i)

                    if eventAtIndex == GetHashKey("EVENT_ENTITY_DAMAGED") then 

                        local eventDataSize = 9
                        local eventDataStruct = DataView.ArrayBuffer(72)
                        eventDataStruct:SetInt32(0 ,0)
                        eventDataStruct:SetInt32(8 ,0) 
                        eventDataStruct:SetInt32(16 ,0)

                        local is_data_exists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA,0,i,eventDataStruct:Buffer(),eventDataSize)
                        if is_data_exists then

                            if PlayerPedId() == eventDataStruct:GetInt32(0) then
                                local weaponhash = eventDataStruct:GetInt32(16)

                                if -655377385 == weaponhash then 

                                    if not PlayerData.IsPoisoned and not IsPedOnMount(PlayerPedId()) then 
                                        TriggerServerEvent("tpz_medics:server:set_poisoned_state", nil, true)
                                    end

                                    Wait(2000)

                                end

                            end

                        end

                    end
    
                end

            end

            ::END::
            Wait(sleep)

        end

    end)

end


AddEventHandler("tpz_medics:client:run_poison_tasks", function()

    Citizen.CreateThread(function()
    
        while PlayerData.IsPoisoned do 
    
            Wait(1000)

            local player = PlayerPedId()

            if Config.SnakePoisons.DamageValue > 0 then 

                PlayerData.DamageCooldown = PlayerData.DamageCooldown + 1

                if PlayerData.DamageCooldown >= Config.SnakePoisons.DamageEvery then

                    if Config.SnakePoisons.PlayAnimation.enabled then 

                        exports.tpz_core:getCoreAPI().PlayAnimation(player, Config.SnakePoisons.PlayAnimation)

                    end

                    local health    = GetEntityHealth(player)
                    local removedHealthValue = health - Config.SnakePoisons.DamageValue

                    if removedHealthValue <= 0 and Config.SnakePoisons.LethalDamage then

                        removedHealthValue = 0
                        Citizen.InvokeNative(0x697157CED63F18D4, player, 500000, false, true, true) -- ApplyDamageToPed
                    end
                    
                    PlayPain(player, 9, 1, true, true)
                    SetEntityHealth(player, removedHealthValue)

                    PlayerData.DamageCooldown = 0

                end

            end

            if Config.SnakePoisons.ScreenEffect ~= false then 

                PlayerData.EffectCooldown = PlayerData.EffectCooldown + 1
 
                if PlayerData.EffectCooldown >= Config.SnakePoisons.ScreenEffectStop and PlayerData.HasEffect then 
                    AnimpostfxStop(Config.SnakePoisons.ScreenEffect)
                    PlayerData.HasEffect = false
                    PlayerData.EffectCooldown = 0
                end

                if PlayerData.EffectCooldown >= Config.SnakePoisons.ScreenEffectEvery and not PlayerData.HasEffect then
                    AnimpostfxPlay(Config.SnakePoisons.ScreenEffect)
                    AddEntityToEntityMaskWithIntensity(player, 2, 1.0)

                    PlayerData.EffectCooldown = 0
                end

            end

        end

    end)
end)
