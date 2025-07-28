Config = {}

Config.DevMode = false

Config.Keys = { ['WOUNDS'] = 0xD9D0E1C0, ['FULL'] = 0x760A9C6F }

---------------------------------------------------------------
--[[ General Settings ]]--
---------------------------------------------------------------

-- NPC Rendering Distance which is deleting the npc when being away from the locations.
Config.NPCRenderingDistance = 30.0

-- How long should it take for the npc to perform an action based on the type?
-- @param ActionDuration (Time in seconds) : The action (animation / scenario) duration.
-- @param Cooldown       (Time in minutes) : How long should it take to perform such an action again.
Config.NPCApplyDuration = { 
    ['WOUNDS'] = { ActionDuration = 5,  Cooldown = 30 },
    ['FULL']   = { ActionDuration = 10, Cooldown = 30 },
}

Config.CheckNearestPlayersForRevive = 1.5 -- The distance to check when using a revive item near players who are unconscious.

Config.NotifyAlertDuration = 5 -- Time in seconds. 

-- The jobs to receive the alert notifications and also check for players availability. 
Config.Jobs = { "medic" } 

-- @MedicNPCData is an extra feature to allow an NPC to revive an unconscious player when there are no
-- players with @Config.Jobs available on the server.
Config.MedicNPCData = {
    Enabled       = true,

    Model         = "CS_DrMalcolmMacIntosh",
    AnimationDict = "mech_revive@unapproved",
    AnimationBody = "revive",

    -- @param account : 0: CASH, 1: GOLD, 2: BLACK MONEY
    ReviveCost    = { account = 0, amount = 5 },
}

-----------------------------------------------------------
--[[ Usable Items  ]]--
-----------------------------------------------------------

