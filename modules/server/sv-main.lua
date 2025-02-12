RegisterNetEvent('LegacyCore:PlayerLoaded')
AddEventHandler('LegacyCore:PlayerLoaded', function(slot, data, newPlayer)
    print("slot", slot)
    local playerId = source
    CurrentCharId[playerId] = slot
    local inventory = Functions.getInventory(playerId)

    SetTimeout(2000, function()
        TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, playerId, inventory)
    end)
end)

RegisterNetEvent('LegacyCore:PlayerLogout')
AddEventHandler('LegacyCore:PlayerLogout', function()
    local playerId = source

    Functions.updateInventory(playerId, PlayerInventory[playerId])

    PlayerInventory[playerId] = nil
    CurrentCharId[playerId] = nil

    SetTimeout(500, function()
        TriggerClientEvent("LGF_Inventory:SyncTablePlayer", -1, playerId, PlayerInventory[playerId])
    end)
end)
