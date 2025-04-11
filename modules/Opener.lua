KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Opener = KyzderpsDerps.Opener or {}
local Opener = KyzderpsDerps.Opener

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
        SCENE_MANAGER:GetCurrentScene().name == "mailInbox" or
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
    if (toLoot[itemId] and not IsItemStolen(bagId, slotId)) then
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
function Opener.Initialize()
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
    if (KyzderpsDerps.savedOptions.opener.openPurpleZenithar) then
        toLoot[187701] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openZenitharCurrency) then
        toLoot[187700] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox and (KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC or not IsInImperialCity())) then
        toLoot[192612] = true
        shouldRegister = true
    end
    if (KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull) then
        toLoot[190037] = true
        shouldRegister = true
    end
    -- Probably don't do this, because it's stolen
    -- if (KyzderpsDerps.savedOptions.opener.openEmberWallet) then
    --     toLoot[187747] = true
    --     shouldRegister = true
    -- end

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


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function Opener.GetSettings()
    return {
        {
            type = "slider",
            name = "Delay before opening",
            tooltip = "Number of milliseconds to wait after obtaining a lootable container, before attempting to open it",
            min = 0,
            max = 2000,
            step = 100,
            default = 0,
            width = "full",
            getFunc = function() return KyzderpsDerps.savedOptions.opener.delay end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.delay = value
            end,
        },
        {
            type = "checkbox",
            name = "Auto open Hidden Treasure Bag",
            tooltip = "When you loot a Hidden Treasure Bag from Mirri's bonus, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openMirriBag end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openMirriBag = value
                Opener.Initialize()
            end,
            width = "full",
        },
        -- {
        --     type = "checkbox",
        --     name = "Auto open Hidden Wallet",
        --     tooltip = "When you loot a Hidden Wallet from Ember's bonus, automatically open and loot it",
        --     default = false,
        --     getFunc = function() return KyzderpsDerps.savedOptions.opener.openEmberWallet end,
        --     setFunc = function(value)
        --         KyzderpsDerps.savedOptions.opener.openEmberWallet = value
        --         Opener.Initialize()
        --     end,
        --     width = "full",
        -- },
        {
            type = "checkbox",
            name = "Auto open Wet Gunny Sack",
            tooltip = "When you loot a Wet Gunny Sack from fishing, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openGunnySack end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openGunnySack = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Toxin Satchel",
            tooltip = "When you loot a Toxin Satchel, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openToxinSatchel end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openToxinSatchel = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Zenithar's Delightful Parcel",
            tooltip = "When you loot a (purple) Zenithar's Delightful Parcel, automatically open and loot it. Will NOT loot stolen ones!",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPurpleZenithar end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPurpleZenithar = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Zenithar's Bounty",
            tooltip = "When you loot a Zenithar's Bounty (the gold bag containing currency), automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openZenitharCurrency end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openZenitharCurrency = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Auto open Pelinal's Boon Box",
            tooltip = "When you loot a Pelinal's Boon Box, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox = value
                Opener.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "    ... in Imperial City",
            tooltip = "Toggles whether to open Pelinal's boxes while in Imperial City, since the boxes can contain some Tel Var",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPelinalsBoonBoxInIC = value
                Opener.Initialize()
            end,
            width = "full",
            disabled = function() return not KyzderpsDerps.savedOptions.opener.openPelinalsBoonBox end,
        },
        {
            type = "checkbox",
            name = "Auto open purple Plunder Skull",
            tooltip = "When you loot a purple Plunder Skull, automatically open and loot it",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.opener.openPurplePlunderSkull = value
                Opener.Initialize()
            end,
            width = "full",
        },
    }
end