-- For metabolism modifications, it supports only tpz_metabolism by default.
Config.UsableItems = {
    ['bandage'] = {

        Type = 'CURE_ITEM', -- CURE_ITEM, REVIVE_ITEM (Available Types).

        ApplyDuration = 10000, -- Time in milliseconds

        ApplyAnimation = {
            Type = 'SCENARIO', -- SCENARIO, ANIMATION (Available Types).
            Dict = 'WORLD_HUMAN_CROUCH_INSPECT', -- Animation Dict or Scenario Name.
            Base = nil, -- Animation Base Name if type is ANIMATION.
            ApplyingDisplayText = "Applying bandage...",  -- Set to nil to prevent displaying progress bar text and its delay system.
            AppliedDisplayText = "Bandage applied, you stopped bleeding.",
        },

        Metabolism = {
            Hunger = { Type = "add",    Value = 0  },
            Thirst = { Type = "remove", Value = 0  },

            -- Stress Types : "add", "remove" (Keep in mind, "add", adds more stress to the player, not actual removing).
            Stress = { Type = "remove", Value = 30 },
        },

        InnerCoreStamina = 0,
        InnerCoreStaminaGold = 0.0,
        OuterCoreStaminaGold = 0.0,

        InnerCoreHealth = 200,
        InnerCoreHealthGold = 0.0,
        OuterCoreHealthGold = 0.0,

        -- Set to true if this item is usable only for player targets.
        RequiredPlayerTarget = false,

        -- Set to true if you want the player target to be unconsious in order to use this item.
        -- @RequiredPlayerTarget must be true.
        RequiredUnconsiousPlayerTarget = false,

        Jobs = false, -- Set to false if you don't want this item to be used only for jobs.
    },

    ['handmade_bandage'] = {

        Type = 'CURE_ITEM', -- CURE_ITEM, REVIVE_ITEM (Available Types).

        ApplyDuration = 10000, -- Time in milliseconds

        ApplyAnimation = {
            Type = 'SCENARIO', -- SCENARIO, ANIMATION (Available Types).
            Dict = 'WORLD_HUMAN_CROUCH_INSPECT', -- Animation Dict or Scenario Name.
            Base = nil, -- Animation Base Name if type is ANIMATION.
            ApplyingDisplayText = "Applying handmade bandage...",  -- Set to nil to prevent displaying progress bar text and its delay system.
            AppliedDisplayText = "Handmade Bandage applied, you stopped bleeding.",
        },

        Metabolism = {
            Hunger = { Type = "add",    Value = 0  },
            Thirst = { Type = "remove", Value = 0  },

            -- Stress Types : "add", "remove" (Keep in mind, "add", adds more stress to the player, not actual removing).
            Stress = { Type = "remove", Value = 15 },
        },

        InnerCoreStamina = 0,
        InnerCoreStaminaGold = 0.0,
        OuterCoreStaminaGold = 0.0,

        InnerCoreHealth = 50,
        InnerCoreHealthGold = 0.0,
        OuterCoreHealthGold = 0.0,

        -- Set to true if this item is usable only for player targets.
        RequiredPlayerTarget = false,
        
        -- Set to true if you want the player target to be unconsious in order to use this item.
        -- @RequiredPlayerTarget must be true.
        RequiredUnconsiousPlayerTarget = false,

        Jobs = false, -- Set to false if you don't want this item to be used only for jobs.
    },

    ['consumable_antibiotics'] = {

        Type = 'CURE_ITEM', -- CURE_ITEM, REVIVE_ITEM (Available Types).

        ApplyDuration = 3000, -- Time in milliseconds

        ApplyAnimation = {
            Type = 'ANIMATION', -- SCENARIO, ANIMATION (Available Types).
            Dict = "amb_rest_drunk@world_human_drinking@male_a@idle_a", -- Animation Dict or Scenario Name.
            Base = "idle_a", -- Animation Base Name if type is ANIMATION.
            ApplyingDisplayText = nil, -- Set to nil to prevent displaying progress bar text and its delay system.
            AppliedDisplayText = "The effect of the antibiotics will make you feel better.",
        },

        Metabolism = {
            Hunger = { Type = "add",    Value = 0  },
            Thirst = { Type = "remove", Value = 0  },

            -- Stress Types : "add", "remove" (Keep in mind, "add", adds more stress to the player, not actual removing).
            Stress = { Type = "remove", Value = 10 },
        },

        InnerCoreStamina = 0,
        InnerCoreStaminaGold = 0.0,
        OuterCoreStaminaGold = 0.0,

        InnerCoreHealth = 200,
        InnerCoreHealthGold = 0.0,
        OuterCoreHealthGold = 0.0,

        -- Set to true if this item is usable only for player targets.
        RequiredPlayerTarget = false,

        -- Set to true if you want the player target to be unconsious in order to use this item.
        -- @RequiredPlayerTarget must be true.
        RequiredUnconsiousPlayerTarget = false,

        Jobs = false, -- Set to false if you don't want this item to be used only for jobs.
    },

    ['syringe'] = {

        Type = 'REVIVE_ITEM', -- CURE_ITEM, REVIVE_ITEM (Available Types).

        ApplyDuration = 15000, -- Time in milliseconds

        ApplyAnimation = {
            Type = 'ANIMATION', -- SCENARIO, ANIMATION (Available Types).
            Dict = "mech_revive@unapproved", -- Animation Dict or Scenario Name.
            Base = "revive", -- Animation Base Name if type is ANIMATION.
            ApplyingDisplayText = "Injecting syringe...",  -- Set to nil to prevent displaying progress bar text and its delay system.
            AppliedDisplayText = "You have successfully injected a syringe.",
        },

        -- Set to true if this item is usable only for player targets.
        RequiredPlayerTarget = true,

        -- Set to true if you want the player target to be unconsious in order to use this item.
        -- @RequiredPlayerTarget must be true.
        RequiredUnconsiousPlayerTarget = true,

        Jobs = { 'medic', 'doctor' }, -- Set to false if you don't want this item to be used only for jobs.

    },
}

