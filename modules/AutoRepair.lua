KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
-- Find repair kit
---------------------------------------------------------------------
local function FindRepairKitFor(equipBagId, equipSlotId)
    local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
    for _, item in pairs(bagCache) do
        -- Don't use bound (crown/group) repair kits
        if (IsItemRepairKit(item.bagId, item.slotIndex) and not IsItemBound(item.bagId, item.slotIndex)) then
            -- Use a repair kit that... probably isn't a petty repair kit
            local repairAmount = GetAmountRepairKitWouldRepairItem(equipBagId, equipSlotId, item.bagId, item.slotIndex)
            if (repairAmount >= 5) then
                return item.bagId, item.slotIndex, repairAmount
            end
        end
    end
end

---------------------------------------------------------------------
-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
---------------------------------------------------------------------
local function OnDurabilityUpdate(_, bagId, slotId, _, _, inventoryUpdateReason, _)
    if (GetItemCondition(bagId, slotId) > 1) then
        return
    end

    -- Can't repair while dead or reincarnating, so delay and keep checking it
    if (IsUnitDeadOrReincarnating("player")) then
        KyzderpsDerps:dbg("delaying repair because dead or reincarnating")
        zo_callLater(function()
                OnDurabilityUpdate(_, bagId, slotId, _, _, inventoryUpdateReason, _)
            end, 1000)
        return
    end

    local repairBagId, repairSlotId, repairAmount = FindRepairKitFor(bagId, slotId)
    if (not repairBagId) then
        KyzderpsDerps:msg(string.format("No repair kit to repair %s with!", GetItemLink(bagId, slotId)))
        return
    end

    RepairItemWithRepairKit(bagId, slotId, repairBagId, repairSlotId)
    KyzderpsDerps:msg(string.format("Repaired %s with %s for %d%% durability.", GetItemLink(bagId, slotId), GetItemLink(repairBagId, repairSlotId), repairAmount))
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function KyzderpsDerps.InitializeAutoRepair()
    KyzderpsDerps:dbg("    Initializing AutoRepair module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "DurabilityUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnDurabilityUpdate)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "DurabilityUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DURABILITY_CHANGE)
end