if not Init.Convar.Shared.RANDOM_DROP_TRUNKS then
    return
end


local TrunkInventories = {}
Trunk = {}
function Trunk.GetTrunkInventory(plate)
    return TrunkInventories[plate] or {}
end

function Trunk.UpdateTrunkInventory(plate, items)
    TrunkInventories[plate] = items
end

RegisterNetEvent("LGF_Inventory:Trunk:UpdateInventory", function(data)
    if data.plate and data.items then
        TrunkInventories[data.plate] = data.items
    end
end)

function Trunk.OpenTrunkInventory()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle then return end

    local plate = GetVehicleNumberPlateText(vehicle)
    local inventory = Trunk.GetTrunkInventory(plate)

    Client.openInventory({
        Display = true,
        InventoryItems = inventory,
        InventoryInfo = {
            maxWeight = 50,
            maxSlots = 30,
            inventoryName = ("Trunk_%s"):format(plate),
            playerJob = "trunk",
            typeInventory = "trunk"
        }
    })
end


