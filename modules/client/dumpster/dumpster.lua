if not Init.Convar.Shared.RANDOM_DROP_DUMPSTERS then
    return
end
local enableDebug = Init.Convar.Shared.ENABLE_DEBUG_INVENTORY


Dumpst = {}

Dumpsters = {
    PropHash = {
        218085040,
        666561306,
        -58485588,
        -206690185,
        1511880420,
        682791951
    }
}


Dumpsters.HashSet = {}
for _, model in ipairs(Dumpsters.PropHash) do
    Dumpsters.HashSet[model] = true
end

local DumpsterInventories = {}

RegisterNetEvent("LGF_Inventory:Dumpsters:UpdateInventoryDumpsters", function(lootData)
    if not lootData or type(lootData) ~= "table" then return end

    if lootData.netId and lootData.items then
        DumpsterInventories[lootData.netId] = lootData.items
        return
    end


    for _, dumpster in ipairs(lootData) do
        if dumpster.netId and dumpster.items then
            DumpsterInventories[dumpster.netId] = dumpster.items
        end
    end
end)


local activeDumpsters = {}

RegisterNetEvent("LGF_Inventory:SyncDumpsters", function(lootData)
    for _, data in ipairs(lootData) do
        local dumpsterId = data.netId

        if not activeDumpsters[dumpsterId] and Framework.playerLoaded() then
            activeDumpsters[dumpsterId] = true

            CreateThread(function()
                local isNearbyDumpster = false
                local isEntered = false
                local moneyCount = 0

                while activeDumpsters[dumpsterId] do
                    local sleep = 2000
                    local playerPed = PlayerPedId()
                    local playerCoords = GetEntityCoords(playerPed)
                    local foundDumpster = false


                    if NetworkDoesNetworkIdExist(dumpsterId) then
                        local DumpsterEntity = NetworkGetEntityFromNetworkId(dumpsterId)
                        if DoesEntityExist(DumpsterEntity) then
                            local model = GetEntityModel(DumpsterEntity)
                            if Dumpsters.HashSet[model] then
                                local dumpsterCoords = GetEntityCoords(DumpsterEntity)
                                local distance = #(playerCoords - dumpsterCoords)

                                if distance < 5.0 then
                                    foundDumpster = true

                                    if not isEntered then
                                        isEntered = true
                                    end

                                    if distance < 4.0 then
                                        if not isNearbyDumpster then
                                            isNearbyDumpster = true
                                            exports.LGF_UiPack:showTextUi({
                                                title = "Dumpster",
                                                message = "Press [E] to search in Dumpster",
                                                binder = "E",
                                                position = "right",
                                                backgroundColor = "rgba(31, 41, 55, 0.9)"
                                            })
                                        end
                                    else
                                        if isNearbyDumpster then
                                            isNearbyDumpster = false
                                            exports.LGF_UiPack:hideTextUi()
                                        end
                                    end

                                    if distance < 2.0 then
                                        sleep = 0
                                        if IsControlJustReleased(0, 38) then
                                            exports.LGF_UiPack:hideTextUi()

                                            local inventory = DumpsterInventories[dumpsterId] or {}
                                            Client.openInventory({
                                                Display = true,
                                                InventoryItems = inventory,
                                                InventoryInfo = {
                                                    maxWeight = 10,
                                                    maxSlots = 20,
                                                    inventoryName = ("Dumpster_%s"):format(dumpsterId),
                                                    playerJob = "dumpsters",
                                                    typeInventory = "dumpster",
                                                    moneyCount = moneyCount
                                                },
                                            })
                                            CurrentDumpst = DumpsterEntity
                                        end
                                    else
                                        sleep = 2000
                                    end
                                end
                            end
                        end
                    else
                        if enableDebug then
                            warn(("Dumpster NetID %s is no longer valid, removing it."):format(dumpsterId))
                        end
                        activeDumpsters[dumpsterId] = nil
                        break
                    end

                    if not foundDumpster then
                        if isEntered or isNearbyDumpster then
                            isEntered = false
                            isNearbyDumpster = false
                            exports.LGF_UiPack:hideTextUi()
                            CurrentDumpst = nil
                        end
                    end

                    Wait(sleep)
                end
            end)
        end
    end
end)


