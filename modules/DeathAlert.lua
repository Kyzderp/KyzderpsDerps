DeathAlert = {
    -- Number of milliseconds after which deaths will disappear
    TIMER_EXPIRY = 3000,

    -- Currently unused controls for deaths: {[1] = "@Kyzeragon"}
    freeControls = {},
}

function DeathAlert:Initialize()
    KyzderpsDerps:dbg("    Initializing DeathAlert module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "DeathAlertDeath", EVENT_UNIT_DEATH_STATE_CHANGED, DeathAlert.OnDeathStateChanged)

    -- Initialize position
    DeathAlertContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.deathAlert.x, KyzderpsDerps.savedValues.deathAlert.y)
    DeathAlertContainer:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.enable)
    DeathAlertContainerBackdrop:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.unlock)
    DeathAlertContainerSkull:SetHidden(not KyzderpsDerps.savedOptions.deathAlert.unlock)
end

-- Save boss list position
function DeathAlert.SavePosition()
    KyzderpsDerps.savedValues.deathAlert.x = DeathAlertContainer:GetLeft()
    KyzderpsDerps.savedValues.deathAlert.y = DeathAlertContainer:GetTop()
end

--  EVENT_UNIT_DEATH_STATE_CHANGED (number eventCode, string unitTag, boolean isDead)
function DeathAlert.OnDeathStateChanged(_, unitTag, isDead)
    if (isDead and KyzderpsDerps.savedOptions.deathAlert.enable and string.find(unitTag, "^group")) then
        local displayName = GetUnitDisplayName(unitTag)
        local deathText = getRoleString(GetGroupMemberSelectedRole(unitTag)) .. displayName .. " is dead!"

        local index = DeathAlert.findOrCreateControl(displayName)
        local deathControl = DeathAlertContainer:GetNamedChild("Death" .. tostring(index))

        DeathAlert.freeControls[index] = displayName
        deathControl:GetNamedChild("Label"):SetText(deathText)
        deathControl:SetHidden(false)
        deathControl.timeline:PlayFromStart()
        -- /script BUI.OnScreen.NotificationSecondary("test","test".." "..BUI.Loc("GroupMemberDead"))

        -- Hide it
        EVENT_MANAGER:RegisterForUpdate("KDD_HideDeath" .. tostring(index), DeathAlert.TIMER_EXPIRY, function()
            deathControl:SetHidden(true)
            DeathAlert.freeControls[index] = ""
            EVENT_MANAGER:UnregisterForUpdate("KDD_HideDeath" .. tostring(index))
        end)
    end
end

-- Return the index of the control to be used
function DeathAlert.findOrCreateControl(displayName)
    for i, name in pairs(DeathAlert.freeControls) do
        if (displayName == name or name == "") then
            return i
        end
    end
    return DeathAlert.createNewControl()
end

-- Create a new control for death alerts, for when multiple are displayed at the same time. Returns the index
function DeathAlert.createNewControl()
    local fontSize = KyzderpsDerps.savedOptions.deathAlert.size
    local index = #DeathAlert.freeControls + 1
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

function DeathAlert.changeFontSize()
    -- If there aren't any controls yet, we need to create them so they're actually visible
    if (#DeathAlert.freeControls == 0) then
        DeathAlert.createNewControl()
        DeathAlert.freeControls[1] = ""
        DeathAlert.createNewControl()
        DeathAlert.freeControls[2] = ""
    elseif (#DeathAlert.freeControls == 1) then
        DeathAlert.createNewControl()
        DeathAlert.freeControls[2] = ""
    end

    -- Change all the current ones
    local fontSize = KyzderpsDerps.savedOptions.deathAlert.size
    for i, name in pairs(DeathAlert.freeControls) do
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

function DeathAlert.hideAll(currentpanel)
    if (currentpanel ~= KyzderpsDerps.addonPanel) then return end
    -- Hide all death controls
    for i, name in pairs(DeathAlert.freeControls) do
        local deathControl = DeathAlertContainer:GetNamedChild("Death" .. tostring(i))
        deathControl:SetHidden(true)
    end
end

-- Get the string containing texture for the group role
function getRoleString(LFGRole)
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
