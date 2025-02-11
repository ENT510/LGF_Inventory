Status = {}

-- Basicalli here you can put Your Framework Status
function Status.getHunger()
    return exports.LEGACYCORE:GetPlayerHunger()
end

function Status.getThirst()
    return exports.LEGACYCORE:GetPlayerThirst()
end

function Status.getStatusInfo(ped)
    ped = ped or PlayerPedId()
    local hunger = math.ceil(Status.getHunger())
    local thirst = math.ceil(Status.getThirst())
    local stamina = math.ceil(GetPlayerStamina(PlayerId()))
    local armour = math.ceil(GetPedArmour(PlayerPedId()))

    local healt = GetEntityHealth(PlayerPedId()) - 100
    return {
        hunger = hunger,
        thirst = thirst,
        stamina = stamina,
        armour = armour,
        health = healt
    }
end

