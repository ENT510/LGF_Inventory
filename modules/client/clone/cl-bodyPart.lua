local ReferenceAnim = {
    ["clothing_backpack"] = { dict = "anim@heists@ornate_bank@grab_cash", clip = "intro" },
    ["clothing_hat"]      = { dict = "misscommon@van_put_on_masks", clip = "put_on_mask_ps" },
    ["clothing_jacket"]   = { dict = "clothingshirt", clip = "try_shirt_positive_d" },
    ["clothing_pants"]    = { dict = "re@construction", clip = "out_of_breath" },
    ["clothing_shoes"]    = { dict = "random@domestic", clip = "pickup_low" },
}




Ped = nil
ClonedPed = nil

local function getFreemode(ped)
    local playerModel = GetEntityModel(ped)
    if playerModel == 1885233650 then
        return "m"
    elseif playerModel == -1667301416 then
        return "f"
    else
        return nil
    end
end


-- Synce The clonePed Action
local function syncClonedPed()
    if not ClonedPed then return end

    local playerPed = PlayerPedId()

    for i = 0, 11 do
        local drawable = GetPedDrawableVariation(playerPed, i)
        local texture = GetPedTextureVariation(playerPed, i)
        SetPedComponentVariation(ClonedPed, i, drawable, texture, 0)
    end

    for i = 0, 7 do
        local propIndex = GetPedPropIndex(playerPed, i)
        local propTexture = GetPedPropTextureIndex(playerPed, i)

        if propIndex ~= -1 then
            SetPedPropIndex(ClonedPed, i, propIndex, propTexture, true)
        else
            ClearPedProp(ClonedPed, i)
        end
    end
end


local function toggleComponent(drawableId, componentId, itemName, isProp)
    local ped = PlayerPedId()
    local animData = ReferenceAnim[itemName]
    local gender = getFreemode(ped)

    if animData then
        Functions.requestAnim(animData.dict)
        TaskPlayAnim(ped, animData.dict, animData.clip, 8.0, 8.0, 700, 0, 0, false, false, false)
        Wait(750)
        RemoveAnimDict(animData.dict)
    end

    local wornItems = LocalPlayer.state.itemsInserted or {}

    if isProp then
        if wornItems[itemName] then
            ClearPedProp(ped, componentId)
            wornItems[itemName] = nil
        else
            SetPedPropIndex(ped, componentId, drawableId, 0, true)
            wornItems[itemName] = true
        end
    else
        if wornItems[itemName] then
            if componentId == 6 then
                SetPedComponentVariation(ped, componentId, (gender == "m") and 34 or 35, 0, 0) -- Not sure for female
            elseif componentId == 4 then
                SetPedComponentVariation(ped, componentId, 14, 0, 0)
            else
                SetPedComponentVariation(ped, componentId, 0, 0, 0)
            end
            wornItems[itemName] = nil
        else
            SetPedComponentVariation(ped, componentId, drawableId, 0, 0)
            wornItems[itemName] = true
        end
    end

    LocalPlayer.state:set("itemsInserted", wornItems, true)
    syncClonedPed()
end

RegisterNuiCallback("LGF_Inventory:FetchItemBodyRemoved", function(data, cb)
    local ped = PlayerPedId()
    local gender = getFreemode(ped)
    local Items = Shared.getRegisteredItems()

    if Items[data.itemName] and Items[data.itemName].metadata then
        local Drawable = (gender == "m") and Items[data.itemName].metadata.maleDrawableId or
        Items[data.itemName].metadata.femaleDrawableId
        local Component = Items[data.itemName].metadata.componentId
        local isProp = (Component == 0)

        if Drawable and Component then
            toggleComponent(Drawable, Component, data.itemName, isProp)
        end
    end

    cb(true)
end)



function GetWornItems()
    return LocalPlayer.state.itemsInserted or {}
end
