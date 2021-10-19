KyzderpsDerps = KyzderpsDerps or {}

local currentChar = GetUnitName("player")

---------------------------------------------------------------------
local function UpdateSkillPoints()
    KyzderpsDerps.savedValues.charInfo.characters[currentChar].availPoints = GetAvailableSkillPoints()
end

local function UpdatePlayedTime()
    KyzderpsDerps.savedValues.playedChart.characters[currentChar] = GetSecondsPlayed()
    KyzderpsDerps.savedValues.charInfo.characters[currentChar].playedTime = GetSecondsPlayed() -- Start migrating
end

local function UpdateAll()
    UpdatePlayedTime()
    UpdateSkillPoints()
end

---------------------------------------------------------------------
-- lazy, copied from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
local function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

---------------------------------------------------------------------
-- Build the entire string for all played
function KyzderpsDerps.BuildPlayed()
    UpdatePlayedTime()

    local result = "=== Time Played ==="
    local totalTime = 0

    -- sort by descending amount played
    for name, seconds in spairs(KyzderpsDerps.savedValues.playedChart.characters, function(t, a, b) return t[b] < t[a] end) do
        totalTime = totalTime + seconds
        result = result .. "\n|cFFFFFF" .. name .. " -|r "
        result = result .. ZO_FormatTime(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS)
        result = result .. "|cFFFFFF" .. string.format(" (%.2f hours)", seconds / 3600) .. "|r"
    end

    -- print the total as well
    result = result .. "\n\n|cFFFFFFTOTAL -|r "
    result = result .. ZO_FormatTime(totalTime, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS)
    result = result .. "|cFFFFFF" .. string.format(" (%.2f hours)", totalTime / 3600) .. "|r"

    return result
end

-- Build the entire string for available skill points
function KyzderpsDerps.BuildPoints()
    UpdateSkillPoints()

    local result = "=== Unspent Skill Points ==="

    -- sort by descending unspent skill points
    for name, info in spairs(KyzderpsDerps.savedValues.charInfo.characters, function(t, a, b) return t[b].availPoints < t[a].availPoints end) do
        result = result .. "\n|cFFFFFF" .. name .. " -|r "
        result = result .. tostring(info.availPoints)
    end

    return result
end

---------------------------------------------------------------------
-- Hooks
function KyzderpsDerps.InitializePlayedChart()
    KyzderpsDerps:dbg("    Initializing PlayedChart module...")

    if (not KyzderpsDerps.savedValues.charInfo.characters[currentChar]) then
        KyzderpsDerps.savedValues.charInfo.characters[currentChar] = {}
    end

    UpdateAll()

    ZO_PreHook("ReloadUI", UpdateAll)
    ZO_PreHook("Logout", UpdateAll)
    ZO_PreHook("SetCVar", UpdateAll)
    ZO_PreHook("Quit", UpdateAll)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SkillPoint", EVENT_SKILL_POINTS_CHANGED, UpdateSkillPoints)
end
