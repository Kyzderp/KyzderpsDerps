KDD_QuickSlots = {}

local indexToSlotIndex = {
    [1] = 12,
    [2] = 11,
    [3] = 10,
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

function KDD_QuickSlots:SelectSlot(index)
    SetCurrentQuickslot(indexToSlotIndex[index])
    PlaySound(SOUNDS.QUICKSLOT_SET)
    -- d(GetUnitWorldPosition("reticleover"))
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

function KDD_QuickSlots:Initialize()
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_1", "Select Quickslot 1")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_2", "Select Quickslot 2")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_3", "Select Quickslot 3")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "QuickSlot", EVENT_ACTIVE_QUICKSLOT_CHANGED, OnSlotChanged)

    QUICKSLOT_FRAGMENT:RegisterCallback("StateChange", function(oldState, newState)
        UpdateSlots()
    end)

    UpdateSlots()
    OnSlotChanged(0, GetCurrentQuickslot())
    KDDQuickSlot:SetHidden(not KyzderpsDerps.savedOptions.quickSlots.enable)
end
