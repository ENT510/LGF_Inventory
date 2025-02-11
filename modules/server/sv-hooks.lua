HookManager = {
    hooks = {},
    inventoryEventData = {}
}

function HookManager:RegisterHook(eventType, callback)
    self.hooks[eventType] = { callback = callback }
end

function HookManager:ExecuteHook(eventType, eventData)
    local hook = self.hooks[eventType]
    if not hook then return true end
    return hook.callback(eventData)
end

function HookManager:RemoveHook(eventType)
    self.hooks[eventType] = nil
end

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

function HookManager:MonitorHooks(eventData, playerId)
    self.inventoryEventData = eventData
    self:ProcessInventoryAction(playerId)
end

RegisterNetEvent("LGF_Inventory:Hooks:MonitorHooks")
AddEventHandler("LGF_Inventory:Hooks:MonitorHooks", function(eventData)
    HookManager:MonitorHooks(eventData, source)
end)

exports("registerServerHook", function(eventType, callback)
    HookManager:RegisterHook(eventType, callback)
end)

exports("removeServerHook", function(eventType)
    HookManager:RemoveHook(eventType)
end)
