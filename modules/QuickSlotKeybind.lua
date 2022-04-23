KyzderpsDerps = KyzderpsDerps or {}

local indexToSlotIndex = {
    [1] = 12,
    [2] = 11,
    [3] = 10,
    [4] =  9,
    [5] = 16,
    [6] = 15,
    [7] = 14,
    [8] = 13,
}

local slotIndexToIndex = {
    [12] = 1,
    [11] = 2,
    [10] = 3,
}

local indexToSlotIndex_highIsle = {
    [1] = 4,
    [2] = 3,
    [3] = 2,
}

local slotIndexToIndex_highIsle = {
    [4] = 1,
    [3] = 2,
    [2] = 3,
}

---------------------------------------------------------------------
-- High Isle PTS compatibility
---------------------------------------------------------------------
local function GetIndexToSlotIndex()
    if (GetAPIVersion() >= 101034) then
        return indexToSlotIndex_highIsle
    else
        return indexToSlotIndex
    end
end

local function GetSlotIndexToIndex()
    if (GetAPIVersion() >= 101034) then
        return slotIndexToIndex_highIsle
    else
        return slotIndexToIndex
    end
end

local function GetIndexTexture(index)
    if (GetAPIVersion() >= 101034) then
        -- Quickslot revamp
        return GetSlotTexture(GetIndexToSlotIndex()[index], HOTBAR_CATEGORY_QUICKSLOT_WHEEL)
    else
        return GetSlotTexture(GetIndexToSlotIndex()[index])
    end
end

---------------------------------------------------------------------
local function UpdateSlots()
    for index = 1, 3 do
        local control = KDDQuickSlot:GetNamedChild("Slot" .. tostring(index)):GetNamedChild("Texture")
        local texture = GetIndexTexture(index)
        if (texture ~= "") then
            control:SetTexture(texture)
            control:SetHidden(false)
        else
            control:SetHidden(true)
        end
    end
end

local function SetBackground(index, highlighted)
    local control = KDDQuickSlot:GetNamedChild("Slot" .. tostring(index)):GetNamedChild("Backdrop")
    control:SetHidden(not highlighted)
    -- if (highlighted) then
    --     control:SetCenterColor(0, 1, 0, 0.5)
    -- else
    --     control:SetCenterColor(0, 0, 0, 0.5)
    -- end
end

local function OnSlotChanged(_, actionSlotIndex)
    SetBackground(1, false)
    SetBackground(2, false)
    SetBackground(3, false)

    local index = GetSlotIndexToIndex()[actionSlotIndex]
    if (index) then
        SetBackground(index, true)
    end
end

function KyzderpsDerps.SelectQuickSlot(index)
    SetCurrentQuickslot(GetIndexToSlotIndex()[index])
    PlaySound(SOUNDS.QUICKSLOT_SET)
    -- d(GetUnitWorldPosition("reticleover"))
end

function KyzderpsDerps.InitializeQuickSlots()
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "QuickSlot", EVENT_ACTIVE_QUICKSLOT_CHANGED, OnSlotChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ArmoryEquippedQuickSlot", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, UpdateSlots)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ActionSlotUpdated", EVENT_ACTION_SLOT_UPDATED, UpdateSlots)

    if (GetAPIVersion() >= 101034) then
        KDDQuickSlot:SetParent(QuickslotButton)
        KDDQuickSlot:SetAnchor(BOTTOMLEFT, QuickslotButton, TOPLEFT, -2, -2)
    else
        KDDQuickSlot:SetParent(ZO_ActionBar1)
    end

    UpdateSlots()
    OnSlotChanged(0, GetCurrentQuickslot())
    KDDQuickSlot:SetHidden(not KyzderpsDerps.savedOptions.quickSlots.enable)
end
