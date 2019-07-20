CustomTargetName = {}

-- KyzderpsDerps.savedValues.customTargetFrame.npcCustom = {
    -- {
    --     name = "Saint Llothis the Pious",
    --     customName = "[Llothis]",
    --     color = {0, 1, 0},
    -- }
-- }

function CustomTargetName:Initialize()
    if (KyzderpsDerps.savedOptions.general.debug) then
        d("    Initializing CustomTargetName module...")
    end

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
        if (not KyzderpsDerps.savedOptions.customTargetFrame.player.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local targetPlayerId = GetUnitDisplayName("reticleover")
        customName = targetPlayerId
    ------------------------------------------------------------
    else -- NPCs
        if (not KyzderpsDerps.savedOptions.customTargetFrame.npc.enable) then
            if (KyzderpsDerps.savedOptions.customTargetFrame.move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        for _, filterEntry in ipairs(KyzderpsDerps.savedValues.customTargetFrame.npcCustom) do
            if (filterEntry.name == targetName) then
                customName = filterEntry.customName
                customColor = filterEntry.color
                break
            end
        end

        -- If no custom name is found, leave it empty if the filter is on
        -- If filter is not on, then we display the regular target name
        if (customName == "" and
            not KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter) then
            customName = targetName
        end


        -- if (targetName == "Saint Olms the Just") then
        --     customName = "[Olms]"
        --     customColor = {1,0.7,0.2}
        -- elseif (targetName == "Saint Felms the Bold") then
        --     customName = "[Felms]"
        --     customColor = {1,0,0}
        -- elseif (targetName == "Saint Llothis the Pious") then
        --     customName = "[Llothis]"
        --     customColor = {0,1,0}
        --     -- TODO: add filter here
        -- elseif (not KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter) then -- Just show regular name if filter is disabled
        --     customName = targetName
        -- end
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