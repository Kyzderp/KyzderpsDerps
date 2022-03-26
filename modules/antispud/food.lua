KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
-- Is this a food buff?
-- RaidNotifier uses heuristics (many API calls) and a blacklist
-- JoGroup uses a set list. I will copy this because more efficient
---------------------------------------------------------------------
local FOOD_BUFFS = {
    [61259] = true,
    [61260] = true,
    [61261] = true,
    [61322] = true,
    [61325] = true,
    [61328] = true,
    [61257] = true,
    [61255] = true,
    [61294] = true,
    [72816] = true,
    [61340] = true,
    [61345] = true,
    [61218] = true,
    [61350] = true,
    [72822] = true,
    [72816] = true,
    [72819] = true,
    [72824] = true,
    -- crown store
    [68411] = true,
    [68416] = true,
    -- 2h Witches event
    [84681] = true,
    [84709] = true,
    [84725] = true,
    [84678] = true,
    [84704] = true,
    [84720] = true,
    [84700] = true,
    [84731] = true,
    [84735] = true,
    -- new years event
    [86791] = true,
    [86787] = true,
    [86673] = true,
    [86749] = true,
    [86677] = true,
    [86789] = true,
    [84678] = true,
    [86559] = true,
    [86746] = true,
    -- jesters festival
    [84678] = true,
    [89957] = true,
    [89955] = true,
    [89971] = true,
    -- pvp foods
    [72956] = true,
    [72959] = true,
    [72961] = true,
    [72965] = true,
    [72968] = true,
    [72971] = true,
    -- clockwork
    [100498] = true,
    [100488] = true,
    [100502] = true,
    -- summerset    
    [107789] = true,
    [107748] = true,
    -- garbage crown crate foods
    [92474] = true,
    [92435] = true,
    [92476] = true,
    [92433] = true,
    -- more witches festival
    [127531] = true,
    [127572] = true,
    [127596] = true,
}

local function IsFoodBuff(abilityId)
    return FOOD_BUFFS[abilityId]
end

---------------------------------------------------------------------
-- Whether the user is in a PvE, PvP, or boss area
---------------------------------------------------------------------
local function IsInNeedFoodArea()
    local currentState = Spud.GetCurrentState()
    if (currentState == Spud.PVE or currentState == Spud.PVP) then
        return true
    end

    -- Overland bosses etc.
    if (DoesUnitExist("boss1")) then
        return true
    end

    return false
end

---------------------------------------------------------------------
-- Check all of the user's buffs for food
---------------------------------------------------------------------
local function CheckAllFood()
    for i = 1, GetNumBuffs("player") do
        local _, _, timeEnding, _, _, _, _, _, _, _, abilityId = GetUnitBuffInfo("player", i)
        if (IsFoodBuff(abilityId)) then
            Spud.Display(nil, Spud.FOOD)
            -- -- Also remind if food buff is low
            -- local remaining = timeEnding - GetGameTimeSeconds()
            -- if (remaining < 20) then
            --     -- TODO: how to remind about food? Also this isn't getting called or refreshed
            --     return
            -- end
            return
        end
    end

    if (IsInNeedFoodArea()) then
        Spud.Display("You are positively famished", Spud.FOOD)
        return
    end

    Spud.Display(nil, Spud.FOOD)
end

---------------------------------------------------------------------
-- State, effect, or bosses change
-- When any change, we should check if user has a food buff
---------------------------------------------------------------------
local function OnSpudStateChanged(oldState, newState)
    CheckAllFood()
end

local RESULT_TO_STRING = {
    [EFFECT_RESULT_FADED] = "FADED",
    [EFFECT_RESULT_FULL_REFRESH] = "FULL_REFRESH",
    [EFFECT_RESULT_GAINED] = "GAINED",
    [EFFECT_RESULT_TRANSFER] = "TRANSFER",
    [EFFECT_RESULT_UPDATED] = "UPDATED",
}

local function OnEffectChanged(_, changeType, _, _, _, _, _, _, _, _, _, _, _, _, _, abilityId)
    if (changeType ~= EFFECT_RESULT_GAINED and changeType ~= EFFECT_RESULT_FADED) then return end
    if (not IsFoodBuff(abilityId)) then return end
    KyzderpsDerps:dbg(string.format("%s %s (%d)", RESULT_TO_STRING[changeType], GetAbilityName(abilityId), abilityId))
    CheckAllFood()
end

local function OnBossesChanged()
    CheckAllFood()
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeFood()
    KyzderpsDerps:dbg("    Initializing AntiSpud Food...")

    Spud.RegisterStateListener("Food", OnSpudStateChanged)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodEffect", EVENT_EFFECT_CHANGED, OnEffectChanged)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "AntiSpudFoodEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "player")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AntiSpudFoodBossChanged", EVENT_BOSSES_CHANGED, OnBossesChanged)
end
