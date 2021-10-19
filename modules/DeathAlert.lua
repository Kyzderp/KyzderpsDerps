KyzderpsDerps = KyzderpsDerps or {}

-- Number of milliseconds after which deaths will disappear
local TIMER_EXPIRY = 3000

-- Currently unused controls for deaths: {[1] = "@Kyzeragon"}
local freeControls = {}

-- Create a new control for death alerts, for when multiple are displayed at the same time. Returns the index
local function CreateNewControl()
    local fontSize = KyzderpsDerps.savedOptions.deathAlert.size
    local index = #freeControls + 1
    local deathControl = CreateControlFromVirtual(
        "$(parent)Death" .. tostring(index),  -- name
        DeathAlertContainer,           -- parent
        "DeathAlert_Line_Template",    -- template
        "")                            -- suffix
    deathControl:SetHeight(zo_floor(fontSize * 1.2))
    deathControl:SetWidth(fontSize * 20)
    deathControl:SetAnchor(CENTER, DeathAlertContainer, CENTER, 0, (index - 1) * zo_floor(fontSize * 1.2))

    local label = deathControl:GetNamedChild("Label")
    label:SetFont("$(BOLD_FONT)|" .. tostring(fontSize) .. "|soft-shadow-thick")
    label:SetHeight(zo_floor(fontSize * 1.2))
    label:SetWidth(fontSize * 20)

    -- Animation
    local animation, timeline = CreateSimpleAnimation(ANIMATION_SCALE, deathControl, 0)
    animation:SetScaleValues(1, 1.2)
    animation:SetDuration(300)
    deathControl.animation = animation
    deathControl.timeline = timeline
    deathControl.timeline:SetPlaybackType(ANIMATION_PLAYBACK_PING_PONG, 1)

    return index
end

-- Return the index of the control to be used
local function FindOrCreateControl(displayName)
    for i, name in pairs(freeControls) do
        if (displayName == name or name == "") then
            return i
        end
    end
    return CreateNewControl()
end

-- Get the string containing texture for the group role
local function GetRoleString(LFGRole)
    local fontSize = tostring(KyzderpsDerps.savedOptions.deathAlert.size)
    local prefix = "|t" .. fontSize .. ":" .. fontSize .. ":"
    if (LFGRole == LFG_ROLE_DPS) then
        return prefix .. "esoui/art/lfg/lfg_dps_down.dds|t"
    elseif (LFGRole == LFG_ROLE_HEAL) then
        return prefix .. "esoui/art/lfg/lfg_healer_down.dds|t"
    elseif (LFGRole == LFG_ROLE_TANK) then
        return prefix .. "esoui/art/lfg/lfg_tank_down.dds|t"
    else
        return ""
    end
end

--  EVENT_UNIT_DEATH_STATE_CHANGED (number eventCode, string unitTag, boolean isDead)
local function OnDeathStateChanged(_, unitTag, isDead)
    -- Companions show up as unitTag = "group5companion" for group members' and "companion" for self
    if (isDead and KyzderpsDerps.savedOptions.deathAlert.enable and string.match(unitTag, "^group%d+$")) then
        local displayName = GetUnitDisplayName(unitTag)
        local deathText = GetRoleString(GetGroupMemberSelectedRole(unitTag)) .. displayName .. " is dead!"

        local index = FindOrCreateControl(displayName)
        local deathControl = DeathAlertContainer:GetNamedChild("Death" .. tostring(index))

        freeControls[index] = displayName
        deathControl:GetNamedChild("Label"):SetText(deathText)
        deathControl:SetHidden(false)
        deathControl.timeline:PlayFromStart()
        -- /script BUI.OnScreen.NotificationSecondary("test","test".." "..BUI.Loc("GroupMemberDead"))

        -- Hide it
        EVENT_MANAGER:RegisterForUpdate("KDD_HideDeath" .. tostring(index), TIMER_EXPIRY, function()
            deathControl:SetHidden(true)
            freeControls[index] = ""
            EVENT_MANAGER:UnregisterForUpdate("KDD_HideDeath" .. tostring(index))
        end)
    end
end

---------------------------------------------------------------------
function KyzderpsDerps.ChangeDeathAlertFontSize()
    -- If there aren't any controls yet, we need to create them so they're actually visible
    if (#freeControls == 0) then
        CreateNewControl()
        freeControls[1] = ""
        CreateNewControl()
        freeControls[2] = ""
    elseif (#freeControls == 1) then
        CreateNewControl()
        freeControls[2] = ""
    end

    DeathAlertContainer:GetNamedChild("Death1"):GetNamedChild("Label"):SetText(GetRoleString(LFG_ROLE_TANK) .. "@Player1 is dead!")
    DeathAlertContainer:GetNamedChild("Death2"):GetNamedChild("Label"):SetText(GetRoleString(LFG_ROLE_DPS) .. "@ExamplePlayer is dead!")

    -- Change all the current ones
    local fontSize = KyzderpsDerps.savedOptions.deathAlert.size
    for i, name in pairs(freeControls) do
        local deathControl = DeathAlertContainer:GetNamedChild("Death" .. tostring(i))
        deathControl:SetHidden(false)
        deathControl:SetHeight(zo_floor(fontSize * 1.2))
        deathControl:SetWidth(fontSize * 20)
        deathControl:SetAnchor(CENTER, DeathAlertContainer, CENTER, 0, (i - 1) * zo_floor(fontSize * 1.2))

        local label = deathControl:GetNamedChild("Label")
        label:SetFont("$(BOLD_FONT)|" .. tostring(fontSize) .. "|soft-shadow-thick")
        label:SetText(string.gsub(label:GetText(), "%d%d:", tostring(fontSize) .. ":"))
        label:SetHeight(zo_floor(fontSize * 1.2))
        label:SetWidth(fontSize * 20)
    end
end

function KyzderpsDerps.HideAllDeathAlert(currentpanel)
    if (currentpanel ~= KyzderpsDerps.addonPanel) then return end
    -- Hide all death controls
    for i, name in pairs(freeControls) do
        local deathControl = DeathAlertContainer:GetNamedChild("Death" .. tostring(i))
        deathControl:SetHidden(true)
    end
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeDeathAlert()
    KyzderpsDerps:dbg("    Initializing DeathAlert module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "DeathAlertDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)

    -- Initialize position
    DeathAlertContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.deathAlert.x, KyzderpsDerps.savedValues.deathAlert.y)
    DeathAlertContainer:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.enable)
    DeathAlertContainer:SetMouseEnabled(KyzderpsDerps.savedOptions.deathAlert.unlock)
    DeathAlertContainerBackdrop:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.unlock)
    DeathAlertContainerSkull:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.unlock)
end
