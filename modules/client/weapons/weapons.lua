Weapon = {}
local wheelEnabled = false
local DataEquiped = {}

function Weapon.setWheelState(enabled)
    if enabled == nil then enabled = wheelEnabled end
    SetWeaponsNoAutoswap(not enabled)
    SetWeaponsNoAutoreload(not enabled)
    wheelEnabled = enabled
    if enabled then
        return N_0x762db2d380b48d04(1 << 0 | 1 << 1 | 1 << 2 | 1 << 3 | 1 << 7 | 1 << 10)
    else
        return N_0xf92099527db8e2a7(1 << 0 | 1 << 1 | 1 << 2 | 1 << 3 | 1 << 7 | 1 << 10, true)
    end
end

function Weapon.getWheelState()
    return wheelEnabled
end

function Weapon.EquipWeapon(itemData)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(itemData.itemName)
    if GetSelectedPedWeapon(ped) == weaponHash then return weaponHash end


    DataEquiped = itemData

    local dict = 'reaction@intimidation@1h'
    Functions.requestAnim(dict)
    local currentAmmo = itemData.metadata and itemData.metadata.CurrentAmmo or 0

    TaskPlayAnimAdvanced(ped, dict, "intro", GetEntityCoords(ped), 0, 0, GetEntityHeading(ped), 8.0, 3.0, 1200, 50, 0.1)

    SetTimeout(600 * 2, function()
        GiveWeaponToPed(ped, weaponHash, itemData.quantity, false, true)
        SetCurrentPedWeapon(ped, weaponHash, true)
        SetPedCurrentWeaponVisible(ped, true, true, false, false)
        SetWeaponsNoAutoswap(true)

        SetPedAmmo(ped, weaponHash, math.min(GetWeaponClipSize(weaponHash), currentAmmo))

        TriggerEvent('LGF_Inventory:weapon:CurrentWeapon', GetSelectedPedWeapon(ped))
    end)

    return weaponHash
end

function Weapon.ToggleWeapon(itemData)
    local ped = PlayerPedId()
    local weaponHash = GetHashKey(itemData.itemName)
    local currentWeapon = GetSelectedPedWeapon(ped)

    if currentWeapon == weaponHash then
        Weapon.DisarmWeapon()
    else
        Weapon.EquipWeapon(itemData)
    end
end

function DisableShootingControls()
    local ped = PlayerPedId()
    if IsPedArmed(ped, 4) then
        DisableControlAction(1, 140, true)
        DisableControlAction(1, 141, true)
        DisableControlAction(1, 142, true)
    end
end

function Weapon.ReloadWeapon()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)
    local PlayerItems = Client.PlayerInventory
    local ammoType, ammoAmount = nil, 0

    for _, item in ipairs(PlayerItems) do
        local itemHash = GetHashKey(item.itemName)
        if itemHash == currentWeapon then
            ammoType = item.typeAmmo
            break
        end
    end

    if not ammoType then return end

    for _, item in ipairs(PlayerItems) do
        if tostring(item.itemName) == tostring(ammoType) then
            ammoAmount = item.quantity
            break
        end
    end

    if ammoAmount == 0 then return end

    local clipSize = GetWeaponClipSize(currentWeapon)
    local ammoInWeapon = GetAmmoInPedWeapon(ped, currentWeapon)
    local ammoNeeded = math.min(clipSize - ammoInWeapon, ammoAmount)


    if ammoNeeded > 0 then
        TaskReloadWeapon(ped, true)
        Wait(500)
        SetPedAmmo(ped, currentWeapon, ammoInWeapon + ammoNeeded)
        local success = lib.callback.await('LGF_Inventory:removeAmmo', true, ammoType, ammoNeeded)
    end
end

AddEventHandler('CEventGunShot', function(_, ped)
    if IsPedCurrentWeaponSilenced(PlayerPedId()) then return end

    local currentWeapon = GetSelectedPedWeapon(ped)
    local ammoInWeapon = GetAmmoInPedWeapon(ped, currentWeapon)


    TriggerEvent('LGF_Inventory:isPedShooting', DataEquiped.itemLabel, ammoInWeapon, DataEquiped.itemName,
        DataEquiped.typeAmmo, DataEquiped.metadata.Serial)
end)

