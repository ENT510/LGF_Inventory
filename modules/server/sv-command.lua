RegisterCommand(Config.inventoryCommand.AddItem.CommandName, function(source, args, rawCommand)
    local target = tonumber(args[1]) or source
    local itemName = args[2]
    local quantity = tonumber(args[3]) or 1

    if not itemName or not target then return end

    local success = Inventory.addItem(target, itemName, quantity)
    if success then
        Shared.debugInventory(("Added %d of %s to target %d"):format(quantity, itemName, target))
    else
        print("Failed to add item.")
    end
end, false)

RegisterCommand(Config.inventoryCommand.ClearInv.CommandName, function(source, args, rawCommand)
    local target = tonumber(args[1])
    if not target then return end

    local success = Inventory.clearInventory(target)
    if success then
        Shared.debugInventory(("Cleared inventory for target %d"):format(target))
    else
        Shared.debugInventory(("Failed to clear inventory for target %s."):format(target))
    end
end, false)



RegisterCommand(Config.inventoryCommand.OpenTargetInv.CommandName, function(source, args, rawCommand)
    local target = tonumber(args[1])
    if not target then return end
    Inventory.openTargetInventory(source, target)
end, false)


RegisterCommand(Config.inventoryCommand.ConfiscateInv.CommandName, function(source, args, rawCommand)
    local target = tonumber(args[1])
    local action = args[2]

    if not target or (action ~= "confiscate" and action ~= "add") then
        return
    end

    local success = Inventory.confiscateInventory(target, action)

    if success then
        Shared.debugInventory(("Inventory %s for target %d"):format(action, target))
    else
        Shared.debugInventory(("Failed to %s inventory for target %d."):format(action, target))
    end
end, false)


Wait(4000)

Inventory.addItem(1, "water", 5)