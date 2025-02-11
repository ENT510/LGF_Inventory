Shared = {}

function Shared.debugInventory(...)
    if not Init.Convar.Shared.ENABLE_DEBUG_INVENTORY then return end
    return print("^5[LGF_INVENTORY]^7 " .. table.concat({ ... }, " "))
end

function Shared.getRegisteredItems()
    if Shared.CachedItems then return Shared.CachedItems end
    local Items = assert(require("shared.items"), "^1[ERROR] Failed to load 'shared.items'!")
    assert(type(Items) == "table", "^1[ERROR] 'shared.items' is not a valid table!")

    Shared.CachedItems = Items

    local itemCount = 0
    for _ in pairs(Items) do itemCount += 1 end

    Shared.debugInventory(("Loaded ^5%s^7 items"):format(itemCount))

    return Shared.CachedItems
end

CreateThread(Shared.getRegisteredItems)


function Shared.notification(title, message, notifType, source)
    notifType = notifType or "inform"

    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', source, {
            title = title,
            description = message,
            type = notifType,
            duration = 5000,
            position = "top-right",
        })
    else
        lib.notify({
            title = title,
            description = message,
            type = notifType,
            duration = 5000,
            position = "top-right",
        })
    end
end

function Shared.nearbyPlayers(startCoords, maxDistance)
    local nearbyPlayers = {}
    local players = GetActivePlayers()
    local count = 0
    maxDistance = maxDistance or 2.0

    for i = 1, #players do
        local playerId = players[i]
        local serverId = GetPlayerServerId(playerId)
        local playerCoords = GetEntityCoords(GetPlayerPed(playerId))
        if playerCoords then
            local distance = #(startCoords - playerCoords)
            if distance <= maxDistance then
                count = count + 1
                nearbyPlayers[count] = { playerId = serverId, playerDistance = distance, playerPed= GetPlayerPed(playerId)}
            end
        end
    end

    return nearbyPlayers
end

RegisterCommand("checkNearby", function()
    local myCoords = GetEntityCoords(PlayerPedId())      -- Ottiene le coordinate del giocatore locale
    local players = Shared.nearbyPlayers(myCoords, 10.0) -- Cerca i giocatori entro 10 metri

    print(json.encode(players, { indent = true }))
end, false)


exports("getItems", Shared.getRegisteredItems)
