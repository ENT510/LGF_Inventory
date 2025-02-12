Client                             = {}
LocalPlayer.state.invIsOpen        = false
LocalPlayer.state.hotBarIsOpen     = false
LocalPlayer.state.playerListIsOpen = false
Client.PlayerInventory             = {}
PlayerInventories                  = {}
Client.currentPedClone             = nil
Client.currentItems                = {}

local ENABLE_SCREENBLUR            = Init.Convar.Client.ENABLE_SCREENBLUR
local MAX_SLOT_INV                 = Init.Convar.Shared.MAX_SLOT_INV
local MAX_INV_WEIGHT               = Init.Convar.Shared.MAX_INV_WEIGHT


local confiscatedStates = {}

function Client.openInventory(data)
    if confiscatedStates[GetPlayerServerId(PlayerId())] then
        Shared.notification("Inventory Confiscated", "Your inventory has been confiscated.", "warning")
        return
    end


    LocalPlayer.state.invIsOpen = data.Display
    SendNUIMessage({ action = "openInventory", data = data })
    SetNuiFocus(data.Display, data.Display)
    if ENABLE_SCREENBLUR then Functions.manageBlur(data) end

    Client.currentPedClone = data.Ped ~= nil and data.Ped or PlayerPedId()

    if data.Display then
        CreatePedScreen(Client.currentPedClone)
    else
        removePreviewPed()
    end
end

function Client.openPlayerList(display, itemName, itemQuantity, slot, metadata)
    LocalPlayer.state.playerListIsOpen = display
    SetNuiFocus(display, display)


    local nearbyPlayers = Shared.nearbyPlayers(GetEntityCoords(PlayerPedId()), 5.0)
    local Players = {}

    for i = 1, #nearbyPlayers do
        local player = nearbyPlayers[i]
        local GetNearbyName = lib.callback.await("LGF_Inventory:GetNameForOpenInv", false, player.playerId)
        local playerData = {
            id = player.playerId,
            name = GetNearbyName,
            distance = player.playerDistance
        }
        Players[#Players + 1] = playerData
    end

    SendNUIMessage({
        action = "openPlayerList",
        data = {
            Display = display,
            Players = Players,
            Item = {
                itemName = itemName,
                itemQuantity = itemQuantity,
                slot = slot,
                metadata = metadata
            }
        }
    })
end

function Client.openTargetInventory(target, screenPed)
    local NearbyItems = PlayerInventories[target]
    local ped = nil
    local GetNearbyName = lib.callback.await("LGF_Inventory:GetNameForOpenInv", false, target)

    Client.currentItems = NearbyItems or {}

    if screenPed then
        PlayerT = GetPlayerFromServerId(target)
        if PlayerT and PlayerT ~= -1 then
            ped = GetPlayerPed(PlayerT)
        end
    end


    Client.openInventory({
        Display = true,
        InventoryItems = NearbyItems,
        InventoryInfo = { maxWeight = MAX_INV_WEIGHT, maxSlots = MAX_SLOT_INV, inventoryName = GetNearbyName, typeInventory = "other_player", source = target },
        Ped = ped,
    })
end

function Client.setNotifyItems(data)
    data.Display = true
    SendNUIMessage({ action = "setNotificationItems", data = data })
end

RegisterNetEvent("LGF_Inventory:Admin:OpenInventoryTarget", function(target)
    local id = type(target) == "number" and target or tonumber(target)
    Client.openTargetInventory(id, true)
end)


function Client.toggleHotbar(state)
    LocalPlayer.state.hotBarIsOpen = state
    local sortedItems = {}
    for slot = 1, 5 do
        local item = Inventory.getItemFromSlot(slot)
        if item then
            table.insert(sortedItems, item)
        end
    end

    SendNUIMessage({ action = "toggleHotbar", data = { Display = state, Items = sortedItems } })
end

function Client.closeInv()
    Client.openInventory({
        Display = false,
        InventoryItems = Client.currentItems,
        InventoryInfo = { maxWeight = MAX_INV_WEIGHT, maxSlots = MAX_SLOT_INV, playerStatus = Status.getStatusInfo() },
    })

    Client.currentItems = {}
end

RegisterNuiCallback("LGF_Inventory:Nui:CloseInventory", function(data, cb)
    cb(1)
    if data.name == "openInventory" then
        Client.closeInv()
    elseif data.name == "openPlayerList" then
        Client.openPlayerList(false)
    end
end)

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        removePreviewPed()
        SetStreamedTextureDictAsNoLongerNeeded("shared")
        local isArmed, weaponData = Weapon.isArmed()
        if isArmed then
            RemoveAllPedWeapons(PlayerPedId(), true)
        end
    end
end)

-- Sync with all Client the Target Inventory action
-- And Populate The client Inventory

RegisterNetEvent("LGF_Inventory:SyncTablePlayer", function(targetInventory, inventory, isConfiscated)
    confiscatedStates[targetInventory] = isConfiscated or false


    if type(inventory) ~= "table" then
        inventory = {}
    end

    local formattedInventory = {}

    for _, item in pairs(inventory) do
        if type(item) == "table" and item.itemName then
            table.insert(formattedInventory, item)
        end
    end

    PlayerInventories[targetInventory] = formattedInventory

    if targetInventory == GetPlayerServerId(PlayerId()) then
        Client.PlayerInventory = formattedInventory
    end
end)


local function registerBarToggle()
    if LocalPlayer.state.hotBarIsOpen then
        Client.toggleHotbar(false)
    else
        Client.toggleHotbar(true)
    end
end

RegisterNetEvent("LGF_Inventory:closeInventory", function()
    Client.closeInv()
end)

local function registerHotbarBind()
    local commandName = ('__%s__toggle_hotbar_+++'):format(GetCurrentResourceName())
    RegisterCommand(commandName, function() registerBarToggle() end, false)
    RegisterKeyMapping(commandName, 'Open/Close Hotbar', 'keyboard', Init.Convar.Client.HOTBAR_TOGGLE_KEY)
end

local function registerInventoryToggle()
    local resourceName = GetCurrentResourceName()
    local commandName = ('_%s___toggle_inventory_+++'):format(resourceName)
    RegisterCommand(commandName, function()
        if not LocalPlayer.state.invIsOpen then
            Client.PlayerInventory = Inventory.getPersonalInventory() or
                lib.callback.await("LGF_Inventory:GetPlayerInv", false)
            local sourceName = Framework.getPlayerName()
            local sourceJob = Framework.getPlayerJobLabel()


            print(sourceJob)

            Client.currentItems = Client.PlayerInventory

            local canOpen, reason = Functions.canOpenInventory()
            if not canOpen then
                print(("^1[ERROR]^7 Cannot open inventory: ^1%s^7"):format(reason))
                return
            end

            Client.openInventory({
                Display = true,
                InventoryItems = Client.currentItems,
                InventoryInfo = {
                    maxWeight = MAX_INV_WEIGHT,
                    maxSlots = MAX_SLOT_INV,
                    inventoryName = sourceName,
                    playerStatus = Status.getStatusInfo(),
                    playerJob = sourceJob,
                    typeInventory = "personal",
                    source = GetPlayerServerId(PlayerId()),
                    moneyCount = Inventory.getMoneyCount()
                },
            })
        end
    end, false)

    RegisterKeyMapping(
        ('_%s___toggle_inventory_+++'):format(GetCurrentResourceName()),
        'Open/Close Inventory',
        'keyboard',
        Init.Convar.Client.INVENTORY_TOGGLE_KEY
    )
end



CreateThread(function()
    registerHotbarBind()
    registerInventoryToggle()
end)


return Client
