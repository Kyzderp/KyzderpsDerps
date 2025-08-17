KyzderpsDerps = KyzderpsDerps or {}

KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

Spud.PVE = "PVE"
Spud.PVP = "PVP"
Spud.NONE = "NONE"

local currentState = Spud.NONE

function Spud.GetCurrentState()
    return currentState
end

---------------------------------------------------------------------
-- State Listeners
-- Other modules should register a listener for state changes
---------------------------------------------------------------------
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

local function FireStateListeners(newState, reason)
    if (newState == currentState) then
        KyzderpsDerps:dbg("|cFF0000Spud state is already " .. newState .. "|r")
        return
    end
    KyzderpsDerps:dbg(string.format("State: %s → %s Reason: %s", currentState, newState, tostring(reason)))

    local prevState = currentState
    currentState = newState
    for _, callback in pairs(listeners) do
        callback(prevState, newState)
    end
end

---------------------------------------------------------------------
-- Cyrodiil or Imperial City Queue Check
---------------------------------------------------------------------
local function GetCyroType()
    if (GetNumCampaignQueueEntries() > 0) then
        return Spud.PVP
    end
    return Spud.NONE
end

---------------------------------------------------------------------
-- Zone Check
---------------------------------------------------------------------
local function IsDoingGroupPVE(zoneId)
    if (IsUnitInDungeon("player")) then
        return KyzderpsDerps.IsInstanceId(tostring(zoneId))
    end
end
Spud.IsDoingGroupPVE = IsDoingGroupPVE

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
end
Spud.IsDoingPVP = IsDoingPVP

---------------------------------------------------------------------
-- Dungeon / Battlegrounds Finder
---------------------------------------------------------------------
-- Code from esoui/ingame/lfg/activitytracker.lua
local function GetCurrentFinderType()
    local activityId = 0

    if (IsCurrentlySearchingForGroup()) then
        activityId = GetActivityRequestIds(1)
    elseif (IsInLFGGroup()) then
        activityId = GetCurrentLFGActivityId()
    end

    if (activityId <= 0) then
        return Spud.NONE
    end

    local activityType = GetActivityType(activityId)

    if (activityType == LFG_ACTIVITY_DUNGEON or activityType == LFG_ACTIVITY_MASTER_DUNGEON) then
        return Spud.PVE
    elseif (activityType == LFG_ACTIVITY_BATTLE_GROUND_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_NON_CHAMPION or activityType == LFG_ACTIVITY_BATTLE_GROUND_LOW_LEVEL) then
        return Spud.PVP
    elseif (activityType == LFG_ACTIVITY_TRIBUTE_CASUAL or activityType == LFG_ACTIVITY_TRIBUTE_COMPETITIVE) then
        return Spud.NONE
    else
        KyzderpsDerps:dbg(string.format("|cFF0000THIS SHOULDN'T BE POSSIBLE? %d", activityType))
        return Spud.NONE
    end
end

---------------------------------------------------------------------
-- Check current state and fire listeners if applicable
---------------------------------------------------------------------
local function CheckState(reason)
    local finderType = Spud.NONE
    if (KyzderpsDerps.savedOptions.antispud.state.includeActivityFinder) then
        finderType = GetCurrentFinderType()
        if (finderType == Spud.NONE) then
            -- Also check Cyro / IC queue
            finderType = GetCyroType()
        end
    end

    local checkedState = Spud.NONE
    if (finderType == Spud.PVE or finderType == Spud.PVP) then
        -- Activity finder should take priority
        checkedState = finderType
    else
        -- If we're not queued, just use the zone as the check
        local zoneId = GetZoneId(GetUnitZoneIndex("player"))
        if (IsDoingGroupPVE(zoneId)) then
            checkedState = Spud.PVE
        elseif (IsDoingPVP()) then
            checkedState = Spud.PVP
        else
            checkedState = Spud.NONE
        end
    end

    if (checkedState ~= currentState) then
        FireStateListeners(checkedState, reason)
    end
end

---------------------------------------------------------------------
-- Events to trigger state check
---------------------------------------------------------------------
local function OnFinderStatusUpdate()
    CheckState("finder")
end

local function OnCampaignQueueChanged()
    CheckState("campaign")
end

local prevZoneId
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (prevZoneId) then
        KyzderpsDerps:dbg(string.format("|c00FF00Left zone %s (%d)|r", GetZoneNameById(prevZoneId), prevZoneId))
    end
    KyzderpsDerps:dbg(string.format("|c00FF00Entered zone %s (%d)|r", GetPlayerActiveZoneName(), zoneId))
    prevZoneId = zoneId

    CheckState("activation")
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeState()
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, OnFinderStatusUpdate)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudCampaignJoined",  EVENT_CAMPAIGN_QUEUE_JOINED, OnCampaignQueueChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudCampaignLeft",  EVENT_CAMPAIGN_QUEUE_LEFT, OnCampaignQueueChanged)
end
