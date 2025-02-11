function CreatePedScreen(ped)
    if ClonedPed then return end
    Ped = ped

    CreateThread(function()
        SetFrontendActive(true)
        ActivateFrontendMenu("FE_MENU_VERSION_EMPTY_NO_BACKGROUND", true, -1)
        Wait(300)

        local x, y, z = table.unpack(GetEntityCoords(Ped))
        ClonedPed = ClonePed(Ped)

        SetEntityCoords(ClonedPed, x + 50, y + 21, z - 100)
        FreezeEntityPosition(ClonedPed, true)
        SetEntityVisible(ClonedPed, false, false)
        ReplaceHudColourWithRgba(117, 0, 0, 0, 0)
        NetworkSetEntityInvisibleToNetwork(ClonedPed, false)
        Wait(200)

        GivePedToPauseMenu(ClonedPed, 2)
        SetPauseMenuPedLighting(true)
        SetPauseMenuPedSleepState(false)
        Wait(1000)
        SetPauseMenuPedSleepState(true)

        SetMouseCursorVisible(false)
    end)
end

function removePreviewPed()
    if ClonedPed then
        SetFrontendActive(false)
        FreezeEntityPosition(ClonedPed, false)
        SetEntityVisible(ClonedPed, true, false)
        DeleteEntity(ClonedPed)
        ClonedPed = nil
        Ped = nil
    end
end
