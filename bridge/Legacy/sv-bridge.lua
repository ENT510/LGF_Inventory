Framework = {}
local Legacy = GetResourceState('LEGACYCORE'):find('start') and exports.LEGACYCORE:GetCoreData() or nil


function Framework.getPlayer(src)
    local playerData = Legacy.DATA:GetPlayerDataBySlot(src)
    if not playerData then return end
    return playerData
end

function Framework.getIdentifier(src)
    return GetPlayerIdentifierByType(src, "license")
end

function Framework.getCharId(src)
    return Legacy.DATA:GetPlayerCharSlot(src)
end

RegisterNetEvent('LegacyCore:PlayerLoaded')
AddEventHandler('LegacyCore:PlayerLoaded', function(slot, data, newPlayer)
    CurrentCharId[data.source] = slot
    Inventory.loadInventory(data.source, true)
end)

RegisterNetEvent('LegacyCore:PlayerLogout')
AddEventHandler('LegacyCore:PlayerLogout', function()
    local playerId = source
    Inventory.loadInventory(playerId, false)
end)
