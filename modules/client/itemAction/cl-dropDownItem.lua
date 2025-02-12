Action = {}
Action.Listener = {}

Action.drops = {}




RegisterNuiCallback("LGF_Inventory:Nui:handleMenuAction", function(data, cb)
    cb(1)
    Action.handleItemAction(data)
end)

function Action.handleItemAction(data)
    local actionType = data.action
    local item = data.item
    local quantityToRemove = (data.sliderValue == 0 and 1 or data.sliderValue)
    local targetInventory = data.targetInventory
    local targetSource = data.source
    local isArmed, weaponData = Weapon.isArmed()

    if actionType == "use" and item.itemType == "weapon" then
        if item.closeOnUse then Client.closeInv() end

        Weapon.ToggleWeapon(item)
        return
    end


    print(json.encode(data, { indent = true }))


    if actionType == "transfer" and data.typeInventory == "dumpster" then
        if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(CurrentDumpst)) > 5.0 then
            return
        end

        local success = Dumpst.removeItemByName(data.inventoryName, data.item.itemName, data.item.slot, quantityToRemove)

        if success then
            Client.closeInv()
            Wait(500)
            local cb = lib.callback.await("LGF_Inventory:AddItemByTypeInv", 100, {
                itemName = data.item.itemName,
                quantity = quantityToRemove,
                metadata = data.item.metadata
            }, data.typeInventory)
        end
    end


    if actionType == "give" then
        if data.item.itemType == "weapon" and isArmed then Weapon.DisarmWeapon() end
        Client.closeInv()
        Client.openPlayerList(true, data.item.itemName, quantityToRemove, data.item.slot, data.item.metadata)
    elseif actionType == "use" then
        if item.itemName == "money" then return end
        Action.useItem(item, quantityToRemove)
    elseif actionType == "drop" or actionType == "take" then
        local ped = PlayerPedId()
        local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.5, 0.0)
        local Prop = Init.Convar.Client.DROP_OBJECT_MODEL
        Client.closeInv()

        if data.item.itemType == "weapon" and isArmed then Weapon.DisarmWeapon() end

        local closestObj = GetClosestObjectOfType(coords.x, coords.y, coords.z, 1.5, Prop, false, false, false)
        if DoesEntityExist(closestObj) then coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 2.0, 0.0) end

        local obj = Functions.createObjDrop({
            model = Prop,
            coords = coords
        })


        lib.callback.await("LGF_Inventory:CreateObjectDrop", false, item, quantityToRemove, obj, targetInventory,
            targetSource, Prop, coords)
    end
end

local function createDropPoint(obj, dropPosition)
    local isInArea = false
    local isNearby = false
    local Sleep = 2000
    local GetDropFromObject = Action.drops[obj]

    if Init.Convar.Client.ENABLE_SPRITE_DROP then
        Functions.requestStreamText("shared")
    end


    CreateThread(function()
        while Action.drops[obj] do
            Wait(Sleep)
            local playerPos = GetEntityCoords(PlayerPedId())
            local dist = #(playerPos - dropPosition)

            if dist < 5.0 then
                if not isInArea then
                    isInArea = true
                    exports.LGF_UiPack:showTextUi({
                        title = ("%s Dropped"):format(GetDropFromObject.data.itemLabel),
                        message = ("Press [E] to take x%s %s"):format(GetDropFromObject.quantityToAdd,
                            GetDropFromObject.data.itemLabel),
                        binder = "E",
                        position = "right",
                        backgroundColor = "rgba(31, 41, 55, 0.9)"
                    })
                end

                if dist < 2.0 then
                    if not isNearby then
                        isNearby = true
                        Sleep = 0
                    end

                    if Init.Convar.Client.ENABLE_SPRITE_DROP then
                        Functions.drawSpriteRef(vec3(dropPosition.x, dropPosition.y, dropPosition.z + 0.5))
                    end

                    if IsControlJustReleased(0, 38) then
                        exports.LGF_UiPack:hideTextUi()
                        lib.callback.await("LGF_Inventory:PickupItem", false, obj, GetDropFromObject.quantityToAdd,
                            GetPlayerServerId(PlayerId()))
                    end
                else
                    isNearby = false
                    Sleep = 2000
                end
            else
                if isInArea then
                    isInArea = false
                    exports.LGF_UiPack:hideTextUi()
                    Sleep = 2000
                end
            end
        end
    end)
end


RegisterNetEvent("LGF_Inventory:CreateObjectDrop", function(data, quantity, obj, targetInventory, model, dropPosition)
    if not Action.drops then Action.drops = {} end
    local coords = vec3(dropPosition.x, dropPosition.y, dropPosition.z)

    Action.drops[obj] = {
        model = model,
        entity = obj,
        data = data,
        position = coords,
        quantityToAdd = quantity
    }

    lib.callback.await("LGF_Inventory:UpdateTableDrops", false, obj, Action.drops[obj])

    createDropPoint(obj, coords)
end)