function Dumpst.matchDumpsterEnt()
    local objects = GetGamePool("CObject")
    local dumpsters = {}

    for i = 1, #objects do
        local obj = objects[i]
        if DoesEntityExist(obj) then
            local model = GetEntityModel(obj)
            if Dumpsters.HashSet[model] then
                FreezeEntityPosition(obj, true)
                dumpsters[#dumpsters + 1] = obj
            end
        end
    end
    return dumpsters
end

function Dumpst.generateDumpsterLoot()
    local RegisteredItems = Shared.getRegisteredItems()
    local possibleLoot = {}
    local MAX_DUMPSTER_WEIGHT = 10
    local currentWeight = 0


    for itemName, itemData in pairs(RegisteredItems) do
        if itemData.itemType ~= "weapon" then
            possibleLoot[#possibleLoot + 1] = itemName
        end
    end


    if math.random() < 0.2 then
        return {}
    end

    local dumpsterLoot = {}
    local numLootItems = math.random(0, 3)

    for i = 1, numLootItems do
        local randomIndex = math.random(#possibleLoot)
        local selectedItem = possibleLoot[randomIndex]
        local itemData = RegisteredItems[selectedItem]
        local quantity = 1

        if selectedItem == "money" then
            quantity = math.random(30, 200)
        elseif itemData.stackable then
            quantity = math.random(1, 3)
        end

        local itemWeight = itemData.itemWeight * quantity

        if (currentWeight + itemWeight) <= MAX_DUMPSTER_WEIGHT then
            currentWeight = currentWeight + itemWeight

            local found = false
            for _, existingItem in ipairs(dumpsterLoot) do
                if existingItem.itemName == selectedItem and existingItem.stackable then
                    existingItem.quantity = existingItem.quantity + quantity
                    found = true
                    break
                end
            end


            if not found then
                dumpsterLoot[#dumpsterLoot + 1] = {
                    slot = #dumpsterLoot + 1,
                    itemName = selectedItem,
                    itemLabel = itemData.itemLabel,
                    metadata = itemData.metadata or {},
                    quantity = quantity,
                    stackable = itemData.stackable or false,
                    itemType = itemData.itemType or "item",
                    itemWeight = itemData.itemWeight,
                    itemRarity = itemData.itemRarity,
                    description = itemData.description,
                    closeOnUse = itemData.closeOnUse or false,
                    durability = itemData.durability,
                    moneyCount = (selectedItem == "money" and quantity or 0)
                }
            end
        else
            break
        end
    end

    return dumpsterLoot
end

function Dumpst.initDumpster()
    local entities = Dumpst.matchDumpsterEnt()
    local lootData = {}
    DumpsterInventories = {}

    for _, entity in ipairs(entities) do
        if DoesEntityExist(entity) then
            local netId
            local attempts = 0


            while not NetworkGetEntityIsNetworked(entity) and attempts < 100 do
                NetworkRegisterEntityAsNetworked(entity)
                Wait(10)
                attempts = attempts + 1
            end

            if NetworkGetEntityIsNetworked(entity) then
                netId = NetworkGetNetworkIdFromEntity(entity)
            end

            if netId and netId > 0 then
                local loot = Dumpst.generateDumpsterLoot()

                lootData[#lootData + 1] = {
                    netId = netId,
                    items = loot
                }

                SetEntityAsMissionEntity(entity, true, false)

                DumpsterInventories[netId] = loot
                if enableDebug then
                    print(("^5[DUMPSTER REGISTERED]^0\n--------------------------\nNetID: %d\nModel: %d\nCoords: %s")
                        :format(netId, GetEntityModel(entity), tostring(GetEntityCoords(entity))))
                end
            else
                warn(("Unable to obtain a valid Network ID for entity %s"):format(entity))
            end
        end
    end

    if #lootData > 0 then
        lib.callback.await("LGF_Inventory:SyncDumpsters", false, lootData)
    end
end

function Dumpst.getInventoryByName(inventoryName)
    local dumpsterId = tonumber(inventoryName:match("Dumpster_(%d+)"))

    return dumpsterId and DumpsterInventories[dumpsterId] or nil
end

function Dumpst.removeItemByName(inventoryName, itemName, slot, quantity)
    local dumpsterId = tonumber(inventoryName:match("Dumpster_(%d+)"))
    if not dumpsterId or not DumpsterInventories[dumpsterId] then
        return false
    end

    local inventory = DumpsterInventories[dumpsterId]

    for i, invItem in ipairs(inventory) do
        if invItem.itemName == itemName and invItem.slot == slot then
            invItem.quantity = invItem.quantity - quantity
            if invItem.quantity <= 0 then
                table.remove(inventory, i)
            end
            lib.callback.await("LGF_Inventory:dumpster:UpdateTableDumpster", false,
                { netId = dumpsterId, items = inventory })
            return true
        end
    end

    return false
end

function Dumpst.openDumpsterById(dumpsterId)
    if not dumpsterId or not DumpsterInventories[dumpsterId] then
        return false
    end

    local inventory = DumpsterInventories[dumpsterId]
    local moneyCount = 0
    for _, item in ipairs(inventory) do
        if item.itemName == "money" then
            moneyCount = moneyCount + item.quantity
        end
    end

    Client.openInventory({
        Display = true,
        InventoryItems = inventory,
        InventoryInfo = {
            maxWeight = 10,
            maxSlots = 20,
            inventoryName = ("Dumpster_%s"):format(dumpsterId),
            playerJob = "dumpsters",
            typeInventory = "dumpster",
            moneyCount = moneyCount
        }
    })
    return true
end

CreateThread(function()
    while true do
        Dumpst.initDumpster()
        Wait(30 * 60 * 1000)
    end
end)
