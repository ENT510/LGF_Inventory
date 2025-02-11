Framework = {}
local Legacy = GetResourceState('LEGACYCORE'):find('start') and exports.LEGACYCORE:GetCoreData() or nil
if not Legacy then return end

function Framework.getPlayer()
    local Player = Legacy.DATA:GetPlayerObject()
    if not Player then return end
    return Player
end

function Framework.playerLoaded()
    return Legacy.DATA:IsPlayerLoaded()
end
