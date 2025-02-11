Functions = {}
local isScreenBlurActive = false

function Functions.manageBlur(data)
    if data.Display and not IsScreenFadingIn() and not isScreenBlurActive then
        TriggerScreenblurFadeIn(1000)
        isScreenBlurActive = true
    end

    if not data.Display and not IsScreenFadingOut() and isScreenBlurActive then
        DisableScreenblurFade()
        isScreenBlurActive = false
    end
end

function Functions.requestModel(model)
    local modelHash = model
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(0) end
    return modelHash
end

function Functions.createObjDrop(data)
    local modelHash = Functions.requestModel(data.model)

    local obj = CreateObject(modelHash, data.coords.x, data.coords.y, data.coords.z, true, false, false)

    SetModelAsNoLongerNeeded(modelHash)
    PlaceObjectOnGroundProperly(obj)
    FreezeEntityPosition(obj, true)
    SetEntityCollision(obj, false, true)
    return obj
end

function Functions.requestAnim(dictionary)
    RequestAnimDict(dictionary)
    while not HasAnimDictLoaded(dictionary) do
        Wait(0)
    end
end

function Functions.playAnim(data)
    local ped = PlayerPedId()
    local propObject

    local bone = data.prop.bone
    local model = Functions.requestModel(data.prop.model)
    propObject = CreateObject(model, GetEntityCoords(ped), true, false, false)

    AttachEntityToEntity(propObject, ped, GetPedBoneIndex(ped, bone),
        data.prop.pos.x, data.prop.pos.y, data.prop.pos.z,
        data.prop.rot.x, data.prop.rot.y, data.prop.rot.z,
        false, true, true, true, 0, true)

    Functions.requestAnim(data.animData.dictionary)

    TaskPlayAnim(ped, data.animData.dictionary, data.animData.clip, 8.0, 8.0, -1, 1, 0, false, false, false)

    SetTimeout(5000, function()
        ClearPedTasks(ped)
        RemoveAnimDict(data.animData.dictionary)
        if propObject then
            DeleteEntity(propObject)
        end
    end)
end

function Functions.canOpenInventory()
    local playerPed = PlayerPedId()

    if not Legacy.DATA:IsPlayerLoaded() then return false, "Character is not loaded" end
    if LocalPlayer.state.invIsOpen then return false, "Inventory already open" end
    if Config.isPlayerDead() or IsPedDeadOrDying(playerPed, true) then return false, "Player is dead" end
    if IsPauseMenuActive() then return false, "Pause menu is active" end
    if IsPedRagdoll(playerPed) then return false, "Player is ragdoll" end
    if IsPedCuffed(playerPed) then return false, "Player is cuffed" end
    if IsPedFalling(playerPed) then return false, "Player is falling" end
    if IsPedInParachuteFreeFall(playerPed) then return false, "Player is parachuting" end

    return true, nil
end

function Functions.requestStreamText(dict)
    RequestStreamedTextureDict(dict, true)
    while not HasStreamedTextureDictLoaded(dict) do
        Wait(0)
    end
end

function Functions.drawSpriteRef(coords)
    local Info = { dict = "shared", texture = "emptydot_32", width = 0.02, height = 0.02 * GetAspectRatio(false) }

    local r, g, b, a = 128, 0, 128, 100
    SetDrawOrigin(coords.x, coords.y, coords.z - 0.5)
    DrawSprite(Info.dict, Info.texture, 0, 0, Info.width, Info.height, 0, r, g, b, a)
    ClearDrawOrigin()
end


