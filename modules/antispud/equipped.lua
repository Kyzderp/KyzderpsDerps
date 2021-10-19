KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

-- Throttle for chat spam
local throttling = false
local lastThrottle = 0

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
local function UpdateDisplay(error, extraText)
    if (error) then
        AntiSpudEquipped:SetHidden(false)
        AntiSpudEquippedLabel:SetText((extraText ~= nil) and (error .. extraText) or error)
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

    if (GetUnitLevel("player") >= GetWeaponSwapUnlockedLevel()) then
        if (backMainLink == "" or (backOffLink == "" and GetNumSetBonuses(backMainLink) == 1)) then
            table.insert(missing, "a backbar weapon")
        end
    end

    if (#missing > 3) then
        return UpdateDisplay("You are nekkid")
    elseif (#missing > 0) then
        return UpdateDisplay("You have not slotted\n" .. table.concat(missing, ", "))
    else
        return UpdateDisplay()
    end
end

-------------------------------------------------------------------------------
local function CheckSlotsSets(slots, extraText, hasError, skipThrottle)
    -- d(extraText .. tostring(hasError) .. tostring(skipThrottle))
    local equippedSets = {}
    for index, slot in pairs(slots) do
        local itemLink = GetItemLink(BAG_WORN, slot)

        if (itemLink ~= "") then
            local hasSet, setName, _, _, maxEquipped = GetItemLinkSetInfo(itemLink, true)
            setName = string.gsub(setName, "^Perfected ", "")
            setName = string.gsub(setName, "^Perfect ", "")
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
        local color = "|c0000FF"
        if (data.numEquipped == data.maxEquipped) then
            color = ""
        elseif (data.maxEquipped == 2) then
            -- Monster sets are ok
            -- TODO: wearing 1 pc of dual wield or snb would also be "ok"
            color = ""
        elseif (data.maxEquipped == 3 and data.numEquipped == 2) then
            -- 3pc sets like Willpower, Endurance, are probably ok with 2 pieces
            color = "|cFFFF00"
        elseif (data.numEquipped == 1) then
            -- If wearing 1 piece of a 3 or 5 pc this is probably wrong
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> piece of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped == 2) then
            -- If wearing 2 pieces of a 5 pc this is probably wrong
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped > data.maxEquipped) then
            -- Too many pieces
            color = "|cFF0000"
            error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
        elseif (data.numEquipped == 3) then
            -- 3 pieces is probably ok
            color = "|cFFFF00"
        elseif (data.numEquipped == 4) then
            -- 4 pieces is probably not correct, but check the exception list
            if (KyzderpsDerps.savedOptions.antispud.equipped.fourPieceExceptions[setName]) then
                color = "|cFF7700"
            else
                color = "|cFF0000"
                error = zo_strformat("You are wearing <<1>> pieces of\n<<2>>", data.numEquipped, setName)
            end
        end
        table.insert(result, zo_strformat("<<1>><<2>><<3>> <<C:4>>", color, data.numEquipped, (color == "") and "" or "|cAAAAAA", setName))
    end

    local resultString = table.concat(result, " / ")
    if (skipThrottle) then
        if (KyzderpsDerps.savedOptions.antispud.equipped.printToChat) then
            KyzderpsDerps:msg("Equipped" .. extraText .. ": " .. resultString)
        end
        Spud.UpdateBuffTheGroup(equippedSets)
        if (hasError) then return true end
        return UpdateDisplay(error, extraText)
    end

    -- some throttling to not spam chat on every change
    local currTime = GetGameTimeMilliseconds()
    if (not throttling) then
        throttling = true
    elseif (currTime - lastThrottle > 150) then
        lastThrottle = currTime
    else
        if (hasError) then return true end
        return UpdateDisplay(error, extraText)
    end

    EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "EquippedThrottle" .. extraText)
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "EquippedThrottle" .. extraText, 200, function()
        throttling = false
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "EquippedThrottle" .. extraText)

        -- Gear has finished changing
        CheckSlotsSets(slots, extraText, hasError, true)
    end)
    if (hasError) then return true end
    return UpdateDisplay(error, extraText)
end

function CheckAllSlots()
    -- Already has error
    local hasError = false
    if (CheckEmptySlots()) then
        hasError = true
    end
    if (CheckSlotsSets(ITEM_SLOTS_FRONTBAR, " on frontbar", hasError, false)) then
        hasError = true
    end
    if (GetUnitLevel("player") >= GetWeaponSwapUnlockedLevel()) then
        CheckSlotsSets(ITEM_SLOTS_BACKBAR, " on backbar", hasError, false)
    end
end

-- EVENT_INVENTORY_SINGLE_SLOT_UPDATE (number eventCode, Bag bagId, number slotId, boolean isNewItem, ItemUISoundCategory itemSoundCategory, number inventoryUpdateReason, number stackCountChange)
function OnSlotUpdated(_, bagId, slotId)
    -- Ignore costume updates, poison updates
    if (slotId == EQUIP_SLOT_COSTUME or slotId == EQUIP_SLOT_POISON or slotId == EQUIP_SLOT_BACKUP_POISON) then return end

    CheckAllSlots()
end

function Spud.InitializeEquipped()
    KyzderpsDerps:dbg("    Initializing AntiSpud Equipped...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OnSlotUpdated)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,
        REGISTER_FILTER_BAG_ID, BAG_WORN,
        REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)

    zo_callLater(CheckAllSlots, 1000)
end

function Spud.UninitializeEquipped()
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "SpudEquipped", EVENT_INVENTORY_SINGLE_SLOT_UPDATE)
    AntiSpudEquipped:SetHidden(true)
end