---------------------------------------------------------------
--[[ Mailbox Locations ]]--
---------------------------------------------------------------

Config.Locations = {

    ['Valentine'] = {
        Name = "Medical Office",

        Coords = {x = -288.521, y = 804.4488, z = 118.38, h = 291.23},

        BlipData = {
            Enabled = true,
            Sprite = -1739686743,
        },

        Model = "CS_DrMalcolmMacIntosh",

        HealCost = 2, -- How much a healing should cost?
        ReviveCost = 10, -- How much a revive should cost?

        DrawText  = "~t6~$2.00 ~q~For Small Wounds Treatment ~o~(Press SPACEBAR)",
        DrawText2 = "~t6~$10.00 ~q~For Full Medical Treatment ~o~(Press G)",

        ActionDistance = 1.6,
        DrawTextRenderDistance = 2,
    },

    ['Rhodes'] = {
        Name = "Medical Office",

        Coords = {x = 1366.585, y = -1310.60, z = 76.946, h = 247.10858154297},

        BlipData = {
            Enabled = true,
            Sprite = -1739686743,
        },

        Model = "CS_DrMalcolmMacIntosh",

        HealCost = 2, -- How much a healing should cost?
        ReviveCost = 10, -- How much a revive should cost?

        DrawText  = "~t6~$2.00 ~q~For Small Wounds Treatment ~o~(Press SPACEBAR)",
        DrawText2 = "~t6~$10.00 ~q~For Full Medical Treatment ~o~(Press G)",

        ActionDistance = 1.6,
        DrawTextRenderDistance = 2.5,
    },

    ['SaintDenis'] = {
        Name = "Medical Office",

        Coords = { x = 2717.622, y = -1233.65, z = 49.366, h = 11.97767257690},

        BlipData = {
            Enabled = true,
            Sprite = -1739686743,
        },

        Model = "CS_DrMalcolmMacIntosh",

        HealCost = 2, -- How much a healing should cost?
        ReviveCost = 10, -- How much a revive should cost?

        DrawText  = "~t6~$2.00 ~q~For Small Wounds Treatment ~o~(Press SPACEBAR)",
        DrawText2 = "~t6~$10.00 ~q~For Full Medical Treatment ~o~(Press G)",

        ActionDistance = 1.6,
        DrawTextRenderDistance = 2.5,
    },

    ['Strawberry'] = {
        Name = "Medical Office",

        Coords = { x = -1806.31, y = -428.902, z = 157.83, h = 153.3718261},

        BlipData = {
            Enabled = true,
            Sprite = -1739686743,
        },

        Model = "CS_DrMalcolmMacIntosh",

        HealCost = 2, -- How much a healing (wounds) should cost?
        ReviveCost = 10, -- How much a revive should cost?

        DrawText  = "~t6~$2.00 ~q~For Small Wounds Treatment ~o~(Press SPACEBAR)",
        DrawText2 = "~t6~$10.00 ~q~For Full Medical Treatment ~o~(Press G)",

        ActionDistance = 1.6,
        DrawTextRenderDistance = 2.5,
    },

}

-----------------------------------------------------------
--[[ Notification Functions  ]]--
-----------------------------------------------------------

-- @param source is always null when called from client.
function SendNotification(source, message)
    local duration = 3000

    if not source then
        TriggerEvent('tpz_core:sendBottomTipNotification', message, duration)
    else
        TriggerClientEvent('tpz_core:sendBottomTipNotification', source, message, duration)
    end
  
end

---------------------------------------------------------------
--[[ Discord Webhooking ]]--
---------------------------------------------------------------

Config.Webhooks = {

    ["ACTIONS"] = {
        Enabled = false, 
        Url    = "", 
        Color  = 10038562
    },

    ["ALERTS"] = { -- You can use a webhook which allows your medics to see the alerts from discord. 
        Enabled = false, 
        Url    = "", 
        Color  = 10038562
    },
}