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

local function UpdateSlots()
    for index = 1, 3 do
        local control = KDDQuickSlot:GetNamedChild("Slot" .. tostring(index)):GetNamedChild("Texture")
        local texture = GetSlotTexture(indexToSlotIndex[index])
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

    local index = slotIndexToIndex[actionSlotIndex]
    if (index) then
        SetBackground(index, true)
    end
end

function KyzderpsDerps.SelectQuickSlot(index)
    SetCurrentQuickslot(indexToSlotIndex[index])
    PlaySound(SOUNDS.QUICKSLOT_SET)
    -- d(GetUnitWorldPosition("reticleover"))
end

function KyzderpsDerps.InitializeQuickSlots()
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "QuickSlot", EVENT_ACTIVE_QUICKSLOT_CHANGED, OnSlotChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ArmoryEquippedQuickSlot", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, UpdateSlots)

    QUICKSLOT_FRAGMENT:RegisterCallback("StateChange", UpdateSlots)

    UpdateSlots()
    OnSlotChanged(0, GetCurrentQuickslot())
    KDDQuickSlot:SetHidden(not KyzderpsDerps.savedOptions.quickSlots.enable)
end
