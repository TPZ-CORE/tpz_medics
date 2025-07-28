local TPZ = exports.tpz_core:getCoreAPI()

local Players = {}

-----------------------------------------------------------
--[[ Functions  ]]--
-----------------------------------------------------------

local function GetTableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end
-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    Players = nil
end)

-----------------------------------------------------------
--[[ Events  ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_medics:server:action")
AddEventHandler("tpz_medics:server:action", function(locationIndex, actionType)
  local _source        = source
  local xPlayer        = TPZ.GetPlayer(_source)
  local charIdentifier = xPlayer.getCharacterIdentifier()

  Wait(250, 500) -- safety wait.

  if Players[charIdentifier] and Players[charIdentifier][actionType] and Players[charIdentifier][actionType].cooldown ~= 0 then -- Cooldown
    SendNotification(_source, string.format(Locales['ACTION_ON_COOLDOWN'], Players[charIdentifier][actionType]))
    return
  end

  local ActionData = Config.Locations[locationIndex]

  local money     = xPlayer.getAccount(0)
  local cost      = 0

  if actionType == 'FULL' then
    cost = ActionData.ReviveCost

  elseif actionType == 'WOUNDS' then
    cost = ActionData.HealCost
  end

  if money < cost then
    SendNotification(_source, Locales['NOT_ENOUGH_MONEY'])
    TriggerClientEvent("tpz_medics:client:setBusy", _source, false)
    return
  end

  if Players[charIdentifier] == nil then
    Players[charIdentifier] = {}

    Players[charIdentifier]['WOUNDS'] = { cooldown = 0, action = 'WOUNDS'} -- WOUNDS
    Players[charIdentifier]['FULL']   = { cooldown = 0, action = 'FULL'} -- FULL (REVIVE)
  end

  xPlayer.removeAccount(0, cost)

  -- We perform the healing here instead of client.
  if actionType == 'WOUNDS' then

    TriggerClientEvent('tpz_core:healPlayer', _source)

    -- tpz_metabolism.
    TriggerClientEvent("tpz_metabolism:setMetabolismValue", _source, "HUNGER", "add", 100)
    TriggerClientEvent("tpz_metabolism:setMetabolismValue", _source, "THIRST", "add", 100)

    TriggerClientEvent("tpz_metabolism:setMetabolismValue", _source, "STRESS", "remove", 100)
    TriggerClientEvent("tpz_metabolism:setMetabolismValue", _source, "ALCOHOL", "remove", 100)

    
    Players[charIdentifier][actionType].cooldown = Config.NPCApplyDuration[actionType].Cooldown

  end

  TriggerClientEvent("tpz_medics:client:action", _source, locationIndex, actionType)

end)

RegisterServerEvent("tpz_medics:server:action_full")
AddEventHandler("tpz_medics:server:action_full", function(id)
  local _source        = source
  local _tsource       = tonumber(id)

  if id == nil then
    _tsource = _source
  end

  local tPlayer        = TPZ.GetPlayer(_tsource)
  local charIdentifier = tPlayer.getCharacterIdentifier()

  if not tPlayer.loaded() then
    return
  end

  if Players[charIdentifier] and Players[charIdentifier]['FULL'] and Players[charIdentifier]['FULL'].cooldown ~= 0 then -- Cooldown
    if id ~= nil then
      SendNotification(_source, string.format(Locales['TARGET_ACTION_ON_COOLDOWN'], Players[charIdentifier]['FULL']))
    end

    SendNotification(_tsource, string.format(Locales['ACTION_ON_COOLDOWN'], Players[charIdentifier]['FULL']))
    return
  end

  Players[charIdentifier]['FULL'].cooldown = Config.NPCApplyDuration['FULL'].Cooldown

  TriggerClientEvent('tpz_core:resurrectPlayer', _tsource, true)
end)

RegisterServerEvent("tpz_medics:server:alert")
AddEventHandler("tpz_medics:server:alert", function()
    local _source = source
    local xPlayer = TPZ.GetPlayer(_source)
    
    if not xPlayer.loaded() then
        return
    end

    local identifier          = xPlayer.getIdentifier()
    local characterIdentifier = xPlayer.getCharacterIdentifier()
    local fullname            = xPlayer.getFirstName() .. " " .. xPlayer.getLastName()
    local steamName           = GetPlayerName(_source)

    local currentTime = os.date("*t") -- Get current date and time as a table
    -- Modify only the year
    currentTime.year = Config.Year

    -- Get the new timestamp with modified year
    local modifiedTimestamp = os.time(currentTime)
    local formatted_date    = os.date("%d/%m/%Y %H:%M:%S", modifiedTimestamp)

    local ped               = GetPlayerPed(_source)
    local playerCoords      = GetEntityCoords(ped)
            
    table.insert(AlertArchives, { 
        fullname = fullname,
        source   = _source,
        coords   = playerCoords,
        signed   = 0,
        date     = formatted_date, 
    } 

    if Config.Webhooks['ALERTS'].Enabled then
		local title   = "🚑`New Unconsious Alert`"
		local message = string.format("The player with the online player id: `%s` is unconsious and sent an alert asking for help.", _source)
		
		TPZ.SendToDiscord(Config.Webhooks['ALERTS'].Url, title, message, Config.Webhooks['ALERTS'].Color)
	end

end)

-----------------------------------------------------------
--[[ Threads  ]]--
-----------------------------------------------------------

Citizen.CreateThread(function()

  while true do

    Wait(1000)

    if GetTableLength(Players) > 0 then

      for index, player in pairs (Players) do

        for type, actionValue in pairs (player) do

            if actionValue.cooldown > 0 then

                actionValue.cooldown = actionValue.cooldown - 1

                if actionValue.cooldown <= 0 then
                    actionValue.cooldown = 0
                end

            end

          end

        end

    end

  end

end)