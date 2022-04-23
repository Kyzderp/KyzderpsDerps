KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
local toLoot = {}
local toLootNames = {} -- Will be populated when a container is opened, to verify LootAll on correct container


---------------------------------------------------------------------
-- Loot All items once the container is opened
---------------------------------------------------------------------
local function OnOpenLootWindow()
    -- KyzderpsDerps:dbg("update loot window")
    local title = GetLootTargetInfo()
    if (toLootNames[title]) then
        LootAll()
    end
end


---------------------------------------------------------------------
-- Open the container
---------------------------------------------------------------------
local function CanOpenContainer()
    if (GetSlotCooldownInfo(1) > 0 or 
        IsInteractionUsingInteractCamera() or 
        SCENE_MANAGER:GetCurrentScene().name == "interact" or 
        IsUnitSwimming("player") or
        IsUnitInCombat("player") or
        IsLooting()) then
        return false
    else
        return true
    end
end

local function OpenContainer(bagId, slotId)
    if (CanOpenContainer()) then
        KyzderpsDerps:dbg("trying to open container")
        if IsProtectedFunction("UseItem") then
            CallSecureProtected("UseItem", bagId, slotId)
        else
            UseItem(bagId, slotId)
        end 
    else
        KyzderpsDerps:dbg("waiting to open container")
        zo_callLater(function()
            OpenContainer(bagId, slotId)
        end, 1000)
    end
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
local function OnInventorySlotUpdate(_, bagId, slotId, isNewItem, _, _, _)
    local itemId = GetItemId(bagId, slotId)
    if (toLoot[itemId]) then
        toLootNames[GetItemName(bagId, slotId)] = true
        zo_callLater(function()
            OpenContainer(bagId, slotId)
        end, KyzderpsDerps.savedOptions.opener.delay)
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local prehooked = false
function KyzderpsDerps.InitializeOpener()
    KyzderpsDerps:dbg("    Initializing Opener module...")

    toLoot = {}
    toLootNames = {}
    local shouldRegister = false
    if (KyzderpsDerps.savedOptions.opener.openMirriBag) then
        toLoot[178470] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openGunnySack) then
        toLoot[43757] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openToxinSatchel) then
        toLoot[79675] = true
        shouldRegister = true
    end

    if (shouldRegister) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnInventorySlotUpdate)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

        if (not prehooked) then
            ZO_PreHook(SYSTEMS:GetObject("loot"), "UpdateLootWindow", OnOpenLootWindow)
            prehooked = true
        end
    else
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "OpenerSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    end
end
