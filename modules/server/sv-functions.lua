Functions       = {}
PlayerInventory = {}
Drops           = {}
CurrentCharId   = {}


local SAVE_DB_INTERVAL = Init.Convar.Server.SAVE_DB_INTERVAL
local Query            = {}

if GetResourceState("LEGACYCORE"):find("start") then
    Query["getInventory"] = 'SELECT playerInventory FROM users WHERE identifier = ? AND charIdentifier = ?'
    Query["updateInventory"] = 'UPDATE users SET playerInventory = ? WHERE identifier = ? AND charIdentifier = ?'
elseif GetResourceState("es_extended"):find("start") then
    Query["getInventory"] = 'SELECT playerInventory FROM users WHERE identifier = ? '
    Query["updateInventory"] = 'UPDATE users SET playerInventory = ? WHERE identifier = ?'
elseif GetResourceState("qbx_core"):find("start") then

end


function Functions.getInventory(target)
    local identifier = Framework.getIdentifier(target)

    local charId = CurrentCharId[target]

    if PlayerInventory[target] then
        return PlayerInventory[target]
    end

    local query = Query["getInventory"]
    local result

    if charId then
        result = MySQL.query.await(query, { identifier, charId })
    else
        result = MySQL.query.await(query, { identifier })
    end

    if result and result[1] then
        local playerInventory = result[1].playerInventory
        local inventory = json.decode(playerInventory)
        PlayerInventory[target] = inventory
        return inventory
    end

    return nil
end

-- Used only For Internal Usage
---@Deprecated use Inventory.removeItem()
function Functions.removeItem(target, data)
    local playerInventory = Array.getPlayerInv(target)

    if playerInventory then
        for i, item in ipairs(playerInventory) do
            if item.slot == data.slot and item.itemName == data.itemName then
                item.quantity = item.quantity - data.quantity

                if item.quantity <= 0 then
                    table.remove(playerInventory, i)
                end
                break
            end
        end

        PlayerInventory[target] = playerInventory
        TriggerClientEvent("LGF_Inventory:RemoveItem", target, data)
        Wait(100)
        TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, target, PlayerInventory[target])
    end
end

function Functions.generateWeaponSerial()
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local serial = ""
    for _ = 1, 10 do
        local randIndex = math.random(1, #chars)
        serial = serial .. chars:sub(randIndex, randIndex)
    end
    return ("#%s"):format(serial)
end

function Functions.updateInventory(target, items)
    local identifier = Framework.getIdentifier(target)
    local inventoryJson = json.encode(items)
    local query = Query["updateInventory"]
    local charId = CurrentCharId[target]

    local affectedRows = MySQL.update.await(query, { inventoryJson, identifier, charId })

    PlayerInventory[target] = items

    return affectedRows ~= nil
end

function Functions.autoUpdateInventory()
    local lastUpdate = os.time()

    CreateThread(function()
        while true do
            Wait(1000)

            local currentTime = os.time()
            if currentTime - lastUpdate >= SAVE_DB_INTERVAL then
                local allPlayers = GetPlayers()
                for I = 1, #allPlayers do
                    local targetID = tonumber(allPlayers[I])
                    local inventory = Array.getPlayerInv(targetID)
                    Functions.updateInventory(targetID, inventory)
                    TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, targetID, inventory)
                end
                lastUpdate = currentTime
            end
        end
    end)
end

function Functions.tabledeepClone(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = Functions.tabledeepClone(orig_value)
        end
        setmetatable(copy, Functions.tabledeepClone(getmetatable(orig)))
    else
        copy = orig
    end
    return copy
end

-- [[ Populate Inventory Table, Preventing call Every time Database to Get Item]]
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        local allPlayers = GetPlayers()
        for I = 1, #allPlayers do
            local targetID = tonumber(allPlayers[I])

            CurrentCharId[targetID] = Framework.getCharId(targetID)

            if not CurrentCharId[targetID] then return end

            local inventories = Functions.getInventory(targetID)
            SetTimeout(1000, function()
                TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, targetID, inventories)
            end)
        end
    end
end)


Functions.autoUpdateInventory()
