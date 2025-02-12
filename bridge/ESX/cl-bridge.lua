Framework = {}
local ESX = GetResourceState('es_extended'):find('start') and exports.es_extended:getSharedObject() or nil
if not ESX then return end


function Framework.getPlayer()
    local Player = ESX.GetPlayerData()
    if not Player then return end
    return Player
end

function Framework.getPlayerName()
    local xPlayer = Framework.getPlayer()
    return xPlayer and ("%s %s"):format(xPlayer?.firstName, xPlayer?.lastName)
end

function Framework.getPlayerJobLabel()
    local PlayerData = Framework.getPlayer()
    if not PlayerData then return end
    return PlayerData.job.label
end

function Framework.playerLoaded()
    return ESX.IsPlayerLoaded()
end

function Framework.getHunger()
    local p = promise:new()

    local hunger = nil
    TriggerEvent('esx_status:getStatus', "hunger", function(status)
        if status then
            hunger = (status.val / 10000)
            p:resolve(hunger)
        end
    end)
    return Citizen.Await(p)
end

function Framework.getThirst()
    local p = promise:new()

    local thirst = nil
    TriggerEvent('esx_status:getStatus', "thirst", function(status)
        if status then
            thirst = (status.val / 10000)
            p:resolve(thirst)
        end
    end)
    return Citizen.Await(p)
end

function Framework.setStatus(typeStatus, quantity)
    if typeStatus == 'thirst' then

    elseif typeStatus == 'hunger' then

    end
end
