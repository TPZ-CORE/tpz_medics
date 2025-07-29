
--[[-------------------------------------------------------
 Handlers
]]---------------------------------------------------------

AddEventHandler("onResourceStop", function(resourceName)
	
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    for i, v in pairs(Config.Locations) do
        if v.BlipHandle then
            RemoveBlip(v.BlipHandle)
        end

        if v.NPC then
            DeleteEntity(v.NPC)
            DeletePed(v.NPC)
            SetEntityAsNoLongerNeeded(v.NPC)
        end
    end

    ClearPedTasks(PlayerPedId())

end)


--[[-------------------------------------------------------
 Blips Management
]]---------------------------------------------------------

Citizen.CreateThread(function ()
    for index, blip in pairs (Config.Locations) do

        if blip.BlipData and blip.BlipData.Enabled then

            local blipHandle = N_0x554d9d53f696d002(1664425300, blip.Coords.x, blip.Coords.y, blip.Coords.z)
    
            SetBlipSprite(blipHandle, blip.BlipData.Sprite, 1)
            SetBlipScale(blipHandle, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blipHandle, blip.Name)

            Config.Locations[index].BlipHandle = blipHandle

        end

    end
end)

--[[-------------------------------------------------------
 NPC Management
]]---------------------------------------------------------

LoadModel = function(inputModel)
    local model = joaat(inputModel)
 
    RequestModel(model)
 
    while not HasModelLoaded(model) do RequestModel(model)
        Citizen.Wait(10)
    end
 end

SpawnNPC = function(index)
    local v = Config.Locations[index]

    LoadModel(v.Model)

    local npc = CreatePed(v.Model, v.Coords.x, v.Coords.y, v.Coords.z, v.Coords.h, false, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, npc, true)
    SetEntityCanBeDamaged(npc, false)
    SetEntityInvincible(npc, true)
    Wait(500)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    Config.Locations[index].NPC = npc
end

RemoveEntityProperly = function(entity, objectHash)
	DeleteEntity(entity)
	DeletePed(entity)
	SetEntityAsNoLongerNeeded( entity )

	if objectHash then
		SetModelAsNoLongerNeeded(objectHash)
	end
end

--[[-------------------------------------------------------
 General
]]---------------------------------------------------------


PlayAnimation = function(ped, anim)
	if not DoesAnimDictExist(anim.dict) then
		return false
	end

	RequestAnimDict(anim.dict)

	while not HasAnimDictLoaded(anim.dict) do
		Wait(0)
	end

	TaskPlayAnim(ped, anim.dict, anim.base, 1.0, 1.0, -1, 1, 0.0, false, false, false, '', false)

	RemoveAnimDict(anim.dict)

	return true
end

DrawText3D = function(x, y, z, text)
	local onScreen,_x,_y=GetScreenCoordFromWorldCoord(x, y, z)
	local px,py,pz=table.unpack(GetGameplayCamCoord())  
	local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
	local str = CreateVarString(10, "LITERAL_STRING", text, Citizen.ResultAsLong())
	if onScreen then
	  SetTextScale(0.30, 0.30)
	  SetTextFontForCurrentCommand(1)
	  SetTextColor(255, 255, 255, 215)
	  SetTextCentre(1)
	  DisplayText(str,_x,_y)
	  local factor = (string.len(text)) / 225
	  DrawSprite("feeds", "hud_menu_4a", _x, _y+0.0125,0.015+ factor, 0.03, 0.1, 35, 35, 35, 190, 0)
	end
end
