local NPCData = { entity = nil, duration = 0, is_reviving = false }

-----------------------------------------------------------
--[[ Base Events ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resource)
	if resource ~= GetCurrentResourceName() then
		return
	end

    if NPCData.entity then
        RemoveEntityProperly(NPCData.entity, GetHashKey(model))
    end

end)

-----------------------------------------------------------
--[[ General Events ]]--
-----------------------------------------------------------

RegisterNetEvent("tpz_medics:client:alert")
AddEventHandler("tpz_medics:client:alert", function(cb)
    local coords = cb[1]

    local blipHandle = Citizen.InvokeNative(0x45f13b7e0a15c880, -1282792512, coords.x,coords.y, coords.z, 50.0)
    SetBlipSprite(blipHandle, 1)

    Wait(Config.AlertBlipDisplayDuration * 1000)
    RemoveBlip(blipHandle)
end)

RegisterNetEvent("tpz_medics:client:start_npc_assistance")
AddEventHandler("tpz_medics:client:start_npc_assistance", function(cb)
    local playerPed = PlayerPedId()

    if NPCData.entity then
        -- in case the entity exists, we return. 
        return
    end

	local coords    = GetEntityCoords(playerPed)
	local model     = Config.MedicNPCData.Model
	
	LoadModel(model)

	local spawnPosition = GetOffsetFromEntityInWorldCoords(playerPed, 0.0, 2.0, coords.z) 

	local entity = CreatePed(model,  coords.x + 12.0, coords.y + 12.0, coords.z, 0, 1, 1, 0, 0 )
    SetModelAsNoLongerNeeded(GetHashKey(model))

	Citizen.InvokeNative(0x283978A15512B2FE, entity, true)
	ClearPedTasks(entity)

    TaskGoToEntity(entity, playerPed, -1, 1.0, 2.0, 0, 0)

    NPCData.entity = entity

    local PED_TO_NET = Citizen.InvokeNative(0x0EDEC3C276198689, entity)
    TriggerServerEvent("tpz_medics:server:send_medical_entity_net", { x = coords.x, y = coords.y, z = coords.z }, PED_TO_NET)
    
    Citizen.CreateThread(function ()
        while true do
            Wait(1000)

            NPCData.duration = NPCData.duration + 1

            -- In case reviving from the npc takes more than a minute, the npc is bugged and we delete it.
            if NPCData.duration > 60 then
                RemoveEntityProperly(NPCData.entity, GetHashKey(model))
                NPCData.duration = 0
                NPCData.entity = nil
                break
            end

            local playerPed       = PlayerPedId()
            local coords          = GetEntityCoords(playerPed)
            local entityCoords    = GetEntityCoords(NPCData.entity)
    
            local coordsDist      = vector3(coords.x, coords.y, coords.z)
            local coordsEntity    = vector3(entityCoords.x, entityCoords.y, entityCoords.z)
            local distance        = #(coordsDist - coordsEntity)
    
            if distance > 1.4 and distance <= 2.0 then
                TaskGoToEntity(NPCData.entity, PlayerPedId(), -1, 1.0, 2.0, 0, 0)
            end

            if distance <= 1.4 and not NPCData.is_reviving then

                NPCData.is_reviving = true

                ClearPedTasks(NPCData.entity)

                local AnimationData = Config.MedicNPCData

                RequestAnimDict(AnimationData.AnimationDict)
                while not HasAnimDictLoaded(AnimationData.AnimationDict) do
                    Citizen.Wait(100)
                end
            
                FreezeEntityPosition(NPCData.entity, true)

                PlayAnimation(NPCData.entity, { dict = AnimationData.AnimationDict, base = AnimationData.AnimationBody } )
                    
                Wait(2000)
                Citizen.InvokeNative(0xEAA885BA3CEA4E4A, NPCData.entity, AnimationData.AnimationDict, AnimationData.AnimationBody, 0)

                exports.tpz_core:getCoreAPI().DisplayProgressBar(2000, Locales['NPC_APPLYING_SYRINGE'])

                Citizen.InvokeNative(0xEAA885BA3CEA4E4A, NPCData.entity, AnimationData.AnimationDict, AnimationData.AnimationBody, 1)
                FreezeEntityPosition(NPCData.entity, false)
                
                TriggerEvent('tpz_core:resurrectPlayer', true)

                TriggerEvent("tpz_metabolism:setMetabolismValue", "HUNGER", "add", 100)
                TriggerEvent("tpz_metabolism:setMetabolismValue", "THIRST", "add", 100)
                TriggerEvent("tpz_metabolism:setMetabolismValue", "STRESS", "remove", 100)
                TriggerEvent("tpz_metabolism:setMetabolismValue", "ALCOHOL", "remove", 100)

                ClearPedTasks(NPCData.entity)

                Wait(2000)
                TaskGoToCoordAnyMeans(NPCData.entity, entityCoords.x + 50.0, entityCoords.y + 50.0, entityCoords.z, 2.0)

                Wait(10000)

                RemoveEntityProperly(NPCData.entity, GetHashKey(model))
                NPCData.entity      = nil
                NPCData.is_reviving = false
                NPCData.duration    = 0

                break
                
            end

        end

    end)

end)


RegisterNetEvent("tpz_medics:client:update_medical_entity_net")
AddEventHandler("tpz_medics:client:update_medical_entity_net", function(netId)

    local entity = Citizen.InvokeNative(0xBFFEAB45A9A9094A, netId)
		
	if entity and DoesEntityExist(entity) then
		
        SetEntityCanBeDamaged(entity, false)
        SetEntityInvincible(entity, true)
        SetBlockingOfNonTemporaryEvents(entity, true)
    end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------