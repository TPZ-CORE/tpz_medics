local TPZ = exports.tpz_core:getCoreAPI()

local AlertArchives = {}

-----------------------------------------------------------
--[[ Base Events  ]]--
-----------------------------------------------------------

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end

    AlertArchives = nil
end)
