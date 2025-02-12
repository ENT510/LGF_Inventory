Framework = {}
local Legacy = GetResourceState('LEGACYCORE'):find('start') and exports.LEGACYCORE:GetCoreData() or nil
if not Legacy then return end

function Framework.getPlayer()
    local Player = Legacy.DATA:GetPlayerObject()
    if not Player then return end
    return Player
end

-- Basically name dont change when player is already loaded [for my core im using a stateBag]
function Framework.getPlayerName()
    local PlayerData = LocalPlayer.state.GetPlayerObject
    if not PlayerData then return end
    return PlayerData.playerName
end

function Framework.getPlayerJobLabel()
    local PlayerData = Framework.getPlayer()
    if not PlayerData then return end
    return PlayerData.JobLabel
end

function Framework.playerLoaded()
    return Legacy.DATA:IsPlayerLoaded()
end

function Framework.getHunger()
    return exports.LEGACYCORE:GetPlayerHunger()
end

function Framework.getThirst()
    return exports.LEGACYCORE:GetPlayerThirst()
end

function Framework.setStatus(typeStatus, quantity)
    if typeStatus == 'thirst' then
        Legacy.DATA:UpdateStatus('thirst', math.random(10, 20))
    elseif typeStatus == 'hunger' then
        Legacy.DATA:UpdateStatus('hunger', math.random(10, 20))
    end
end
