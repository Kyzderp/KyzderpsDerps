KDD_AntiSpud = KDD_AntiSpud or {}
local Spud = KDD_AntiSpud

local MUNDUS_BUFFS = {
    [13940] = "The Warrior",
    [13943] = "The Mage",
    [13974] = "The Serpent",
    [13975] = "The Thief",
    [13976] = "The Lady",
    [13977] = "The Steed",
    [13978] = "The Lord",
    [13979] = "The Apprentice",
    [13980] = "The Ritual",
    [13981] = "The Lover",
    [13982] = "The Atronach",
    [13984] = "The Shadow",
    [13985] = "The Tower",
}

function Spud.CheckMundus()
    for i = 1, GetNumBuffs("player") do
        -- string buffName, number timeStarted, number timeEnding, number buffSlot, number stackCount, textureName iconFilename, string buffType, number BuffEffectType effectType, number AbilityType abilityType, number StatusEffectType statusEffectType, number abilityId, boolean canClickOff, boolean castByPlayer
        local buffName, _, _, _, _, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        -- KyzderpsDerps:dbg(string.format("%s %s %s(%d)", buffName, iconFilename, GetAbilityName(abilityId), abilityId))
        if (MUNDUS_BUFFS[abilityId]) then
            Spud.DisplayWarning("You are using |cFFFFFF" .. buffName .. "|r")
        end
    end
end
