KyzderpsDerps = KyzderpsDerps or {}

-- Check each group member to see who has the Focused Fire DEBUFF
local function OnFocusedFireGained(_, result, _, _, _, _, sourceName, sourceType, targetName, _, hitValue, _, _, _, sourceUnitId, targetUnitId, abilityId)
    for g = 1, GetGroupSize() do
        local unitTag = "group" .. tostring(g)
        for i = 1, GetNumBuffs(unitTag) do
            local buffName, _, _, _, stackCount, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo(unitTag, i)
            if (abilityId == 121726) then
                d(string.format("|cAAAAAA%s|r has %d x %s", GetUnitDisplayName(unitTag), stackCount, buffName))
                break
            end
        end
    end
end

function KyzderpsDerps.InitializeFocusedFire()
    KyzderpsDerps:dbg("    Initializing FocusedFire module...")

    -- TODO: only register while in sunspire
    -- Register the CAST of the Focused Fire
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FocusedFireBegin", EVENT_COMBAT_EVENT, OnFocusedFireGained)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "FocusedFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_BEGIN)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "FocusedFireBegin", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, 121722)
end