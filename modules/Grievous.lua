Grievous = {}

function Grievous:Initialize()
    if (KyzderpsDerps.savedOptions.general.debug) then
        d("    Initializing Grievous module...")
    end

    -- Register
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_COMBAT_EVENT, self.OnCombatIn)

    -- Position
    GrievousRetaliation:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.grievous.x, KyzderpsDerps.savedValues.grievous.y)
end

function Grievous.SavePosition()
    KyzderpsDerps.savedValues.grievous.x = GrievousRetaliation:GetLeft()
    KyzderpsDerps.savedValues.grievous.y = GrievousRetaliation:GetTop()
end

-- Grievous Retaliation 104646
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
function Grievous.OnCombatIn(_, result, isError, aName, aGraphic, aActionSlotType, sName, sType, tName, tType, hitValue, pType, dType, log, sUnitId, tUnitId, abilityId)
    if (abilityId == 104646 and KyzderpsDerps.savedOptions.grievous.enable == true) then
        if (tType ~= COMBAT_UNIT_TYPE_PLAYER and KyzderpsDerps.savedOptions.grievous.selfOnly) then
            return
        end
        GrievousRetaliation:SetHidden(false)
        EVENT_MANAGER:RegisterForUpdate("KDD_HideGrievous", 3000, function()
            GrievousRetaliation:SetHidden(true)
            EVENT_MANAGER:UnregisterForUpdate("KDD_HideGrievous")
        end)
    end
end
