local PlayerData = { 
    IsBusy           = false, 
    Job              = nil, 
    ClosestDoctorNPC = nil, 
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

-- Requests when devmode set to false and character is selected.
AddEventHandler("tpz_core:isPlayerReady", function()

    Wait(2000)
    
    local data = exports.tpz_core:getCoreAPI().GetPlayerClientData()

    if data == nil then
        return
    end

    TriggerServerEvent("tpz_medics:server:request_alerts")

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

        TriggerServerEvent("tpz_medics:server:request_alerts")
    
        PlayerData.Job = data.job
        PlayerData.Loaded = true
    end)

end

-- Updates the player job.
RegisterNetEvent("tpz_core:getPlayerJob")
AddEventHandler("tpz_core:getPlayerJob", function(data)
    PlayerData.Job = data.job

    local isPermitted = false

    for index, job in pairs (Config.Jobs) do

        if job == PlayerData.Job then
            isPermitted = true
        end

    end

    if not isPermitted then
        return
    end

    TriggerServerEvent("tpz_medics:server:request_alerts")

end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

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
