KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
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

local function GetMundus(unitTag)
    local currentMundus = "NONE"
    for i = 1, GetNumBuffs(unitTag) do
        -- string buffName, number timeStarted, number timeEnding, number buffSlot, number stackCount, textureName iconFilename, string buffType, number BuffEffectType effectType, number AbilityType abilityType, number StatusEffectType statusEffectType, number abilityId, boolean canClickOff, boolean castByPlayer
        local buffName, _, _, _, _, iconFilename, _, _, _, _, abilityId, _, _ = GetUnitBuffInfo("player", i)
        if (MUNDUS_BUFFS[abilityId]) then
            -- Yes, this wouldn't get the second mundus for Twice-Born Star, but I cba dealing with that
            return MUNDUS_BUFFS[abilityId], abilityId
        end
    end
end

local function CheckMundus()
    local currentMundus, abilityId = GetMundus("player")
    if (not currentMundus) then
        Spud.Display("You have no Mundus Stone", Spud.MUNDUS)
        return
    end
    Spud.DisplayWarning("You are using |cFFFFFF" .. currentMundus .. "|r")

    local currentState = Spud.GetCurrentState()

    if (currentState == Spud.PVE and KyzderpsDerps.savedOptions.antispud.mundus.checkPve
        and not KyzderpsDerps.savedOptions.antispud.mundus.pve[abilityId]) then
        Spud.Display(string.format("You are using %s in PvE", currentMundus), Spud.MUNDUS)
    elseif (currentState == Spud.PVP and KyzderpsDerps.savedOptions.antispud.mundus.checkPvp
        and not KyzderpsDerps.savedOptions.antispud.mundus.pvp[abilityId]) then
        Spud.Display(string.format("You are using %s in PvP", currentMundus), Spud.MUNDUS)
    else
        if (KyzderpsDerps.savedOptions.general.experimental
            and currentState == Spud.PVE
            and GetSelectedLFGRole() ~= LFG_ROLE_TANK
            and abilityId == 13982) then
            -- Kyzer does not want Atro on non-tank
            Spud.Display("Yo you have the Atro on non-tank", Spud.MUNDUS)
        else
            Spud.Display(nil, Spud.MUNDUS)
        end
    end
end
Spud.CheckMundus = CheckMundus

---------------------------------------------------------------------
-- State change
---------------------------------------------------------------------
local function OnSpudStateChanged(oldState, newState)
    CheckMundus()
end

local function OnMundusBuffChanged(_, result)
    if (result ~= EFFECT_RESULT_GAINED) then return end
    KyzderpsDerps:dbg("Mundus changed")
    CheckMundus()
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeMundus()
    Spud.RegisterStateListener("Mundus", OnSpudStateChanged)

    for abilityId, _ in pairs(MUNDUS_BUFFS) do
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudMundus" .. tostring(abilityId), EVENT_EFFECT_CHANGED, OnMundusBuffChanged)
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "AntiSpudMundus" .. tostring(abilityId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")
        EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "AntiSpudMundus" .. tostring(abilityId), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, abilityId)
    end
end
