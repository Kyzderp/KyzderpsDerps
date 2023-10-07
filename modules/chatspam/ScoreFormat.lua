KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

---------------------------------------------------------------------
-- Upon completion of a leaderboard instance, outputs a string that
-- can be easily copied to paste in Discord
---------------------------------------------------------------------

local TRIALS_DICTIONARY = {
    ["Hel Ra Citadel"] = "HRC",
    ["Aetherian Archive"] = "AA",
    ["Sanctum Ophidia"] = "SO",
    ["Dragonstar Arena"] = "DSA",
    ["Maw of Lorkhaj"] = "MoL",
    ["Maelstrom Arena"] = "MA",
    ["Halls of Fabrication"] = "HoF",
    ["Asylum Sanctorium"] = "AS",
    ["Cloudrest"] = "CR",
    ["Blackrose Prison"] = "BRP",
    ["Sunspire"] = "SS",
    ["Kyne's Aegis"] = "KA",
    ["Vateshran Hollows"] = "VH",
    ["Rockgrove"] = "RG",
    ["Dreadsail Reef"] = "DSR",
    ["Sanity's Edge"] = "SE",
};

local MONTHS_DICTIONARY = {
    ["1"] = "January",
    ["2"] = "February",
    ["3"] = "March",
    ["4"] = "April",
    ["5"] = "May",
    ["6"] = "June",
    ["7"] = "July",
    ["8"] = "August",
    ["9"] = "September",
    ["10"] = "October",
    ["11"] = "November",
    ["12"] = "December",
};

---------------------------------------------------------------------
-- Keep track of vitality because for some reason, the completion
-- event doesn't provide that...
---------------------------------------------------------------------
local maxVitality = 0
local vitality = 0

-- EVENT_RAID_TRIAL_STARTED (number eventCode, string trialName, boolean weekly)
local function OnTrialStarted()
    vitality = GetRaidReviveCountersRemaining()
    maxVitality = GetCurrentRaidStartingReviveCounters()
    Spam.AddMessage(string.format("Trial started: %d/%d", vitality, maxVitality))
end

-- EVENT_RAID_REVIVE_COUNTER_UPDATE (number eventCode, number currentCounter, number countDelta)
local function OnVitalityChanged(_, currentCounter, countDelta)
    vitality = currentCounter
    maxVitality = GetCurrentRaidStartingReviveCounters()
    Spam.AddMessage(string.format("Vitality changed: %d/%d", vitality, maxVitality))
end

---------------------------------------------------------------------
local function BuildGroupRoles()

    local isInGroup = GetGroupSize() > 1;

    if not isInGroup then
        return "";
    end

    local tanks = "";
    local healers = "";
    local dps = "";
    local unknown = "";

    local groupSize = GetGroupSize();

    for i = 1, groupSize do

        local unitTag = GetGroupUnitTagByIndex(i);
        local member = string.gsub(GetUnitDisplayName(unitTag), "@", "")
        local role = GetGroupMemberSelectedRole(unitTag);

        if (role == LFG_ROLE_TANK) then
            tanks = tanks .. " " .. member
        elseif (role == LFG_ROLE_HEAL) then
            healers = healers .. " " .. member
        elseif (role == LFG_ROLE_DPS) then
            dps = dps .. " " .. member
        else
            unknown = unknown .. " " .. member
        end
    end

    local result = ""
    if (tanks ~= "") then result = result .. "Tanks:" .. tanks .. " | " end
    if (healers ~= "") then result = result .. "Healers:" .. healers .. " | " end
    if (dps ~= "") then result = result .. "Dps:" .. dps .. " | " end
    if (unknown ~= "") then result = result .. "UNKNOWN:" .. unknown .. " | " end

    return string.gsub(result, " %| $", "");
end

local function BuildScoreFormat(trialName, score, totalSeconds, vitality, maxVitality)
    local result = "__**v" .. TRIALS_DICTIONARY[string.gsub(trialName, " %(Veteran%)", "")] .. "**__\n"

    -- score
    result = result .. "**" .. tostring(score) .. " - "

    -- time
    local time = string.format("%d:%02d:%02d",
        math.floor(totalSeconds / 3600),
        math.floor(totalSeconds / 60) % 60,
        totalSeconds % 60);
    result = result .. string.gsub(time, "^[0:]+", "") .. " - "

    -- vitality
    result = result .. ":vitality: " .. tostring(vitality) .. "/" .. tostring(maxVitality) .. "**\n"

    -- date
    local _, _, mon, day, year = string.find(GetDateStringFromTimestamp(GetTimeStamp()), "(%d+)/(%d+)/(%d+)")
    result = result .. MONTHS_DICTIONARY[mon] .. " " .. day .. ", " .. year .. " - \n"

    -- group members
    result = result .. BuildGroupRoles()

    return result
end

-- EVENT_RAID_TRIAL_COMPLETE (number eventCode, string trialName, number score, number totalTime)
local function OnTrialComplete(_, trialName, score, totalTime)
    local kyzFormat = BuildScoreFormat(trialName, score, totalTime / 1000, vitality, maxVitality)

    vitality = 0
    maxVitality = 0

    CHAT_SYSTEM:AddMessage(kyzFormat)
    -- And also log it again 15 seconds later because it gets buried in muh loot spying
    EVENT_MANAGER:RegisterForUpdate("KyzFormat", 15000, function()
        CHAT_SYSTEM:AddMessage(kyzFormat)
        EVENT_MANAGER:UnregisterForUpdate("KyzFormat")
    end)
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spam.InitializeScoreFormat()
    -- TODO: add setting
    EVENT_MANAGER:RegisterForEvent(Spam.name .. "TrialComplete", EVENT_RAID_TRIAL_COMPLETE, OnTrialComplete)
    EVENT_MANAGER:RegisterForEvent(Spam.name .. "TrialStart", EVENT_RAID_TRIAL_STARTED, OnTrialStarted)
    EVENT_MANAGER:RegisterForEvent(Spam.name .. "TrialVitalityChange", EVENT_RAID_REVIVE_COUNTER_UPDATE, OnVitalityChanged)

    local raidId = GetCurrentParticipatingRaidId()
    if (raidId ~= nil and raidId ~= 0) then
        OnTrialStarted()
    end
end
