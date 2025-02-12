Status = {}

function Status.getStatusInfo(ped)
    ped = ped or PlayerPedId()
    local hunger = math.ceil(Framework.getHunger())
    local thirst = math.ceil(Framework.getThirst())
    local stamina = math.ceil(GetPlayerStamina(PlayerId()))
    local armour = math.ceil(GetPedArmour(ped))

    local healt = GetEntityHealth(ped) - 100
    return {
        hunger = hunger,
        thirst = thirst,
        stamina = stamina,
        armour = armour,
        health = healt
    }
end
