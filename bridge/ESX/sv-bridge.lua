Framework = {}
local ESX = GetResourceState('es_extended'):find('start') and exports.es_extended:getSharedObject() or nil
if not ESX then return end


function Framework.getPlayer(src)
    local playerData = ESX.GetPlayerFromId(src)
    if not playerData then return end
    return playerData
end

function Framework.getIdentifier(src)
    local player = Framework.getPlayer(src)
    if not player then return end
    return player.identifier
end

function Framework.getCharId(src)
    -- local identifier = Framework.getIdentifier(src)
    -- if not identifier then return end
    -- local charId = identifier:match("char(%d+):")
    -- if not charId then return end
    -- return tonumber(charId)
    return nil --- fallback, basically use directly identifier with prefix char:
end

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
    Inventory.loadInventory(playerId, false)
end)

-- Probably player return the source player but i dont have a server ESX to test this
RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    local src = source
    Inventory.loadInventory(src, true)
end)
