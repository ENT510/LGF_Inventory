Config                  = {}

-- Put your exports/variables here to check if the player is dead
-- If use ars_ambulanceJob is altready setted
Config.isPlayerDead     = function()
    return LocalPlayer.state.dead
end

Config.inventoryCommand = {
    AddItem       = { CommandName = "addItem" },
    ClearInv      = { CommandName = "clearInventory" },
    OpenTargetInv = { CommandName = "openInventory" },
    ConfiscateInv = { CommandName = "confiscate" },
}
