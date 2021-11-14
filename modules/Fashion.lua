KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------------------------------------
local curseTypes = {
    [CURSE_TYPE_NONE] = "CURSE_TYPE_NONE",
    [CURSE_TYPE_VAMPIRE] = "CURSE_TYPE_VAMPIRE",
    [CURSE_TYPE_WEREWOLF] = "CURSE_TYPE_WEREWOLF",
}

---------------------------------------------------------------------------------------------------
-- SKILL_TYPE_WORLD
-- Werewolf: skilLType 4 skillIndex 6 /script d(GetSkillLineId(SKILL_TYPE_WORLD, 5)) 50
-- Vampire: skilLType 4 skillIndex 5 /script d(GetSkillLineId(SKILL_TYPE_WORLD, 5)) 51
local function OnSkillLineAdded(_, skillType, skillIndex, advised)
    local skillLineId = GetSkillLineId(skillType, skillIndex)
    if (skillLineId == 50) then
        -- Werewolf
        KyzderpsDerps:dbg("Gained Werewolf")
    elseif (skillLineId == 51) then
        -- Vampire
        KyzderpsDerps:dbg("Gained Vampire")
    end
end

---------------------------------------------------------------------------------------------------
-- Entry
function KyzderpsDerps.InitializeFashion()
    KyzderpsDerps:dbg("    Initializing Fashion module...")

    -- EVENT_SKILL_LINE_ADDED (number eventCode, SkillType skillType, number skillIndex, boolean advised)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionSkillLine", EVENT_SKILL_LINE_ADDED, OnSkillLineAdded)
end
