local Framework = {}
local Legacy = GetResourceState('LEGACYCORE'):find('start') and exports.LEGACYCORE:GetCoreData() or nil


function Framework.getPlayer(src)
    local playerData = Legacy.DATA:GetPlayerDataBySlot(src)
    if not playerData then return end
    return playerData
end

function Framework.getIdentifier(src)
    local playerData = Framework.getPlayer(src)
    if playerData then
        return playerData.ientifier
    end
end

return Framework
