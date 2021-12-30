KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

---------------------------------------------------------------------
-- Keeping track
---------------------------------------------------------------------
local chestsLooted = 0

local function UpdateDisplay()
    KDDInfoPanel:SetWidth(150)
    KDDInfoPanelChestsLabel:SetWidth(150)
    KDDInfoPanelChestsLabel:SetText(string.format("%d chest%s looted", chestsLooted, chestsLooted == 1 and "" or "s"))
    KDDInfoPanelChestsLabel:SetWidth(KDDInfoPanelChestsLabel:GetTextWidth())
    KDDInfoPanel:SetWidth(KDDInfoPanelChestsLabel:GetTextWidth() + 8)
end

local function ResetCounter()
    KyzderpsDerps:dbg(string.format("You have looted %d chests. Resetting counter.", chestsLooted))
    chestsLooted = 0
    UpdateDisplay()
end
Spam.ResetCounter = ResetCounter

local function OnChestLooted()
    KyzderpsDerps:dbg("Interacted with chest.")
    chestsLooted = chestsLooted + 1
    UpdateDisplay()
end

---------------------------------------------------------------------
-- On interact key
---------------------------------------------------------------------
local lastChestTime = 0
local function OnStartInteract()
    local interactText, mainText, _, isOwned = GetGameCameraInteractableActionInfo()

    -- Looting a chest
    if ((mainText == "Chest" and interactText == "Use") and not isOwned) then
        local currentTimeStamp = GetTimeStamp()
        if (currentTimeStamp - lastChestTime > 3) then
            OnChestLooted()
            lastChestTime = currentTimeStamp
        end
    end
end


---------------------------------------------------------------------
-- Zoning
---------------------------------------------------------------------
local prevZoneId
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    if (prevZoneId ~= zoneId) then
        ResetCounter()
    end

    prevZoneId = zoneId
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spam.InitializeInteract()
    ZO_PreHook(FISHING_MANAGER, "StartInteraction", OnStartInteract)

    -- Must do this separately, or else every attempt to pick lock will be an interact
    EVENT_MANAGER:RegisterForEvent(Spam.name .. "LockSuccess", EVENT_LOCKPICK_SUCCESS, OnStartInteract)

    EVENT_MANAGER:RegisterForEvent(Spam.name .. "FinderComplete", EVENT_ACTIVITY_FINDER_ACTIVITY_COMPLETE, function()
        d("finder complete")
        -- ResetCounter()
    end)

    EVENT_MANAGER:RegisterForEvent(Spam.name .. "LFGJoined", EVENT_GROUPING_TOOLS_LFG_JOINED, function(_, locationName)
        d("lfg joined " .. locationName)
        ResetCounter()
    end)

    EVENT_MANAGER:RegisterForEvent(Spam.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    -- UI
    KDDInfoPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.chestsLooted.x, KyzderpsDerps.savedValues.chestsLooted.y)
    HUD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(KDDInfoPanel))
    HUD_UI_SCENE:AddFragment(ZO_SimpleSceneFragment:New(KDDInfoPanel))
    UpdateDisplay()

    -- TODO: add a setting for showing info panel
end
