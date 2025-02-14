Init = {}
Init.Convar = {}
local serverContext = IsDuplicityVersion()
local CurrentResource = GetCurrentResourceName()

if not LoadResourceFile(CurrentResource, 'web/build/index.html') then
    error('Missing UI Build. Please build lgf_inventory or download the latest release already built.')
end

-- Convert Getters int to boolean using Lua's ternary operator.
function Init.intToBool(value) return value ~= 0 end

Init.Convar.Shared = {
    MAX_SLOT_INV           = GetConvarInt("lgf_inventory:maxSlotInv", 10),
    MAX_INV_WEIGHT         = GetConvarInt("lgf_inventory:maxInvWeight", 20),
    ENABLE_DEBUG_INVENTORY = Init.intToBool(GetConvarInt("lgf_inventory:enableDebug", 1)),
    RANDOM_DROP_TRUNKS     = Init.intToBool(GetConvarInt("lgf_inventory:randomDropTrunks", 1)),
    RANDOM_DROP_DUMPSTERS  = Init.intToBool(GetConvarInt("lgf_inventory:randomDropDumpsters", 1))
}

if serverContext then
    Init.Convar.Server = {
        SAVE_DB_INTERVAL = GetConvarInt("lgf_inventory:save_interval", 120)
    }
else
    Init.Convar.Client = {
        ENABLE_SCREENBLUR      = Init.intToBool(GetConvarInt("lgf_inventory:screenBlur", 1)),
        DROP_OBJECT_MODEL      = GetConvar("lgf_inventory:dropModel", "hei_p_f_bag_var6_bus_s"),
        ENABLE_SPRITE_DROP     = Init.intToBool(GetConvarInt("lgf_inventory:enableSpriteDrop", 1)),
        HOTBAR_TOGGLE_KEY      = GetConvar("lgf_inventory:hotbarKey", "f9"),
        INVENTORY_TOGGLE_KEY   = GetConvar("lgf_inventory:inventoryKey", "f3"),
        ENABLE_AMMO_CHARGERDUI = Init.intToBool(GetConvarInt("lgf_inventory:enableAmmoChargerDui", 1))
    }
end

