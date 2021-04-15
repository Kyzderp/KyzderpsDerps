KDD_AntiSpud = KDD_AntiSpud or {}
local Spud = KDD_AntiSpud

--[[
summon pets after dying
resummon pets on zhajhassa
5 piece armor
addons not enabled
wrong mundus
wrong cp
missing gear
incomplete sets
take off alkosh on spooder
reequip alkosh
low soul gems
]]

local currentState = "NONE"

function Spud.DisplayWarning(message)
    -- TODO: other methods of warnings like popup dialogs
    local chatWarning = "|cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|r: " .. message
    CHAT_SYSTEM:AddMessage(chatWarning)
end

function Spud.IsDoingGroupPVE()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    -- d(string.format("|cAAAAAAIsActiveWorldGroupOwnable: " .. tostring(IsActiveWorldGroupOwnable()) .. "|r"))

    if (IsUnitInDungeon("player")) then
        return SpawnTimer.DUNGEON_ZONEIDS[tostring(zoneId)] ~= nil or SpawnTimer.TRIAL_ZONEIDS[tostring(zoneId)] ~= nil
    end

    -- TODO: check LFG queue
end

function Spud.IsDoingPVP()
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
    -- TODO: do checks

    if (finderType == "PVE" and currentState ~= "PVE") then
        Spud.CheckMundus()
    elseif (finderType == "PVP" and currentState ~= "PVP") then
        Spud.CheckMundus()
    end
end

---------------------------------------------------------------------
local function OnPlayerActivated(_, initial)
    if (Spud.IsDoingGroupPVE()) then
        if (currentState ~= "PVE") then
            KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s → PVE", currentState))
            currentState = "PVE"
            Spud.CheckMundus()
        else
            KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s", currentState))
        end
    elseif (Spud.IsDoingPVP()) then
        if (currentState ~= "PVP") then
            KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s → PVP", currentState))
            currentState = "PVP"
            Spud.CheckMundus()
        else
            KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s", currentState))
        end
    elseif (currentState ~= "NONE") then
        KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s → NONE", currentState))
        currentState = "NONE"
    else
        KyzderpsDerps:dbg(string.format("|cAAAAAAState: %s", currentState))
    end
end

---------------------------------------------------------------------
-- Entry
function Spud:Initialize()
    KyzderpsDerps:dbg("    Initializing AntiSpud module...")
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()
    Spud.CheckMundus()

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnFinderStatusUpdate)
end

-- ACTIVITY_FINDER_STATUS_COMPLETE
-- ACTIVITY_FINDER_STATUS_FORMING_GROUP
-- ACTIVITY_FINDER_STATUS_IN_PROGRESS
-- ACTIVITY_FINDER_STATUS_NONE
-- ACTIVITY_FINDER_STATUS_QUEUED
-- ACTIVITY_FINDER_STATUS_READY_CHECK
