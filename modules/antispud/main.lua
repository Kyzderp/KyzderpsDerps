KDD_AntiSpud = KDD_AntiSpud or {}
local Spud = KDD_AntiSpud

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
    d(string.format("|cAAAAAAIsActiveWorldGroupOwnable: " .. tostring(IsActiveWorldGroupOwnable()) .. "|r"))

    if (IsUnitInDungeon("player")) then
        return SpawnTimer.DUNGEON_ZONEIDS[tostring(zoneId)] ~= nil or SpawnTimer.TRIAL_ZONEIDS[tostring(zoneId)] ~= nil
    end

    -- TODO: check LFG queue
end

function Spud.IsDoingPVP()
    d(string.format("|cAAAAAAIsActiveWorldBattleground: " .. tostring(IsActiveWorldBattleground()) .. "|r"))

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

local finderStatus = {
    [ACTIVITY_FINDER_STATUS_COMPLETE] = "COMPLETE",
    [ACTIVITY_FINDER_STATUS_FORMING_GROUP] = "FORMING_GROUP",
    [ACTIVITY_FINDER_STATUS_IN_PROGRESS] = "IN_PROGRESS",
    [ACTIVITY_FINDER_STATUS_NONE] = "NONE",
    [ACTIVITY_FINDER_STATUS_QUEUED] = "QUEUED",
    [ACTIVITY_FINDER_STATUS_READY_CHECK] = "READY_CHECK",
}


---------------------------------------------------------------------
-- Entry
function Spud:Initialize()
    KyzderpsDerps:dbg("    Initializing AntiSpud module...")
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    OnPlayerActivated()

    -- EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpudActivityFinder", EVENT_ACTIVITY_FINDER_STATUS_UPDATE, function(_, result) d(string.format("|cAAAAAAActivityFinderStatus %s|r", finderStatus[result])) end)
end

-- ACTIVITY_FINDER_STATUS_COMPLETE
-- ACTIVITY_FINDER_STATUS_FORMING_GROUP
-- ACTIVITY_FINDER_STATUS_IN_PROGRESS
-- ACTIVITY_FINDER_STATUS_NONE
-- ACTIVITY_FINDER_STATUS_QUEUED
-- ACTIVITY_FINDER_STATUS_READY_CHECK