RegisterNetEvent("LGF_Inventory:isPedShooting", function()
    local playerPed = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(playerPed)
    local ammoInWeapon = GetAmmoInPedWeapon(playerPed, currentWeapon)

    if DataEquiped and DataEquiped.metadata and DataEquiped.metadata.Serial then
        local serial = DataEquiped.metadata.Serial
        lib.callback.await('LGF_Inventory:updateAmmoCount', false, serial, ammoInWeapon)
    else
        print("Errore: DataEquiped non definito o serial mancante.")
    end
end)

function Weapon.isArmed()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)


    if currentWeapon == 0 then
        return false, nil
    end

    if DataEquiped then
        return true, DataEquiped
    else
        return true, nil
    end
end

function Weapon.DisarmWeapon()
    local ped = PlayerPedId()
    local currentWeapon = GetSelectedPedWeapon(ped)
    if currentWeapon and currentWeapon ~= 0 then
        RemoveWeaponFromPed(ped, currentWeapon)
        ClearPedSecondaryTask(ped)
        SetPedAmmo(ped, currentWeapon, 0)

        DataEquiped = {}

        TriggerEvent('LGF_Inventory:weapon:CurrentWeapon', nil)
    end
end

function DISABLE_ANDRELOAD()
    DisableShootingControls()
    Weapon.ReloadWeapon()
end

RegisterCommand("+reload_weapon", function()
    DISABLE_ANDRELOAD()
end, false)

RegisterKeyMapping("+reload_weapon", "Ricarica Arma", "keyboard", "r")




-- local ThrownWeapons = {}

-- local throwingWeapon = false

-- local function getCamDir(cameraRotation)
--     local radians = { x = math.rad(cameraRotation.x), y = math.rad(cameraRotation.y), z = math.rad(cameraRotation.z) }
--     return {
--         x = -math.sin(radians.z) * math.abs(math.cos(radians.x)),
--         y = math.cos(radians.z) *
--             math.abs(math.cos(radians.x)),
--         z = math.sin(radians.x)
--     }
-- end

-- function Weapon.ThrowWeapon()
--     if throwingWeapon then return end
--     local ped = PlayerPedId()
--     local equipped, weaponHash = GetCurrentPedWeapon(ped, 1)
--     if not equipped or weaponHash == `WEAPON_UNARMED` then return end

--     local weaponModel = GetWeaponObjectFromPed(ped, true)
--     if not weaponModel then return end

--     throwingWeapon = true

--     local animDict = "melee@thrown@streamed_core"
--     local animName = "plyr_takedown_front"
--     TaskPlayAnim(ped, animDict, animName, 8.0, -8.0, -1, 49, 0, false, false, false)


--     Wait(600)
--     ClearPedTasks(ped)


--     local coords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)
--     local thrownProp = CreateObject(GetEntityModel(weaponModel), coords.x, coords.y, coords.z, true, true, false)

--     RemoveWeaponFromPed(ped, weaponHash)
--     SetCurrentPedWeapon(ped, `WEAPON_UNARMED`, true)
--     DeleteEntity(weaponModel)

--     local rot = GetGameplayCamRot(2)
--     local dir = getCamDir(rot)
--     SetEntityVelocity(thrownProp, dir.x * 15, dir.y * 15, dir.z * 5)



--     local netId = ObjToNet(thrownProp)
--     ThrownWeapons[netId] = { weapon = weaponHash, entity = thrownProp }

--     TriggerServerEvent("LGF_Inventory:weaponThrown", netId, weaponHash)
--     throwingWeapon = false
-- end

-- AddEventHandler("onResourceStop", function(res)
--     if GetCurrentResourceName() == res then
--         for netId, data in pairs(ThrownWeapons) do
--             if DoesEntityExist(data.entity) then
--                 DeleteEntity(data.entity)
--             end
--         end
--         ThrownWeapons = {}
--     end
-- end)


-- RegisterCommand("throwWeapon", function()
--     Weapon.ThrowWeapon()
-- end, false)

-- RegisterKeyMapping("throwWeapon", "Lancia Arma", "keyboard", "g")


exports("disarmWeapon", Weapon.DisarmWeapon)
exports("getWheelState", Weapon.getWheelState)
