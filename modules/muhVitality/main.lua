KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
local function OnDeathStateChanged(_, unitTag, isDead)
    if (isDead) then
        d(string.format("%s (%s) died", GetUnitDisplayName(unitTag), unitTag))
    else
        d(string.format("%s (%s) rezzed", GetUnitDisplayName(unitTag), unitTag))
    end
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeMuhVitality()
    KyzderpsDerps:dbg("    Initializing MuhVitality module...")

    MuhVitality:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.muhVitality.x, KyzderpsDerps.savedValues.muhVitality.y)
    HUD_SCENE:AddFragment(ZO_SimpleSceneFragment:New(MuhVitality))
    HUD_UI_SCENE:AddFragment(ZO_SimpleSceneFragment:New(MuhVitality))

    -- On player death
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "MuhVitalityDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "MuhVitalityDeath", EVENT_UNIT_DEATH_STATE_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group")
end
