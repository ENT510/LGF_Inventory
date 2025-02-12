Inventory            = {}
local MAX_SLOT_INV   = Init.Convar.Shared.MAX_SLOT_INV
local MAX_INV_WEIGHT = Init.Convar.Shared.MAX_INV_WEIGHT


---@param target number
---@param itemName string
---@param quantity number|nil
---@return boolean

function Inventory.hasItem(target, itemName, quantity)
    local inventory = Array.getPlayerInv(target)
    if not inventory then return false end

    for _, item in pairs(inventory) do
        if item.itemName == itemName and item.quantity >= (quantity or 1) then
            return true
        end
    end
    return false
end

---@param source number
---@param target number
function Inventory.openTargetInventory(source, target)
    if not IsPlayerAceAllowed(source, "lgf_inventory.openTargetInventory") then
        Shared.notification("Not Allowed", "You dont have permission to execute this Command.", "error", source)
        return
    end
    TriggerClientEvent("LGF_Inventory:Admin:OpenInventoryTarget", source, target)
end

---@param target number
---@return number|nil
function Inventory.getFirstFreeSlot(target)
    local playerInventory = Array.getPlayerInv(target)

    if not playerInventory then
        return 1
    end

    local occupiedSlots = {}

    for _, item in ipairs(playerInventory) do
        occupiedSlots[item.slot] = true
    end

    for i = 1, MAX_SLOT_INV do
        if not occupiedSlots[i] then
            return i
        end
    end

    return nil
end

---@param target number
---@return number
function Inventory.getInventoryWeight(target)
    if not target then return end
    local inv = Array.getPlayerInv(target)
    if not inv or #inv == 0 then
        return 0
    end
    local totalWeight = 0
    for _, item in ipairs(inv) do
        if item then
            totalWeight = totalWeight + (item.itemWeight * item.quantity)
        end
    end
    return totalWeight
end

---@param target number
---@return boolean
function Inventory.clearInventory(target)
    local inv = Array.getPlayerInv(target)
    if not inv then return false end
    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, {})

    local result = Functions.updateInventory(target, {})
    if result then return true else return false end
end

---@param target number
---@param itemName string
---@param quantity number
---@param metadata table|nil
---@param slot number|nil
---@return boolean
function Inventory.addItem(target, itemName, quantity, metadata, slot)
    local inv = Array.getPlayerInv(target) or {}

    local regItems = Shared.getRegisteredItems()
    local data = regItems[itemName]
    local currentWeight = Inventory.getInventoryWeight(target)
    local additionalWeight = data.itemWeight * quantity

    if currentWeight + additionalWeight > MAX_INV_WEIGHT then
        return false, "Inventory Full"
    end

    if not data then return false end
    slot = slot or Inventory.getFirstFreeSlot(target)

    if not slot then return false end

    local found = false
    if data.stackable then
        for _, item in pairs(inv) do
            if item and item.itemName == itemName then
                item.quantity = item.quantity + quantity
                found = true
                break
            end
        end
    end
    if not found then
        metadata = metadata or data.metadata or {}

        if data.itemType == "weapon" and not data.stackable then
            metadata.Serial = metadata.Serial or Functions.generateWeaponSerial()
            metadata.CurrentAmmo = metadata.CurrentAmmo or 0
        end


        local newItem = {
            slot = slot,
            itemName = itemName,
            quantity = quantity,
            stackable = data.stackable or false,
            itemType = data.itemType,
            itemLabel = data.itemLabel,
            itemWeight = data.itemWeight,
            itemRarity = data.itemRarity,
            description = data.description,
            closeOnUse = data.closeOnUse,
            metadata = metadata,
            durability = data.durability or nil,
            typeAmmo = data.typeAmmo or nil,
        }
        table.insert(inv, newItem)
    end


    PlayerInventory[target] = inv

    TriggerClientEvent("LGF_Inventory:AddItem", target, itemName, quantity, metadata, slot)
    Wait(100)
    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, inv)

    return true
end

