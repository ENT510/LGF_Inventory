lib.callback.register("LGF_Inventory:RemoveItem", function(source, data)
    Functions.removeItem(data.Target or source, data)
    return true
end)


lib.callback.register("LGF_Inventory:GetPlayerInv", function(source, data)
    return Array.getPlayerInv(source)
end)


lib.callback.register("LGF_Inventory:Hooks:MonitorHooks", function(source, data)
    local playerInventory = Array.getPlayerInv(source)

    -- Sync New State of the Inventory like slot ecc with all
    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, source, data)

    if playerInventory then
        PlayerInventory[source] = data
    end

    return true
end)


lib.callback.register("LGF_Inventory:UpdateTableDrops", function(source, obj, data)
    Drops[obj] = data
    return true
end)

lib.callback.register("LGF_Inventory:CreateObjectDrop",
    function(source, data, quantityToAdd, obj, targetInventory, targetSource, model, dropCoords)
        TriggerClientEvent("LGF_Inventory:CreateObjectDrop", -1, data, quantityToAdd, obj, targetInventory, model,
            dropCoords)

        print(json.encode(data, { indent = true }))

        data.quantity = quantityToAdd

        Functions.removeItem(targetSource, data)
        return true
    end)


lib.callback.register("LGF_Inventory:PickupItem", function(source, obj, quantiToAdd, target)
    if Drops[obj] then
        local itemData = Drops[obj]
        local quantity = quantiToAdd
        local metadata = itemData.data.metadata or nil

        TriggerClientEvent("LGF_Inventory:PickupItem", -1, obj)

        local success = Inventory.addItem(target, itemData.data.itemName, quantity, metadata)

        if success then
            Drops[obj] = nil
            return true
        else
            return false
        end
    end

    return false
end)

lib.callback.register("LGF_Inventory:GetNameForOpenInv", function(source, target)
    return Legacy.DATA:GetName(target)
end)

lib.callback.register("LGF_Inventory:SyncDumpsters", function(source, lootData)
    TriggerClientEvent("LGF_Inventory:SyncDumpsters", -1, lootData)
    TriggerClientEvent("LGF_Inventory:Dumpsters:UpdateInventoryDumpsters", -1, lootData)
    return true
end)

lib.callback.register("LGF_Inventory:dumpster:UpdateTableDumpster", function(source, lootData)
    TriggerClientEvent("LGF_Inventory:Dumpsters:UpdateInventoryDumpsters", -1, lootData)
    return true
end)

lib.callback.register("LGF_Inventory:AddItemByTypeInv", function(source, data, type)
    Inventory.addItem(source, data.itemName, data.quantity, data.metadata)
    return true
end)

lib.callback.register('LGF_Inventory:removeAmmo', function(source, itemName, quantityAmmo, serial, ammoInWeapon)
    Inventory.removeItem(source, itemName, quantityAmmo)


    return true
end)

lib.callback.register('LGF_Inventory:updateAmmoCount', function(source, serial, ammoInWeapon)
    Inventory.updateWeaponMetadata(source, serial, "CurrentAmmo", ammoInWeapon)
    return true
end)
