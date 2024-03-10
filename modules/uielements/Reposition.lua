KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.UIElements = KyzderpsDerps.UIElements or {}
local UIE = KyzderpsDerps.UIElements

--[[
/script
local bg = WINDOW_MANAGER:CreateControl("$(parent)BG", ZO_LootHistoryControl_Keyboard, CT_BACKDROP)
bg:SetAnchorFill(ZO_LootHistoryControl_Keyboard)
bg:SetCenterColor(0, 0, 0, 0.5)
bg:SetEdgeColor(0,0,0,1)
]]
local function Reposition()

    -- Attributes: move health up a bit to put stam and mag in pyramid
    ZO_PlayerAttributeHealth:SetAnchor(CENTER, ZO_PlayerAttribute, CENTER, 0, -33)
    ZO_PlayerAttributeStamina:SetAnchor(LEFT, ZO_PlayerAttribute, CENTER, 2, -6)
    ZO_PlayerAttributeMagicka:SetAnchor(RIGHT, ZO_PlayerAttribute, CENTER, -2, -6)

    -- Loot History: move up above minimap
    ZO_LootHistoryControl_Keyboard:SetAnchor(BOTTOMRIGHT, GuiRoot, BOTTOMRIGHT, 0, -290)

    -- Synergies: move up a bit
    ZO_SynergyTopLevelContainer:SetAnchor(BOTTOM, ZO_SynergyTopLevel, BOTTOM, 0, -300)

    -- Player Interaction: move up a bit
    ZO_PlayerToPlayerAreaPromptContainer:SetAnchor(BOTTOM, ZO_PlayerToPlayerArea, BOTTOM, 0, -350)

    -- Subtitles: is anchored to ZO_PlayerToPlayerAreaPromptContainerTarget so should be fine

    -- Ram Siege: move up a bit
    ZO_RamTopLevel:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -300)

    -- AvA Meter
    ZO_ObjectiveCaptureMeter:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -300)

    -- Combat Tips
    ZO_ActiveCombatTipsTip:SetAnchor(BOTTOM, GuiRoot, BOTTOM, 0, -300)
end

local function ToggleQuestPanel()
    local isInTrial = KyzderpsDerps.TRIAL_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))] ~= nil

    ZO_FocusedQuestTrackerPanel:SetHidden(isInTrial)
end

function UIE.Initialize()
    Reposition()

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "UIEActivated", EVENT_PLAYER_ACTIVATED, ToggleQuestPanel)
end
