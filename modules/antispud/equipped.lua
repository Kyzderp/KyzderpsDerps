KDD_AntiSpud = KDD_AntiSpud or {}
local Spud = KDD_AntiSpud

-- Some stuff yoinked from LibEquipmentBonus in Cooldowns by g4rr3t

-- Slots to monitor
local ITEM_SLOTS_FRONTBAR = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_MAIN_HAND,
    EQUIP_SLOT_OFF_HAND,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
}

local ITEM_SLOTS_BACKBAR = {
    EQUIP_SLOT_HEAD,
    EQUIP_SLOT_NECK,
    EQUIP_SLOT_CHEST,
    EQUIP_SLOT_SHOULDERS,
    EQUIP_SLOT_WAIST,
    EQUIP_SLOT_LEGS,
    EQUIP_SLOT_FEET,
    EQUIP_SLOT_RING1,
    EQUIP_SLOT_RING2,
    EQUIP_SLOT_HAND,
    EQUIP_SLOT_BACKUP_MAIN,
    EQUIP_SLOT_BACKUP_OFF,
}

local ITEM_SLOTS_MAIN = {
    [EQUIP_SLOT_HEAD] = "a hat",
    [EQUIP_SLOT_CHEST] = "a chest",
    [EQUIP_SLOT_SHOULDERS] = "shoulders",
    [EQUIP_SLOT_LEGS] = "panties",
    [EQUIP_SLOT_WAIST] = "a belt",
    [EQUIP_SLOT_HAND] = "gloves",
    [EQUIP_SLOT_FEET] = "shoes",
    [EQUIP_SLOT_NECK] = "an amulet",
    [EQUIP_SLOT_RING1] = "ring 1",
    [EQUIP_SLOT_RING2] = "ring 2",
}

-------------------------------------------------------------------------------
local function GetNumSetBonuses(itemLink)
    local _, _, _, equipType = GetItemLinkInfo(itemLink)
    -- 2H weapons, staves, bows count as two set pieces
    if equipType == EQUIP_TYPE_TWO_HAND then
        return 2
    else
        return 1
    end
end

-------------------------------------------------------------------------------
local function UpdateDisplay(error)
    if (error) then
        AntiSpudEquipped:SetHidden(false)
        AntiSpudEquippedLabel:SetText(error)
        AntiSpudEquipped:SetWidth(1000)
        AntiSpudEquipped:SetWidth(AntiSpudEquippedLabel:GetTextWidth())
        return true
    else
        AntiSpudEquipped:SetHidden(true)
        return false
    end
end

-------------------------------------------------------------------------------
local function CheckEmptySlots()
    local missing = {}
    for slot, name in pairs(ITEM_SLOTS_MAIN) do
        local itemLink = GetItemLink(BAG_WORN, slot)
        if (itemLink == "") then
            table.insert(missing, name)
        end
    end

    local frontMainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_MAIN_HAND)
    local frontOffLink = GetItemLink(BAG_WORN, EQUIP_SLOT_OFF_HAND)
    local backMainLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_MAIN)
    local backOffLink = GetItemLink(BAG_WORN, EQUIP_SLOT_BACKUP_OFF)

    if (frontMainLink == "" or (frontOffLink == "" and GetNumSetBonuses(frontMainLink) == 1)) then
        -- Nothing in main hand, or nothing in offhand when 1hander
        table.insert(missing, "a frontbar weapon")
    end

    if (backMainLink == "" or (backOffLink == "" and GetNumSetBonuses(backMainLink) == 1)) then
        table.insert(missing, "a backbar weapon")
    end

    if (#missing > 3) then
        return UpdateDisplay("You are nekkid")
    elseif (#missing > 0) then
        return UpdateDisplay("You are not wearing\n" .. table.concat(missing, ", "))
    else
        return UpdateDisplay()
    end
end

-------------------------------------------------------------------------------
local function CheckSlotsSets(slots)
    local equippedSets = {}
    for index, slot in pairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if (itemLink ~= "") then
            local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)
            if (hasSet) then
                if (not equippedSets[setName]) then
                    equippedSets[setName] = {}
                    equippedSets[setName].numEquipped = 0
                    equippedSets[setName].maxEquipped = maxEquipped
                end
                equippedSets[setName].numEquipped = equippedSets[setName].numEquipped + GetNumSetBonuses(itemLink)
            end
        end
    end

    local result = {}
    local error
    for setName, data in pairs(equippedSets) do
        local color = "0000FF"
        if (data.numEquipped == data.maxEquipped) then
            color = "FFFFFF"
        elseif (data.maxEquipped == 2) then
            -- Monster sets are ok
            -- TODO: wearing 1 pc of dual wield or snb would also be "ok"
            color = "FFFFFF"
        elseif (data.numEquipped <= 2) then
            -- If wearing 1 or 2 pieces of a 3 or 5 pc this is probably wrong
            color = "FF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped > data.maxEquipped) then
            -- Too many pieces
            color = "FF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped == 3) then
            -- 3 pieces is probably ok
            color = "FFFF00"
        elseif (data.numEquipped == 4) then
            -- 4 pieces is probably not correct
            color = "FF7700"
        end
        table.insert(result, zo_strformat("|c<<1>><<2>>|cFFFFFF <<C:4>>", color, data.numEquipped, data.maxEquipped, setName))
    end

    local resultString = table.concat(result, "|cAAAAAA / ") .. "|r"
    d(resultString)
    return UpdateDisplay(error)
end

function CheckAllSlots()
    -- Already has error
    if (CheckEmptySlots()) then
        return
    end
    if (CheckSlotsSets(ITEM_SLOTS_FRONTBAR)) then
        return
    end
    CheckSlotsSets(ITEM_SLOTS_BACKBAR)
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
function OnSlotUpdated(_, bagId, slotId)
    -- Ignore costume updates
    if slotId == EQUIP_SLOT_COSTUME then return end

    -- TODO: throttle it
    CheckAllSlots()
end

function Spud.InitializeEquipped()
    KyzderpsDerps:dbg("    Initializing AntiSpud Equipped...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdated)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    zo_callLater(CheckAllSlots, 2000)
end
