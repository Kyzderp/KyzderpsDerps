KyzderpsDerps = KyzderpsDerps or {}

KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

Spud.PVE = "PVE"
Spud.PVP = "PVP"
Spud.NONE = "NONE"

---------------------------------------------------------------------
local currentState = "NONE"
local listeners = {}

-- Callback with params:
-- string oldState
-- string newState
function Spud.RegisterStateListener(name, callback)
    if (listeners[name]) then
        KyzderpsDerps:dbg("|cFF0000Spud state listener " .. name .. " already exists|r")
        return
    end

    listeners[name] = callback
end

local function FireStateListeners(newState)
    if (newState == currentState) then
        KyzderpsDerps:dbg("|cFF0000Spud state is already " .. newState .. "|r")
        return
    end
    KyzderpsDerps:dbg(string.format("State: %s → %s", currentState, newState))
    for _, callback in pairs(listeners) do
        callback(currentState, newState)
    end
    currentState = newState
end

---------------------------------------------------------------------

local function IsDoingGroupPVE()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    if (IsUnitInDungeon("player")) then
        return KyzderpsDerps.DUNGEON_ZONEIDS[tostring(zoneId)] ~= nil or KyzderpsDerps.TRIAL_ZONEIDS[tostring(zoneId)] ~= nil
    end

    -- TODO: check LFG queue
end

local function IsDoingPVP()
    if (IsActiveWorldBattleground()) then
        return true
    end

    if (IsInAvAZone()) then
        return true
    end

    if (IsInImperialCity()) then
        return true
    end

    if (GetUnitBattlegroundAlliance("player") ~= nil and GetUnitBattlegroundAlliance("player") ~= 0) then
        return true
    end


    -- TODO: check LFG queue
end

---------------------------------------------------------------------
-- Dungeon / Battlegrounds Finder
local HEADER_MAPPING = {
    [LFG_ACTIVITY_DUNGEON] = GetString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER),
    [LFG_ACTIVITY_MASTER_DUNGEON] = GetString(SI_ACTIVITY_FINDER_CATEGORY_DUNGEON_FINDER),
    [LFG_ACTIVITY_BATTLE_GROUND_CHAMPION] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
    [LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
    [LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL] = GetString(SI_ACTIVITY_FINDER_CATEGORY_BATTLEGROUNDS),
}

-- Code from esoui/ingame/lfg/activitytracker.lua
local function GetCurrentFinderType()
    local activityId = 0

    if (IsCurrentlySearchingForGroup()) then
        activityId = GetActivityRequestIds(1)
    elseif (IsInLFGGroup()) then
        activityId = GetCurrentLFGActivityId()
    end

    if (activityId <= 0) then
        return "NONE"
    end

    local activityType = GetActivityType(activityId)
    KyzderpsDerps:dbg(string.format("|cAAAAAAActivity Finder: %s", HEADER_MAPPING[activityType]))

    if (activityType == LFG_ACTIVITY_DUNGEON or activityType == LFG_ACTIVITY_MASTER_DUNGEON) then
        return "PVE"
    elseif (activityType == LFG_ACTIVITY_BATTLE_GROUND_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL) then
        return "PVP"
    else
        KyzderpsDerps:dbg(string.format("|cFF0000THIS SHOULDN'T BE POSSIBLE? %d", activityType))
        return "NONE"
    end
end

-- EVENT_ACTIVITY_FINDER_STATUS_UPDATE (number eventCode, ActivityFinderStatus result)
local function OnFinderStatusUpdate(_, result)
    local finderType = GetCurrentFinderType()

    if (finderType == "PVE" and currentState ~= "PVE") then
        FireStateListeners(Spud.PVE)
    elseif (finderType == "PVP" and currentState ~= "PVP") then
        FireStateListeners(Spud.PVP)
    elseif (finderType == "NONE" and currentState ~= "NONE") then
        FireStateListeners(Spud.NONE)
    end
end

---------------------------------------------------------------------
local function OnPlayerActivated(_, initial)
    if (Spud.IsDoingGroupPVE()) then
        if (currentState ~= Spud.PVE) then
            FireStateListeners(Spud.PVE)
        end
    elseif (Spud.IsDoingPVP()) then
        if (currentState ~= Spud.PVP) then
            FireStateListeners(Spud.PVP)
        end
    elseif (currentState ~= Spud.NONE) then
        FireStateListeners(Spud.NONE)
    else
        -- Same state as before
    end
end

---------------------------------------------------------------------
-- Entry
function Spud.InitializeState()
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnFinderStatusUpdate)
end