RegisterNetEvent("LGF_Inventory:PickupItem", function(obj)
    if Action.drops[obj] then
        SetEntityAsMissionEntity(Action.drops[obj].entity, false, true)
        DeleteEntity(Action.drops[obj].entity)
        Action.drops[obj] = nil

        SetStreamedTextureDictAsNoLongerNeeded("shared")

        if LocalPlayer.state.textuiBusy then
            exports.LGF_UiPack:hideTextUi()
        end
    end
end)



AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        for _, drop in pairs(Action.drops) do
            if DoesEntityExist(drop.entity) then
                SetEntityAsMissionEntity(drop.entity, false, true)
                DeleteEntity(drop.entity)
            end
        end
    end
end)



function Action.useItem(item, quantity)
    if not item then return end

    local GetItems = Shared.getRegisteredItems()
    local itemData = GetItems[item.itemName]

    if itemData.closeOnUse then
        Client.closeInv()
    end

    if Action.Listener.onUse then
        Action.Listener.onUse(item)
    end

    if item.stackable then
        Action.removeItem({
            itemName = item.itemName,
            quantity = 1,
            slot = item.slot,
            metadata = item.metadata
        })
    else
        Action.removeItem({
            itemName = item.itemName,
            quantity = quantity,
            slot = item.slot,
            metadata = item.metadata
        })
    end
end

function Action.triggerOnUse(item)
    if Action.Listener.onUse then
        Action.Listener.onUse(item)
    end
end

function Action.removeItem(data)
    return lib.callback.await("LGF_Inventory:RemoveItem", false, data)
end

RegisterNetEvent("LGF_Inventory:RemoveItem", function(data)
    local GetItems = Shared.getRegisteredItems()
    local itemData = GetItems[data.itemName]

    local itemToRemove = {
        slot = data.slot,
        itemName = data.itemName,
        itemLabel = itemData.itemLabel,
        metadata = data?.metadata or itemData.metadata,
        quantity = data?.quantity
    }

    SendNUIMessage({
        action = "LGF_Inventory:Removeitem",
        data = itemToRemove
    })

    Client.setNotifyItems({
        itemLabel = itemData.itemLabel,
        itemImage = ("nui://LGF_Inventory/web/images/%s.png"):format(data.itemName),
        quantity = data.quantity,
        action = "Removed",
        duration = 4000,
    })
end)


RegisterNetEvent("LGF_Inventory:AddItem", function(itemName, quantity, metadata, slot)
    local itemData = Shared.getRegisteredItems()[itemName]
    if not itemData then return end
    local currentWeight = Inventory.getInventoryWeight()
    local maxWeight = Init.Convar.Shared.MAX_INV_WEIGHT

    if currentWeight + (itemData.itemWeight * quantity) > maxWeight then return end

    local itemToAdd = {
        slot = slot,
        itemName = itemName,
        itemLabel = itemData.itemLabel,
        metadata = metadata or itemData.metadata or nil,
        quantity = quantity,
        stackable = itemData.stackable,
        itemType = itemData.itemType,
        itemWeight = itemData.itemWeight,
        itemRarity = itemData.itemRarity,
        description = itemData.description,
        closeOnUse = itemData.closeOnUse,
        durability = itemData.durability or nil
    }

    SendNUIMessage({
        action = "LGF_Inventory:AddItem",
        data = itemToAdd
    })

    Client.setNotifyItems({
        itemLabel = itemData.itemLabel,
        itemImage = ("nui://LGF_Inventory/web/images/%s.png"):format(itemName),
        quantity = quantity,
        action = "add",
        duration = 4000,
    })
end)

RegisterNuiCallback("LGF_Inventory:Nui:GiveItemToPlayer", function(data, cb)
    cb(true)
    local targetId = data.playerId
    local itemName = data.itemName
    local itemQuantity = data.itemQuantity
    local slot = data.slot
    local metadata = data.metadata
    local CoordsTargetId = GetPlayerFromServerId(targetId)

    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(CoordsTargetId))) > 5.0 then
        return
    end

    local _Call = lib.callback.await("LGF_Inventory:Nui:GiveItemToPlayer", false, tonumber(targetId), itemName,
        itemQuantity, slot, metadata)

    if _Call then
        Client.openPlayerList(false, itemName, itemQuantity, slot, metadata)
    end
end)

exports("useItem", Action.useItem)

exports("onUse", function(callback)
    Action.Listener.onUse = callback
end)

exports.LGF_Inventory:onUse(function(item)
    if item and PrefixAnim[item.itemName] then
        local itemData = PrefixAnim[item.itemName]
        if itemData then
            if itemData.onUsing then
                itemData.onUsing(itemData)
            end
        end
    end
end)
