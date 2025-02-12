--- HookManager module to manage event hooks with unique identifiers.
--- @class HookManager
local HookManager = {
    hooks = {},
    inventoryEventData = {}
}

local currentId = 0
local function generateUniqueId()
    currentId = currentId + 1
    return ("hook_%s_%s"):format(tostring(currentId), GetCurrentResourceName())
end


--- Registers a hook for a specific event type with a unique identifier.
--- @param eventType string The type of event (e.g., 'move', 'split', "removeItem", "addItem").
--- @param callback function The function to call when the event occurs.
--- @return string
function HookManager:RegisterHook(eventType, callback)
    local id = generateUniqueId()
    if not self.hooks[eventType] then
        self.hooks[eventType] = {}
    end
    self.hooks[eventType][id] = callback
    return id
end

--- Executes all hooks registered for a specific event type.
--- @param eventType string The type of event to execute.
--- @param eventData table The data associated with the event.
--- @return boolean True if all hooks executed successfully; false if any hook returned false.
function HookManager:ExecuteHook(eventType, eventData)
    local hooksForEvent = self.hooks[eventType]
    if not hooksForEvent then return true end
    for id, callback in pairs(hooksForEvent) do
        local result = callback(eventData)
        if result == false then
            return false
        end
    end
    return true
end

--- Removes a specific hook for an event type using its unique identifier.
--- @param eventType string The event type associated with the hook.
--- @param id string The unique identifier of the hook to remove.
function HookManager:RemoveHook(eventType, id)
    if self.hooks[eventType] then
        self.hooks[eventType][id] = nil
        if next(self.hooks[eventType]) == nil then
            self.hooks[eventType] = nil
        end
    end
end

--- Processes an inventory action for a player.
--- @param playerId number The ID of the player.
function HookManager:ProcessInventoryAction(playerId)
    if self.inventoryEventData.action then
        local actionDetails = {
            source = playerId,
            actionType = self.inventoryEventData.action,
            fromSlot = self.inventoryEventData.fromSlot,
            toSlot = self.inventoryEventData.toSlot,
            itemData = self.inventoryEventData.movedItem,
            timestamp = os.date("%Y-%m-%d %H:%M:%S")
        }

        local executionResult = self:ExecuteHook(self.inventoryEventData.action, actionDetails)

        TriggerClientEvent("LGF_Inventory:Hooks:ActionResult", playerId, executionResult)
    end
end

--- Monitors hooks for an inventory event.
--- @param eventData table The inventory event data.
--- @param playerId number The ID of the player.
function HookManager:MonitorHooks(eventData, playerId)
    self.inventoryEventData = eventData
    self:ProcessInventoryAction(playerId)
end

RegisterNetEvent("LGF_Inventory:Hooks:MonitorHooks")
AddEventHandler("LGF_Inventory:Hooks:MonitorHooks", function(eventData)
    HookManager:MonitorHooks(eventData, source)
end)


exports("registerServerHook", function(eventType, callback)
    return HookManager:RegisterHook(eventType, callback)
end)


exports("removeServerHook", function(eventType, id)
    HookManager:RemoveHook(eventType, id)
end)
