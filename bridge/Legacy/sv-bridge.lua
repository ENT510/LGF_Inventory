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
