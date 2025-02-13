Hook = {}

RegisterNetEvent("LGF_Inventory:Hooks:ActionResult")
AddEventHandler("LGF_Inventory:Hooks:ActionResult", function(bool)
    if Hook.pendingCallback then
        Hook.pendingCallback(bool)
        Hook.pendingCallback = nil
    end
end)

RegisterNuiCallback("LGF_Inventory.Nui.MonitorAction", function(data, cb)
    Hook.pendingCallback = cb
    Hook.monitorAction(data)
end)

function Hook.monitorAction(data)
    local fromSlot = data.fromSlot
    local toSlot = data.toSlot
    local movedItem = data.movedItem
    local playerInventory = Client.PlayerInventory
    local registeredItems = Shared.getRegisteredItems()
    local newItemData = registeredItems[movedItem.itemName]

    local itemIndex = nil
    for i, item in ipairs(playerInventory) do
        if item.slot == fromSlot then
            itemIndex = i
            break
        end
    end

    if itemIndex then
        local item = playerInventory[itemIndex]

        if item then
            if item.quantity > movedItem.quantity then
                item.quantity = item.quantity - movedItem.quantity

                local merged = false
                for i, targetItem in ipairs(playerInventory) do
                    if targetItem.slot == toSlot and targetItem.itemName == movedItem.itemName and targetItem.stackable then
                        targetItem.quantity = targetItem.quantity + movedItem.quantity
                        merged = true
                        break
                    end
                end

                if not merged then
                    local newItem = {
                        slot        = toSlot,
                        itemName    = movedItem.itemName,
                        quantity    = movedItem.quantity,
                        itemLabel   = newItemData.itemLabel,
                        itemWeight  = newItemData.itemWeight,
                        itemType    = newItemData.itemType,
                        stackable   = newItemData.stackable,
                        itemRarity  = movedItem.itemRarity or newItemData.itemRarity,
                        description = newItemData.description,
                        closeOnUse  = newItemData.closeOnUse,
                        metadata    = newItemData.metadata or nil,
                        durability  = newItemData.durability or nil,
                        usable      = newItemData.usable or nil
                    }
                    table.insert(playerInventory, newItem)
                end
            else
                local swapped = false
                for i, targetItem in ipairs(playerInventory) do
                    if targetItem.slot == toSlot then
                        if targetItem.itemName == item.itemName and targetItem.stackable then
                            targetItem.quantity = targetItem.quantity + item.quantity
                            table.remove(playerInventory, itemIndex)
                            swapped = true
                            break
                        else
                            playerInventory[i].slot = fromSlot
                        end
                    end
                end
                if not swapped then
                    item.slot = toSlot
                end
            end
        end
    end

    Client.PlayerInventory = playerInventory

    lib.callback.await("LGF_Inventory:Hooks:MonitorHooks", false, Client.PlayerInventory)
    TriggerServerEvent("LGF_Inventory:Hooks:MonitorHooks", data)
end
