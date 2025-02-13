if not Init.Convar.Client.ENABLE_AMMO_CHARGERDUI then return end

local resource                  = GetCurrentResourceName()
local Url                       = ('nui://%s/web/build/index.html'):format(resource)
local screenWidth, screenHeight = GetActiveScreenResolution()

WeaponsDui                      = {
    currentAmmo  = nil,
    maxAmmo      = nil,
    weaponLabel  = nil,
    spriteActive = false
}

AddEventHandler("onResourceStart", function(res)
    if resource == res then
        WeaponsDui.Dui = lib.dui:new({
            url = Url,
            width = screenWidth,
            height = screenHeight,
            debug = true
        })
    end
end)

function WeaponsDui.draw3DSprite(coords)
    if not WeaponsDui.spriteActive then return end

    local maxDistance = 5.0
    local distance = #(GetEntityCoords(PlayerPedId()) - coords)
    if distance > maxDistance then return end
    local scale = math.max(0.1, 1.5 / distance)
    scale = math.min(scale, 1.0)

    SetDrawOrigin(coords.x, coords.y, coords.z, false)
    DrawInteractiveSprite(WeaponsDui.Dui.dictName, WeaponsDui.Dui.txtName, 0, 0, scale, scale, 0.0, 255, 255, 255, 255)
    ClearDrawOrigin()
end

function WeaponsDui.showAmmoCharger(state)
    if WeaponsDui.Dui then
        WeaponsDui.Dui:sendMessage({
            action = "toggleInventoryAmmoCharg",
            data = { Display = state }
        })
    end
end

function WeaponsDui.updateAmmoCharger(data)
    if WeaponsDui.Dui then
        WeaponsDui.currentAmmo = data.CurrentAmmo
        WeaponsDui.maxAmmo = data.MaxAmmo
        WeaponsDui.weaponLabel = data.WeaponLabel

        WeaponsDui.Dui:sendMessage({
            action = "updateAmmoChargerInventory",
            data = {
                CurrentAmmo = WeaponsDui.currentAmmo,
                MaxAmmo = WeaponsDui.maxAmmo,
                ColorCube = "#3b5bdb",
                WeaponLabel = WeaponsDui.weaponLabel
            }
        })
    end
end

RegisterNetEvent('LGF_Inventory:weapon:CurrentWeapon', function(data)
    if not data or not data.itemData then
        WeaponsDui.spriteActive = false
        return
    end

    local Sleep = 1000

    WeaponsDui.updateAmmoCharger({
        CurrentAmmo = data.currentAmmo,
        MaxAmmo = GetWeaponClipSize(GetHashKey(data.itemData.itemName)),
        WeaponLabel = data.itemData.itemLabel
    })

    if not WeaponsDui.spriteActive then
        WeaponsDui.spriteActive = true

        CreateThread(function()
            while WeaponsDui.spriteActive do
                Wait(Sleep)

                if IsPlayerFreeAiming(PlayerId()) then
                    Sleep = 0
                    local handCoords = GetWorldPositionOfEntityBone(cache.ped, 71)
                    WeaponsDui.draw3DSprite(vec3(handCoords.x, handCoords.y, handCoords.z + 0.2))
                else
                    Sleep = 1000
                end
            end
        end)
    end
end)

RegisterNetEvent('LGF_Inventory:isPedShooting', function(itemLabel, ammoInWeapon, itemName, typeAmmo, serial)
    WeaponsDui.updateAmmoCharger({
        CurrentAmmo = ammoInWeapon,
        MaxAmmo = GetWeaponClipSize(GetHashKey(itemName)),
        WeaponLabel = itemLabel
    })
end)
