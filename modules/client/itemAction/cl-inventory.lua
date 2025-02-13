---@class Item
---@field slot number
---@field itemWeight number
---@field quantity number
---@field itemName string
---@field itemLabel? string
---@field itemType? string
---@field itemRarity? string
---@field description? string
---@field closeOnUse? boolean
---@field metadata? table
---@field durability? number
---@field usable? boolean

Inventory = {}

--- Returns the player's personal inventory safely.
--- @return Item[] inventory The contents of the player's inventory.
function Inventory.getPersonalInventory()
    local success, inventory = pcall(function()
        return Client.PlayerInventory or {}
    end)
    return success and inventory or {}
end

--- Retrieves an item from the specified slot safely.
--- @param slot number The slot number to retrieve the item from.
--- @return Item|nil item Returns the item found, or nil if it doesn't exist.
function Inventory.getItemFromSlot(slot)
    local PlayerInv = Inventory.getPersonalInventory()
    slot = tonumber(slot) --[[@as number]]
    if not slot then return nil end

    for i = 1, #PlayerInv do
        local item = PlayerInv[i]
        if item and item.slot == slot then
            return item
        end
    end

    return nil
end

--- Calculates the total weight of the inventory.
--- @return number totalWeight The total weight of the player's inventory.
function Inventory.getInventoryWeight()
    local inventory = Inventory.getPersonalInventory() or {}
    local totalWeight = 0

    for _, item in ipairs(inventory) do
        if item and type(item) == "table" and item.itemWeight and item.quantity then
            totalWeight = totalWeight + ((tonumber(item.itemWeight) or 0) * (tonumber(item.quantity) or 0))
        end
    end

    return totalWeight
end

--- Finds the first available free inventory slot.
--- @return number|nil firstFreeSlot The first free slot or nil if inventory is full.
function Inventory.getFirstFreeSlot()
    local playerInventory = Inventory.getPersonalInventory()

    if not playerInventory then
        return 1
    end

    local occupiedSlots = {}

    for _, item in ipairs(playerInventory) do
        occupiedSlots[item.slot] = true
    end

    for i = 1, Init.Convar.Shared.MAX_SLOT_INV do
        if not occupiedSlots[i] then
            return i
        end
    end

    return nil
end

--- Returns the player's money count.
--- @return number moneyCount The total money count.
function Inventory.getMoneyCount()
    local inventory = Inventory.getPersonalInventory() or {}
    local moneyCount = 0

    for _, item in ipairs(inventory) do
        if item and type(item) == "table" and item.itemName and string.lower(item.itemName) == "money" then
            moneyCount = moneyCount + (tonumber(item.quantity) or 0)
        end
    end

    return moneyCount
end

--- Checks if the player's inventory contains at least the given quantity of the specified item.
--- @param itemName string The name of the item to check (case-insensitive).
--- @param quantity number The required quantity.
--- @return boolean hasItem True if the item exists in at least the given quantity, false otherwise.
--- @return number itemCount The actual quantity of the item found in the inventory.
function Inventory.hasItem(itemName, quantity)
    local inventory = Inventory.getPersonalInventory() or {}
    local itemCount = 0
    quantity = tonumber(quantity) or 1

    for _, item in ipairs(inventory) do
        if item and item.itemName and string.lower(item.itemName) == string.lower(itemName) then
            itemCount = itemCount + (tonumber(item.quantity) or 0)
            if itemCount >= quantity then
                return true, itemCount
            end
        end
    end

    return false, itemCount
end

--- Checks if a specific slot is occupied.
--- @param slot number The slot number to check.
--- @return boolean occupied True if the slot is occupied.
function Inventory.isSlotOccupied(slot)
    return Inventory.getItemFromSlot(slot) ~= nil
end

-- get Correct data when close the inventory using Client.closeInv()
-- When close Pass correctly data
function Inventory.closeInventory()
    Client.closeInv()
end

exports("getFirstFreeSlot", Inventory.getFirstFreeSlot)
exports("getPlayerItems", Inventory.getPersonalInventory)
exports("getItemFromSlot", Inventory.getItemFromSlot)
exports("getInventoryWeight", Inventory.getInventoryWeight)
exports("getMoneyCount", Inventory.getMoneyCount)
exports("hasItem", Inventory.hasItem)
exports("isSlotOccupied", Inventory.isSlotOccupied)
exports("closeInventory", Inventory.closeInventory)
