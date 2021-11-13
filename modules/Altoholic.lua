KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
--[[
characters = {
    Kyrozan = {
        availPoints = 13,
        playedTime = 123987219841,
        armoryBuilds = {
            {
                name = Stam,
            },
            {
                name = Tank,
            }
        }
    }
}
]]
local function UpdateSkillPoints()
    local currentChar = GetUnitName("player")
    KyzderpsDerps.savedValues.charInfo.characters[currentChar].availPoints = GetAvailableSkillPoints()
end

local function UpdatePlayedTime()
    local currentChar = GetUnitName("player")
    KyzderpsDerps.savedValues.playedChart.characters[currentChar] = GetSecondsPlayed()
    KyzderpsDerps.savedValues.charInfo.characters[currentChar].playedTime = GetSecondsPlayed() -- Start migrating
end

local function UpdateArmoryBuilds()
    local builds = {}
    for i = 1, GetNumUnlockedArmoryBuilds() do
        local build = {}
        local name = GetArmoryBuildName(i)
        if (not name or name == "") then
            name = "[Empty]"
        end
        build.name = name
        table.insert(builds, {name = name, iconIndex = GetArmoryBuildIconIndex(i)})
    end

    local currentChar = GetUnitName("player")
    KyzderpsDerps.savedValues.charInfo.characters[currentChar].armoryBuilds = builds
end

local function UpdateAll()
    UpdatePlayedTime()
    UpdateSkillPoints()
    UpdateArmoryBuilds()
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

---------------------------------------------------------------------
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
-- Build the entire string for armory builds
function KyzderpsDerps.BuildArmory()
    UpdateArmoryBuilds()

    local result = "=== Armory Builds ==="

    -- Sort by character index
    for index = 1, GetNumCharacters() do
        local name = zo_strformat("<<1>>", GetCharacterInfo(index))
        local info = KyzderpsDerps.savedValues.charInfo.characters[name]
        if (info and info.armoryBuilds) then
            local buildNames = {}
            for _, build in ipairs(info.armoryBuilds) do
                local buildString = string.format("|t24:24:/esoui/art/armory/buildicons/buildicon_%d.dds|t%s", build.iconIndex, build.name)
                table.insert(buildNames, buildString)
            end

            result = result .. string.format("\n%s (%d) - ", name, #buildNames)
            result = result .. table.concat(buildNames, " || ", 1, math.min(5, #buildNames))
            if (#buildNames > 5) then
                -- Apparently, with too many builds, or probably just too long of a message
                -- due to my color coding, it won't show for the same line
                result = result .. "\n    ... " .. table.concat(buildNames, " || ", 6)
            end
        end
    end

    return result
end

---------------------------------------------------------------------
-- Hooks
function KyzderpsDerps.InitializeAltoholic()
    KyzderpsDerps:dbg("    Initializing Altoholic module...")

    local currentChar = GetUnitName("player")
    if (not KyzderpsDerps.savedValues.charInfo.characters[currentChar]) then
        KyzderpsDerps.savedValues.charInfo.characters[currentChar] = {}
    end

    -- Get rid of this weird bug that happened at some point, maybe not initialized?
    KyzderpsDerps.savedValues.charInfo.characters["LocalPlayer"] = nil
    KyzderpsDerps.savedValues.playedChart.characters["LocalPlayer"] = nil

    UpdateAll()

    ZO_PreHook("ReloadUI", UpdateAll)
    ZO_PreHook("Logout", UpdateAll)
    ZO_PreHook("SetCVar", UpdateAll)
    ZO_PreHook("Quit", UpdateAll)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SkillPoint", EVENT_SKILL_POINTS_CHANGED, UpdateSkillPoints)
end