--- @param target number Player ID
--- @param itemName string Name of the item to remove
--- @param quantity number Amount to remove (default: 1)
--- @param slot number|nil Specific slot to remove the item from (optional)
--- @param metadata table|nil Additional item metadata (optional)
--- @return boolean Returns true if the item was removed, false otherwise
function Inventory.removeItem(target, itemName, quantity, slot, metadata)
    if not target or not itemName then return false end
    if not quantity then quantity = 1 end

    local playerInventory = Array.getPlayerInv(target)
    if not playerInventory then return false end

    local itemFound = false

    for i, item in ipairs(playerInventory) do
        if (not slot and item.itemName == itemName) or (slot and item.slot == slot and item.itemName == itemName) then
            if item.quantity >= quantity then
                item.quantity = item.quantity - quantity
                if item.quantity <= 0 then
                    table.remove(playerInventory, i)
                end
                itemFound = true
            end
            break
        end
    end

    if not itemFound then return false end
    PlayerInventory[target] = playerInventory
    TriggerClientEvent("LGF_Inventory:RemoveItem", target,
        { slot = slot, itemName = itemName, quantity = quantity, metadata = metadata })
    Wait(400)
    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, PlayerInventory[target])

    return true
end

local isConfiscated = {}

---@param target number Player ID
---@param state string "confiscate" to remove inventory, "add" to return it
---@return boolean Success of the operation
function Inventory.confiscateInventory(target, state)
    if not target then return false end
    local backupKey = ("%s_confiscateBackup"):format(target)
    isConfiscated[target] = false

    if state == "confiscate" then
        if PlayerInventory[backupKey] then return false end
        PlayerInventory[backupKey] = Functions.tabledeepClone(Array.getPlayerInv(target))
        PlayerInventory[target]    = {}
        isConfiscated[target]      = true
        TriggerClientEvent("LGF_Inventory:closeInventory", target)
    elseif state == "add" then
        if not PlayerInventory[backupKey] then return false end
        PlayerInventory[target] = Functions.tabledeepClone(PlayerInventory[backupKey])
        PlayerInventory[backupKey] = nil
        isConfiscated[target] = false
    else
        return false
    end


    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, PlayerInventory[target], isConfiscated[target])
    return true
end

---@param target number Player ID
---@param serial string Weapon serial number
---@param key string Metadata key to update
---@param value any New value for the metadata
---@return boolean Success of the operation
function Inventory.updateWeaponMetadata(target, serial, key, value)
    local inv = Array.getPlayerInv(target)
    if not inv then
        return false
    end

    for _, item in ipairs(inv) do
        if item.itemType == "weapon" and item.metadata and item.metadata.Serial == serial then
            item.metadata[key] = value

            TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, inv)
            return true
        end
    end

    return false
end

---@param typeInventory string Inventory type ("player", "drops", "dumpsters")
---@param value number|string ID or identifier of the inventory
---@return table|boolean Inventory data or false if an error occurs
function Inventory.getInventoryData(typeInventory, value)
    if not typeInventory or not value then return false end

    local inv, ownerID, maxWeight, maxSlots, isConfiscated, totalWeight = {}, value, nil, nil, false, 0

    if typeInventory == "player" then
        inv = Array.getPlayerInv(value) or {}
        maxWeight = MAX_INV_WEIGHT
        maxSlots = MAX_SLOT_INV
        isConfiscated = PlayerInventory[("%s_confiscateBackup"):format(value)] ~= nil
        totalWeight = Inventory.getInventoryWeight(value) or 0
    elseif typeInventory == "drops" then
        inv = Drops[value] and Drops[value].items or {}
    elseif typeInventory == "dumpsters" then
        inv = Dumpsters[value] and Dumpsters[value].items or {}
        maxWeight = 10
        maxSlots = 20
    else
        return false
    end

    return {
        items = inv,
        ownerID = ownerID,
        typeInventory = typeInventory,
        totalWeight = totalWeight,
        maxWeight = maxWeight or nil,
        totalItems = #inv,
        maxSlots = maxSlots or nil,
        isConfiscated = isConfiscated
    }
