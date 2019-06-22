-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "0.0.0"

-- Defaults
local defaultOptions = {
    EnableNpc = true,
    EnablePlayer = true,
    Move = false,
    Debug = false,
    PlayerFilterOn = true,
    NpcFilterOn = true,
    EnableGrievous = true,
}
local defaultValues = {
    ["offsetX"] = GuiRoot:GetWidth() / 2,
    ["offsetY"] = GuiRoot:GetHeight() / 4 * 3,
    ["players"] = {},
    ["npcs"] = {},
    ["grievousX"] = GuiRoot:GetWidth() / 2,
    ["grievousY"] = GuiRoot:GetHeight() / 2,
}

---------------------------------------------------------------------
-- Initialize 
function KyzderpsDerps:Initialize()
    d("Initializing Kyzderp's Derps...")

    -- -- Register
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_RETICLE_TARGET_CHANGED, self.OnReticleTargetChanged)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_COMBAT_EVENT, self.OnCombatIn)

    -- -- Settings and saved variables
    self.SavedOptions = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 1, "Options", defaultOptions)
    self.SavedValues = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 1, "Values", defaultValues)
    KyzderpsDerps:CreateSettingsMenu()

    CustomTargetCustomName:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SavedValues["offsetX"], self.SavedValues["offsetY"])
    GrievousRetaliation:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, self.SavedValues["grievousX"], self.SavedValues["grievousY"])

    if (KyzderpsDerps.SavedOptions.Debug) then
        d("Kyzderp's Derps initialized!")
    end
end
 
---------------------------------------------------------------------
-- On Load
function KyzderpsDerps.OnAddOnLoaded(event, addonName)
    if addonName == KyzderpsDerps.name then
        KyzderpsDerps:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED, KyzderpsDerps.OnAddOnLoaded)


---------------------------------------------------------------------
-- Event Handlers

-- Grievous Retaliation 104646
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
function KyzderpsDerps.OnCombatIn(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    if (abilityId == 104646 and KyzderpsDerps.SavedOptions.EnableGrievous == true) then
        d(tUnitId)
        GrievousRetaliation:SetHidden(false)
        EVENT_MANAGER:RegisterForUpdate("KDD_HideGrievous", 3000, function()
            GrievousRetaliation:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("KDD_HideGrievous")
        end)
    end
end


-- EVENT_RETICLE_TARGET_CHANGED(number eventCode)
function KyzderpsDerps.OnReticleTargetChanged(eventCode)
    local targetName = GetUnitName("reticleover")

    if (targetName == "") then
        if (KyzderpsDerps.SavedOptions.Move == false) then
            CustomTargetCustomName:SetHidden(true)
        end
        return
    end

    local customName = ""
    local customColor = {1,1,1}

    ------------------------------------------------------------
    -- 1 means player
    if (GetUnitType("reticleover") == 1) then
        if (not KyzderpsDerps.SavedOptions.EnablePlayer) then
            if (KyzderpsDerps.SavedOptions.Move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        local targetPlayerId = GetUnitDisplayName("reticleover")
        customName = targetPlayerId
    ------------------------------------------------------------
    else -- NPCs
        if (not KyzderpsDerps.SavedOptions.EnableNpc) then
            if (KyzderpsDerps.SavedOptions.Move == false) then
                CustomTargetCustomName:SetHidden(true)
            end
            return
        end

        if (targetName == "Saint Olms the Just") then
            customName = "[Olms]"
            customColor = {1,0.7,0.2}
        elseif (targetName == "Saint Felms the Bold") then
            customName = "[Felms]"
            customColor = {1,0,0}
        elseif (targetName == "Saint Llothis the Pious") then
            customName = "[Llothis]"
            customColor = {0,1,0}
            -- TODO: add filter here
        elseif (not KyzderpsDerps.SavedOptions.NpcFilterOn) then -- Just show regular name if filter is disabled
            customName = targetName
        end
    end

    ------------------------------------------------------------
    -- Display/Hide
    if (customName ~= "") then
        CustomTargetCustomName:SetHidden(false)
        CustomTargetCustomNameLabel:SetText(customName)
        CustomTargetCustomNameLabel:SetColor(unpack(customColor))
    elseif (KyzderpsDerps.SavedOptions.Move == false) then
        CustomTargetCustomName:SetHidden(true)
    end
end


function KyzderpsDerps.SavePosition()
    KyzderpsDerps.SavedValues["offsetX"] = CustomTargetCustomName:GetLeft()
    KyzderpsDerps.SavedValues["offsetY"] = CustomTargetCustomName:GetTop()
    KyzderpsDerps.SavedValues["grievousX"] = GrievousRetaliation:GetLeft()
    KyzderpsDerps.SavedValues["grievousY"] = GrievousRetaliation:GetTop()
end

---------------------------------------------------------------------
-- Commands
function KyzderpsDerps.handleCommand(argString)
    local args = {}
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
    end

    if (args.length == 0) then
        d("/kdd <grievous>")
        return
    end

    if (KyzderpsDerps.SavedOptions.Debug) then
        d(args)
    end

    if (args[1] == "grievous") then
        GrievousRetaliation:SetHidden(not GrievousRetaliation:IsHidden())
    else
        d("/kdd <grievous>")
    end
end

SLASH_COMMANDS["/kdd"] = KyzderpsDerps.handleCommand
