local KD = KyzderpsDerps
KD.WorldEvent = {}
local WE = KD.WorldEvent

local WORLD_EVENT_TYPES = {
    [WORLD_EVENT_TYPE_MONSTER_HUNT] = "MONSTER_HUNT", -- dragons and skirmishes
    [WORLD_EVENT_TYPE_SCRIPTED_EVENT] = "SCRIPTED_EVENT", -- seems to be dolmens. stonefalls: 25, glenumbra: 30, seem to stay the same
    [WORLD_EVENT_TYPE_STATIC_MONSTER] = "STATIC_MONSTER", -- only DEs... for now?
}

--[[
auridon
[16:28:30] activated: instanceid 98 eventid 98 type SCRIPTED_EVENT
[16:28:31] activated: instanceid 131 eventid 131 type STATIC_MONSTER

glenumbra
[16:01:30] activated: instanceid 96 eventid 96 type SCRIPTED_EVENT
[16:01:31] activated: instanceid 99 eventid 99 type STATIC_MONSTER
[16:02:26] activated: instanceid 100 eventid 100 type STATIC_MONSTER
[16:03:18] activated: instanceid 101 eventid 101 type STATIC_MONSTER
[16:04:11] activated: instanceid 102 eventid 102 type STATIC_MONSTER
[16:04:57] activated: instanceid 103 eventid 103 type STATIC_MONSTER
[16:05:43] activated: instanceid 104 eventid 104 type STATIC_MONSTER
[16:06:22] activated: instanceid 105 eventid 105 type STATIC_MONSTER

stonefalls
[15:30:13] activated: instanceid 95 eventid 95 type SCRIPTED_EVENT
[15:30:13] activated: instanceid 106 eventid 106 type STATIC_MONSTER
[15:31:00] activated: instanceid 107 eventid 107 type STATIC_MONSTER
[15:31:36] activated: instanceid 108 eventid 108 type STATIC_MONSTER
[15:32:13] activated: instanceid 109 eventid 109 type STATIC_MONSTER
[15:32:39] activated: instanceid 112 eventid 112 type STATIC_MONSTER
[15:33:06] activated: instanceid 110 eventid 110 type STATIC_MONSTER
]]
local DYNAMIC_EVENT_DATA = {
    [98] = true, -- auridon
    [96] = true, -- glenumbra
    [95] = true, -- stonefalls
}

local function IsDE(worldEventInstanceId)
    local worldEventId = GetWorldEventId(worldEventInstanceId)
    local worldEventType = GetWorldEventType(worldEventId)
    d(zo_strformat("instanceid <<1>> eventid <<2>> type <<3>>", worldEventInstanceId, worldEventId, WORLD_EVENT_TYPES[worldEventType]))

    return DYNAMIC_EVENT_DATA[worldEventId]
end

local function CheckDE(worldEventInstanceId)
    if (IsDE(worldEventInstanceId)) then
        if (KD.savedOptions.overland.dynamicEventSound) then
            PlaySound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM)
            PlaySound(SOUNDS.BATTLEGROUND_CAPTURE_FLAG_TAKEN_OWN_TEAM)
        end
        if (KD.savedOptions.overland.dynamicEventChat) then
            KD:msg("Dynamic event active!")
        end
        if (KD.savedOptions.overland.dynamicEventCrutch and CrutchAlerts and CrutchAlerts.DisplayProminentSpin) then
            CrutchAlerts.DisplayProminentSpin("DYNAMIC EVENT", {1, 0, 0}, 1)
            CrutchAlerts.DisplayProminentSpin("DYNAMIC EVENT", {0, 1, 0}, 2)
            CrutchAlerts.DisplayProminentSpin("DYNAMIC EVENT", {0, 0, 1}, 3)
        end
        return true
    end
end

local function OnWorldEventActivated(_, worldEventInstanceId)
    CheckDE(worldEventInstanceId)
end

local function OnPlayerActivated()
    -- Yoinked from esoui/ingame/map/worldmap.lua
    local function GetNextWorldEventInstanceIdIter(state, var1)
        return GetNextWorldEventInstanceId(var1)
    end
    for worldEventInstanceId in GetNextWorldEventInstanceIdIter do
        if (CheckDE(worldEventInstanceId)) then
            return -- just do one, but it prob shouldn't have multiple anyway
        end
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function WE.Initialize()
    EVENT_MANAGER:RegisterForEvent(KD.name .. "WorldEventActivated", EVENT_WORLD_EVENT_ACTIVATED, OnWorldEventActivated)
    -- EVENT_MANAGER:RegisterForEvent(KD.name .. "WorldEventPlayerActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    -- OnPlayerActivated()
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function WE.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Show chat message",
            tooltip = "Shows a message in chat when a dynamic event starts in your current zone",
            default = false,
            getFunc = function() return KD.savedOptions.overland.dynamicEventChat end,
            setFunc = function(value)
                KD.savedOptions.overland.dynamicEventChat = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Play sound",
            tooltip = "Plays a sound when a dynamic event starts in your current zone",
            default = false,
            getFunc = function() return KD.savedOptions.overland.dynamicEventSound end,
            setFunc = function(value)
                KD.savedOptions.overland.dynamicEventSound = value
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Use obnoxious text and sound",
            tooltip = "Uses CrutchAlerts to display really obnoxious prominent alerts and spammy sounds when a dynamic event starts in your current zone. Requires CrutchAlerts",
            default = false,
            getFunc = function() return KD.savedOptions.overland.dynamicEventCrutch end,
            setFunc = function(value)
                KD.savedOptions.overland.dynamicEventCrutch = value
            end,
            width = "full",
            disabled = function() return CrutchAlerts == nil or CrutchAlerts.DisplayProminentSpin == nil end,
        },
    }
end