end

---@param target number Player ID
---@param data table Table containing item information (itemName, metadata, slot)
---@return boolean success Indicates if the operation was successful
---@return string response Contains details about the operation result
function Inventory.setMetadata(target, data)
    assert(type(target) == "number", "Invalid target ID")
    assert(type(data.itemName) == "string", "Missing or invalid itemName")
    assert(type(data.metadata) == "table", "Missing or invalid metadata")
    assert(type(data.slot) == "number", "Slot is required and must be a number")

    local inventory = assert(Array.getPlayerInv(target), "Player inventory not found")

    for _, item in ipairs(inventory) do
        if item.itemName == data.itemName and item.slot == data.slot then
            item.metadata = item.metadata or {}

            for key, value in pairs(data.metadata) do
                item.metadata[key] = value
            end

            TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, inventory)
            return true, "Metadata updated successfully"
        end
    end

    return false, "Item not found in the specified slot"
end

---@param target number Player ID
---@param itemName string Item name
---@return number quantity Amount of the item owned
function Inventory.getItemCount(target, itemName)
    assert(type(target) == "number", "Invalid target ID")
    assert(type(itemName) == "string", "Invalid item name")

    local inventory = Array.getPlayerInv(target)
    if not inventory then return 0 end

    local count = 0
    for _, item in ipairs(inventory) do
        if item.itemName == itemName then
            count = count + item.quantity
        end
    end

    return count
end

--- @param from_source number Player ID
--- @param to_targetId number Target Player ID
--- @param itemName string Item name
--- @param quantity number Amount of the item to transfer
--- @param metadata table|nil Metadata for the item (optional)
--- @param slot number|nil Slot number for the item (optional)
--- @return boolean Success of the transfer
function Inventory.transferItem(from_source, to_targetId, itemName, quantity, metadata, slot)
    local targetWeight = Inventory.getInventoryWeight(to_targetId)

    local registeredItems = Shared.getRegisteredItems()
    local itemData = registeredItems[itemName]

    local itemWeight = itemData.itemWeight * quantity

    if targetWeight + itemWeight > MAX_INV_WEIGHT then
        Shared.notification("Error", "Target's inventory is too full to accept this item", "error", from_source)
        return false
    end

    Inventory.removeItem(from_source, itemName, quantity, slot, metadata)
    Inventory.addItem(to_targetId, itemName, quantity, metadata)

    return true
end

--- @param target number The player ID whose inventory is being loaded or unloaded
--- @param load boolean Whether to load or unload the inventory (true to load, false to unload)
function Inventory.loadInventory(target, load)
    local playerId = target
    if load == true then
        local inventory = Functions.getInventory(playerId)
        SetTimeout(1000, function()
            TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, playerId, inventory)
            local charId = Framework.getCharId(playerId)
            CurrentCharId[playerId] = charId
        end)
        
    elseif load == false then
        if PlayerInventory[playerId] then
            Functions.updateInventory(playerId, PlayerInventory[playerId])
        end

        PlayerInventory[playerId] = nil
        CurrentCharId[playerId] = nil
        SetTimeout(1000, function()
            TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, playerId, PlayerInventory[playerId] or {})
        end)
    end
end

exports("loadInventory", Inventory.loadInventory)
exports("transferItem", Inventory.transferItem)
exports("getItemCount", Inventory.getItemCount)
exports("getInventoryData", Inventory.getInventoryData)
exports("getFirstFreeSlot", Inventory.getFirstFreeSlot)
exports("addItem", Inventory.addItem)
exports("removeItem", Inventory.removeItem)
exports("getInventoryWeight", Inventory.getInventoryWeight)
exports("clearInventory", Inventory.clearInventory)
exports("openTargetInventory", Inventory.openTargetInventory)
exports("confiscateInventory", Inventory.confiscateInventory)
exports("hasItem", Inventory.hasItem)
exports("setMetadata", Inventory.setMetadata)
