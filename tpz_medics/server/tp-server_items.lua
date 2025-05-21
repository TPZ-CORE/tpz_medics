local TPZ    = exports.tpz_core:getCoreAPI()
local TPZInv = exports.tpz_inventory:getInventoryAPI()

-----------------------------------------------------------
--[[ Local Functions  ]]--
-----------------------------------------------------------

local HasRequiredJob = function(currentJob, jobs)

	if not jobs then
		return true
	end

	for index, job in pairs (jobs) do

		if job == currentJob then

			return true
		end

	end

	return false

end

-----------------------------------------------------------
--[[ Items Registration  ]]--
-----------------------------------------------------------

-- @param source     - returns the player source.
-- @param item       - returns the item name.
-- @param itemId     - returns the itemId (itemId exists only for non-stackable items) otherwise it will return as "0"
-- @param id         - returns the item id which is located in the tpz_items table.
-- @param label      - returns the item label name.
-- @param weight     - returns the item weight.
-- @param durability - returns the durability (exists only for non-stackable items).
-- @param metadata   - returns the metadata that you have created on the given item.

Citizen.CreateThread(function ()
	
	for item, itemData in pairs (Config.UsableItems) do

		TPZInv.registerUsableItem(item, GetCurrentResourceName(), function(data)
			local _source = data.source

			local xPlayer = TPZ.GetPlayer(_source)
		
			local hasRequiredJob = HasRequiredJob(xPlayer.getJob(), itemData.Jobs) 

			if hasRequiredJob then

				TriggerClientEvent('tpz_medics:client:use', _source, item )
				TPZInv.closeInventory(_source)
			else
				SendNotification(_source, Locales['NOT_REQUIRED_JOB'])
			end

		end)

	end

	
end)

-----------------------------------------------------------
--[[ Events ]]--
-----------------------------------------------------------

RegisterServerEvent("tpz_medics:server:use")
AddEventHandler("tpz_medics:server:use", function(itemName, targetSource)
  local _source  = source
  local _tsource = tonumber(targetSource)

  if targetSource == nil then
    _tsource = _source
  end

  local xPlayer = TPZ.GetPlayer(_source) -- We must get xPlayer in order to remove the used item.
  local tPlayer = TPZ.GetPlayer(_tsource)

  if not tPlayer.loaded() then
    return
  end

  local ItemData = Config.UsableItems[itemName]

  if ItemData == nil then
	print("There was an attempt using on tpz_medics an unknown item data: Player ID: %s | Attempted Item: %s", _source, itemName)
	return
  end

  xPlayer.removeItem(itemName, 1)

  if ItemData.Type == 'CURE_ITEM' then

	TriggerClientEvent("tpz_metabolism:setMetabolismCoreValue", "HEALTH", _tsource, ItemData.InnerCoreHealth, ItemData.InnerCoreHealthGold, ItemData.OuterCoreHealthGold )
	TriggerClientEvent("tpz_metabolism:setMetabolismCoreValue", "STAMINA", _tsource, ItemData.InnerCoreStamina, ItemData.InnerCoreStaminaGold, ItemData.OuterCoreStaminaGold )

	local metabolismData = ItemData.Metabolism

	if metabolismData.Hunger.Value > 0 then
		TriggerClientEvent("tpz_metabolism:setMetabolismValue", _tsource, "HUNGER", metabolismData.Hunger.Type, metabolismData.Hunger.Value)
	end

	if metabolismData.Thirst.Value > 0 then
		TriggerClientEvent("tpz_metabolism:setMetabolismValue", _tsource, "THIRST", metabolismData.Thirst.Type, metabolismData.Thirst.Value)
	end

	if metabolismData.Stress.Value > 0 then
		TriggerClientEvent("tpz_metabolism:setMetabolismValue", _tsource, "STRESS", metabolismData.Stress.Type, metabolismData.Stress.Value)
	end

  elseif ItemData.Type == 'REVIVE_ITEM' then
	TriggerClientEvent('tpz_core:resurrectPlayer', _tsource, true)
  end

end)