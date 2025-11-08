# TPZ-CORE Medics

## Requirements

1. TPZ-Core: https://github.com/TPZ-CORE/tpz_core
2. TPZ-Characters: https://github.com/TPZ-CORE/tpz_characters
3. TPZ-Inventory : https://github.com/TPZ-CORE/tpz_inventory
4. TPZ-Notify : https://github.com/TPZ-CORE/tpz_notify

# Installation

1. When opening the zip file, open `tpz_medics-main` directory folder and inside there will be another directory folder which is called as `tpz_medics`, this directory folder is the one that should be exported to your resources (The folder which contains `fxmanifest.lua`).

2. Add `ensure tpz_medics` after the **REQUIREMENTS** in the resources.cfg or server.cfg, depends where your scripts are located.

# Development API

- Use the specified server event to set a player's snake poison state (removing or adding poison)

```lua

-- @param source (Integer) : Requires the player target source id.
-- @param state (Boolean) : Requires the set state (true = add poison, false = remove poison).
TriggerEvent("tpz_medics:server:set_poisoned_state", source, state) -- the event is server side, the trigger is by default from server > server.
```
