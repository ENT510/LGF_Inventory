# LGF_Inventory API

![LGF Inventory API](https://i.ibb.co/JFvgCMQT/image.png)

# ConVar Configuration

Add the following lines to your `server.cfg` to configure the inventory system.

---
##  **ConVar Settings**

###  Shared ConVars (Client & Server)
```cfg
# Max inventory slots per player
set lgf_inventory:maxSlotInv 10

# Max inventory weight per player
set lgf_inventory:maxInvWeight 20

# Enable debug mode (1 = Enabled, 0 = Disabled)
set lgf_inventory:enableDebug 1

# Enable random item drops in dumpsters (1 = Yes, 0 = No)
set lgf_inventory:randomDropDumpsters 1
```

###  Client-side ConVars

```cfg
# Enable screen blur effect (1 = Yes, 0 = No)
set lgf_inventory:screenBlur 1

# Model for dropped items
set lgf_inventory:dropModel "hei_p_f_bag_var6_bus_s"

# Show item sprite on dropped items (1 = Yes, 0 = No)
set lgf_inventory:enableSpriteDrop 1

# Keybind for hotbar toggle
set lgf_inventory:hotbarKey "f9"

# Keybind for inventory toggle
set lgf_inventory:inventoryKey "f3"

# Enable Ammo Charger DUI (1 = Yes, 0 = No)
set lgf_inventory:enableAmmoChargerDui 1
```

###  Server-side ConVars

```cfg
# Inventory data save interval (seconds) <300 = 5min>
set lgf_inventory:save_interval 120
```

## Server Exports

```lua
--- Retrieves the count of a specific item in a player's inventory.
-- @param target number The ID of the player.
-- @param itemName string The name of the item.
-- @return number The quantity of the item possessed by the player.
local itemCount = exports.LGF_Inventory:getItemCount(target, itemName)

--- Fetches the inventory data of a player.
-- @param target number The ID of the player.
-- @return table A table containing the inventory data.
local inventoryData = exports.LGF_Inventory:getInventoryData(target)

--- Finds the first available free slot in a player's inventory.
-- @param target number The ID of the player.
-- @return number The index of the first free slot.
local freeSlot = exports.LGF_Inventory:getFirstFreeSlot(target)

--- Adds an item to a player's inventory.
-- @param target number The ID of the player.
-- @param itemName string The name of the item to add.
-- @param quantity number The amount of the item to add.
-- @param slot? number|nil Specific slot to add the item from (optional)
-- @param metadata? table|nil Additional item metadata (optional)
-- @return boolean True if the item was added successfully; false otherwise.
local success = exports.LGF_Inventory:addItem(target, itemName, quantity, metadata, slot)

--- Removes an item from a player's inventory.
-- @param target number The ID of the player.
-- @param itemName string The name of the item to remove.
-- @param quantity number The amount of the item to remove.
-- @param slot? number|nil Specific slot to remove the item from (optional)
-- @param metadata? table|nil Additional item metadata (optional)
-- @return boolean True if the item was removed successfully; false otherwise.
local success = exports.LGF_Inventory:removeItem(target, itemName, quantity, metadata, slot)

--- Retrieves the total weight of a player's inventory.
-- @param target number The ID of the player.
-- @return number The total weight of the inventory.
local totalWeight = exports.LGF_Inventory:getInventoryWeight(target)

--- Clears all items from a player's inventory.
-- @param target number The ID of the player.
-- @return boolean True if the inventory was cleared successfully; false otherwise.
local success = exports.LGF_Inventory:clearInventory(target)

--- Opens the inventory of a target player. Required Ace perms "lgf_inventory.openTargetInventory"
-- @param source number The ID of the player initiating the action.
-- @param target number The ID of the target player whose inventory is to be opened.
-- @return boolean True if the inventory was opened successfully; false otherwise.
local success = exports.LGF_Inventory:openTargetInventory(source, target)

--- Confiscates the inventory of a target player.
-- @param target number The ID of the player whose inventory is to be confiscated.
-- @param action string "confiscate" to confiscate the inventory target or "add" to return an inventory Confiscated.
-- @return boolean True if the inventory was confiscated successfully; false otherwise.
local success = exports.LGF_Inventory:confiscateInventory(target, action)

--- Checks if a player has a specific item in their inventory.
-- @param target number The ID of the player.
-- @param itemName string The name of the item to check for.
-- @param quantity number|nil The quantity to check
-- @return boolean True if the player has the item; false otherwise.
local hasItem = exports.LGF_Inventory:hasItem(target, itemName, quantity)

--- Sets metadata for a specific item in a player's inventory.
-- @param target number Player ID
-- @param data table Table containing item information (itemName, metadata, slot)
-- @return boolean success Indicates if the operation was successful
-- @return string response Contains details about the operation result
local success, response = exports.LGF_Inventory:setMetadata(target, data)

--- Retrieves the inventory of a specific player.
-- @param target number The ID of the player whose inventory is to be retrieved.
-- @return table A table containing the player's inventory items.
local playerInventory = exports.LGF_Inventory:getPlayerItems(target)

--- Registers a server-side hook for a specific inventory event.
-- @param eventType string The type of event to hook into (e.g., 'itemAdded', 'itemRemoved', 'move').
-- @param callback function The function to be called when the event occurs.
-- @return string The ID of the Hook
local id = exports.LGF_Inventory:registerServerHook(eventType, function(eventData) end)

--- Removes a previously registered server-side hook.
-- @param eventType string The type of event for which the hook was registered.
-- @param id string The ID of the Hook
exports.LGF_Inventory:removeServerHook(eventType, id)

--- Loads a player's inventory.
-- @param target number The ID of the player whose inventory is to be loaded.
-- @param load boolean Whether to load (true) or unload (false) the player's inventory.
-- @return void
exports.LGF_Inventory:loadInventory(target, load)

--- Transfers an item from one player to another.
-- @param from_source number The source player ID.
-- @param to_targetId number The target player ID.
-- @param itemName string The name of the item.
-- @param quantity number The amount of the item to transfer.
-- @param metadata table|nil Metadata for the item (optional).
-- @param slot number|nil Slot for the item (optional).
-- @return boolean True if the item was successfully transferred; false otherwise.
exports.LGF_Inventory:transferItem(from_source, to_targetId, itemName, quantity, metadata, slot)

```
