CustomTargetName = {}

function CustomTargetName:Initialize()
    KyzderpsDerps:dbg("    Initializing CustomTargetName module...")

    -- Register
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_RETICLE_TARGET_CHANGED, self.OnReticleTargetChanged)

    -- Position
    CustomTargetCustomName:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.customTargetFrame.x,
        KyzderpsDerps.savedValues.customTargetFrame.y)
end

function CustomTargetName.SavePosition()
    KyzderpsDerps.savedValues.customTargetFrame.x = CustomTargetCustomName:GetLeft()
    KyzderpsDerps.savedValues.customTargetFrame.y = CustomTargetCustomName:GetTop()
end

-- EVENT_RETICLE_TARGET_CHANGED(number eventCode)
function CustomTargetName.OnReticleTargetChanged()
    local targetName = GetUnitName("reticleover")

    if (targetName == "") then
        if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
            CustomTargetCustomName:SetHidden(true)
        end
        return
    end

    local customName = ""
    local customColor = {1,1,1}

    ------------------------------------------------------------
    -- 1 means player
    if (GetUnitType("reticleover") == 1) then
        targetName = GetUnitDisplayName("reticleover")
        if (not KyzderpsDerps.savedOptions.customTargetFrame.player.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local entry = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[targetName]
        if (entry) then
            customName = entry.customName
            customColor = entry.color
        elseif (not KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter) then
            -- If no custom name is found, leave it empty if the filter is on
            -- If filter is not on, then we display the regular target name
            customName = targetName
        end

        if (customName ~= "") then
            CustomTargetName.recentPlayer = targetName
        end

    ------------------------------------------------------------
    else -- NPCs
        CustomTargetName.recentNpc = targetName
        if (not KyzderpsDerps.savedOptions.customTargetFrame.npc.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local entry = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[targetName]
        if (entry) then
            customName = entry.customName
            customColor = entry.color
        elseif (not KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter) then
            -- If no custom name is found, leave it empty if the filter is on
            -- If filter is not on, then we display the regular target name
            customName = targetName
        end

        if (customName ~= "") then
            CustomTargetName.recentNpc = targetName
        end
    end

    ------------------------------------------------------------
    -- Display/Hide
    if (customName ~= "") then
        CustomTargetCustomName:SetHidden(false)
        CustomTargetCustomNameLabel:SetText(customName)
        CustomTargetCustomNameLabel:SetColor(unpack(customColor))
    elseif (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
        CustomTargetCustomName:SetHidden(true)
    end
end