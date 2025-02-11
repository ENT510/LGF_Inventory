Array = {}

function Array.getPlayerInv(target)
    return PlayerInventory[target]
end

exports("getPlayerItems", Array.getPlayerInv)
