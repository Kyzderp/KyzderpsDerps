KyzderpsDerps = KyzderpsDerps or {}

local previousCompanion = nil
local assistantActive = false

---------------------------------------------------------------------
local collectibleBlockReasons = {
    [COLLECTIBLE_USAGE_BLOCK_REASON_ACTIVE_DIG_SITE_REQUIRED] = "ACTIVE_DIG_SITE_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLACKLISTED] = "BLACKLISTED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_SUBZONE] = "BLOCKED_BY_SUBZONE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_BLOCKED_BY_ZONE] = "BLOCKED_BY_ZONE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_CATEGORY_REQUIREMENT_FAILED] = "CATEGORY_REQUIREMENT_FAILED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COLLECTIBLE_ALREADY_QUEUED] = "COLLECTIBLE_ALREADY_QUEUED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_INTRO_QUEST] = "COMPANION_INTRO_QUEST",
    [COLLECTIBLE_USAGE_BLOCK_REASON_COMPANION_MENU_REQUIRED] = "COMPANION_MENU_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_DEAD] = "DEAD",
    [COLLECTIBLE_USAGE_BLOCK_REASON_DUELING] = "DUELING",
    [COLLECTIBLE_USAGE_BLOCK_REASON_GROUP_FULL] = "GROUP_FULL",
    [COLLECTIBLE_USAGE_BLOCK_REASON_HAS_PENDING_COMPANION] = "HAS_PENDING_COMPANION",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_ALLIANCE] = "INVALID_ALLIANCE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_CLASS] = "INVALID_CLASS",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_COLLECTIBLE] = "INVALID_COLLECTIBLE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_GENDER] = "INVALID_GENDER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_INVALID_RACE] = "INVALID_RACE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_AIR] = "IN_AIR",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_COMBAT] = "IN_COMBAT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_HIDEY_HOLE] = "IN_HIDEY_HOLE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_IN_WATER] = "IN_WATER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED] = "NOT_BLOCKED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN] = "ON_COOLDOWN",
    [COLLECTIBLE_USAGE_BLOCK_REASON_ON_MOUNT] = "ON_MOUNT",
    [COLLECTIBLE_USAGE_BLOCK_REASON_PLACED_IN_HOUSE] = "PLACED_IN_HOUSE",
    [COLLECTIBLE_USAGE_BLOCK_REASON_QUEST_FOLLOWER] = "QUEST_FOLLOWER",
    [COLLECTIBLE_USAGE_BLOCK_REASON_TARGET_REQUIRED] = "TARGET_REQUIRED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_TEMPORARILY_DISABLED] = "TEMPORARILY_DISABLED",
    [COLLECTIBLE_USAGE_BLOCK_REASON_UNUSABLE_BY_COMPANION] = "UNUSABLE_BY_COMPANION",
    [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_BOSS] = "WORLD_BOSS",
    [COLLECTIBLE_USAGE_BLOCK_REASON_WORLD_EVENT] = "WORLD_EVENT",
}

---------------------------------------------------------------------
local function HasActiveAssistant()
    return GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_ASSISTANT) > 0
end

local function SaveCurrentCompanion()
    assistantActive = false
    if (HasPendingCompanion()) then
        previousCompanion = GetCompanionCollectibleId(GetPendingCompanionDefId())
    elseif (HasActiveCompanion()) then
        previousCompanion = GetCompanionCollectibleId(GetActiveCompanionDefId())
    elseif (HasActiveAssistant()) then
        assistantActive = true
    end
end

---------------------------------------------------------------------
-- It seems assistants fire these events, companions do not? Combat pets also count though.
-- The unit tags end up being playerpet1 and playerpet2. They're reused so only 1 and 2
local function OnUnitCreated(_, unitTag)
    assistantActive = HasActiveAssistant()
end

-- This fires about a second after starting to put assistant away
local function OnUnitDestroyed(_, unitTag)
    -- Check that we're putting away an assistant
    if (not assistantActive) then return end

    -- Check that a companion is not already being summoned
    if (HasPendingCompanion() or HasActiveCompanion()) then return end
    
    -- Check that there's no active assistant, because having an assistant out and then summoning a different assistant will fire created -> destroyed
    if (HasActiveAssistant()) then return end

    assistantActive = false

    -- Check that there was a companion active previously
    if (not previousCompanion) then return end
    if (not KyzderpsDerps.savedOptions.companion.resummon) then return end

    -- Check that we can use the collectible
    local blockReason = GetCollectibleBlockReason(previousCompanion)
    if (blockReason ~= 0) then
        KyzderpsDerps:msg(zo_strformat("Could not use collectible <<1>> because: <<2>>",
            GetCollectibleLink(previousCompanion, LINK_STYLE_BRACKETS),
            collectibleBlockReasons[blockReason]))
        return
    end

    -- Finally we can summon
    local cooldown = GetCollectibleCooldownAndDuration(previousCompanion)
    KyzderpsDerps:msg(zo_strformat("Re-summoning <<1>> soon...",
        GetCollectibleLink(previousCompanion, LINK_STYLE_BRACKETS)))
    zo_callLater(function()
        UseCollectible(previousCompanion)
    end, GetCollectibleCooldownAndDuration(previousCompanion) + 500)
end

---------------------------------------------------------------------
local function OnCompanionActivated(_, companionId)
    previousCompanion = GetCompanionCollectibleId(companionId)
end

local function OnCompanionDeactivated()
    if (not HasActiveAssistant()) then
        previousCompanion = nil
    end
end

---------------------------------------------------------------------
local function OnSummonResult(_, summonResult, companionId)
    local summonResults = {
        [COMPANION_SUMMON_RESULT_ADDED_FOR_GROUP_PLAYER] = "ADDED_FOR_GROUP_PLAYER",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_FOLLOWER] = "BLOCKED_BY_FOLLOWER",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_SUBZONE] = "BLOCKED_BY_SUBZONE",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_WORLD_BOSS] = "BLOCKED_BY_WORLD_BOSS",
        [COMPANION_SUMMON_RESULT_BLOCKED_BY_WORLD_EVENT] = "BLOCKED_BY_WORLD_EVENT",
        [COMPANION_SUMMON_RESULT_DATA_NOT_LOADED] = "DATA_NOT_LOADED",
        [COMPANION_SUMMON_RESULT_DEACTIVATED_VANITY_PET] = "DEACTIVATED_VANITY_PET",
        [COMPANION_SUMMON_RESULT_EFFECT_LIMIT] = "EFFECT_LIMIT",
        [COMPANION_SUMMON_RESULT_EXPECTED_DIFFERENT_COMPANION] = "EXPECTED_DIFFERENT_COMPANION",
        [COMPANION_SUMMON_RESULT_GROUP_FULL] = "GROUP_FULL",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_FOLLOWER] = "REMOVED_FOR_FOLLOWER",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_GROUP_PLAYER] = "REMOVED_FOR_GROUP_PLAYER",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_PERF] = "REMOVED_FOR_PERF",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_SUBZONE] = "REMOVED_FOR_SUBZONE",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_VANITY_PET] = "REMOVED_FOR_VANITY_PET",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_WORLD_BOSS] = "REMOVED_FOR_WORLD_BOSS",
        [COMPANION_SUMMON_RESULT_REMOVED_FOR_WORLD_EVENT] = "REMOVED_FOR_WORLD_EVENT",
        [COMPANION_SUMMON_RESULT_SPAWN_FAILED] = "SPAWN_FAILED",
        [COMPANION_SUMMON_RESULT_SUMMON_AUTO_REQUESTED] = "SUMMON_AUTO_REQUESTED",
        [COMPANION_SUMMON_RESULT_SUMMON_FAILED] = "SUMMON_FAILED",
        [COMPANION_SUMMON_RESULT_SUMMON_FAILED_LOW_RAPPORT] = "SUMMON_FAILED_LOW_RAPPORT",
        [COMPANION_SUMMON_RESULT_SUMMON_REQUESTED] = "SUMMON_REQUESTED",
    }
    KyzderpsDerps:msg(zo_strformat("Summon result for <<1>>: <<2>>", GetCompanionName(companionId), summonResults[summonResult]))
end

---------------------------------------------------------------------
local function OnCompanionRapportUpdated(_, companionId, previousRapport, currentRapport)
    if (not KyzderpsDerps.savedOptions.companion.showRapport) then return end

    local arrow = ""
    if (currentRapport > previousRapport) then
        arrow = "|c00FF00↑|r"
    else
        arrow = "|cFF0000↓|r"
    end
    KyzderpsDerps:msg(zo_strformat("Rapport changed for <<1>>: <<2>> → <<3>> <<4>>", GetCompanionName(companionId), previousRapport, currentRapport, arrow))
end

---------------------------------------------------------------------
-- Called on initial player activated
function KyzderpsDerps.InitializeCompanion()
    KyzderpsDerps:dbg("    Initializing Companion module...")

    -- Check the active companion on first login
    SaveCurrentCompanion()

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionUnitCreated", EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionUnitDestroyed", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionActivated", EVENT_COMPANION_ACTIVATED, OnCompanionActivated)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionDeactivated", EVENT_COMPANION_DEACTIVATED, OnCompanionDeactivated)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionSummonResult", EVENT_COMPANION_SUMMON_RESULT, OnSummonResult)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionRapport", EVENT_COMPANION_RAPPORT_UPDATE, OnCompanionRapportUpdated)

--[[
* EVENT_ACTIVE_COMPANION_STATE_CHANGED (*[CompanionState|#CompanionState]* _newState_, *[CompanionState|#CompanionState]* _oldState_)
* EVENT_COMPANION_ACTIVATED (*integer* _companionId_)
* EVENT_COMPANION_DEACTIVATED
* EVENT_COMPANION_EXPERIENCE_GAIN (*integer* _companionId_, *integer* _level_, *integer* _previousExperience_, *integer* _currentExperience_)
* EVENT_COMPANION_RAPPORT_UPDATE (*integer* _companionId_, *integer* _previousRapport_, *integer* _currentRapport_)
* EVENT_COMPANION_SKILLS_FULL_UPDATE (*bool* _isInit_)
* EVENT_COMPANION_SKILL_LINE_ADDED (*integer* _skillLineId_)
* EVENT_COMPANION_SKILL_RANK_UPDATE (*integer* _skillLineId_, *luaindex* _rank_)
* EVENT_COMPANION_SKILL_XP_UPDATE (*integer* _skillLineId_, *integer* _reason_, *luaindex* _rank_, *integer* _previousXP_, *integer* _currentXP_)
* EVENT_COMPANION_SUMMON_RESULT (*[CompanionSummonResult|#CompanionSummonResult]* _summonResult_, *integer* _companionId_)
* EVENT_COMPANION_ULTIMATE_FAILURE (*[CompanionUltimateFailureReason|#CompanionUltimateFailureReason]* _reason_, *string* _companionName_)
* EVENT_OPEN_COMPANION_MENU
* EVENT_RETICLE_TARGET_COMPANION_CHANGED
]]
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "CompanionStateChanged", EVENT_ACTIVE_COMPANION_STATE_CHANGED, function(_, newState, oldState)
        local companionState = {
            [COMPANION_STATE_ACTIVE] = "ACTIVE",
            [COMPANION_STATE_BLOCKED_PERMANENT] = "BLOCKED_PERMANENT",
            [COMPANION_STATE_BLOCKED_TEMPORARY] = "BLOCKED_TEMPORARY",
            [COMPANION_STATE_HIDDEN] = "HIDDEN",
            [COMPANION_STATE_INACTIVE] = "INACTIVE",
            [COMPANION_STATE_INITIALIZED_PENDING] = "INITIALIZED_PENDING",
            [COMPANION_STATE_INITIALIZING] = "INITIALIZING",
            [COMPANION_STATE_PENDING] = "PENDING",
        }
        KyzderpsDerps:dbg(zo_strformat("companion state: <<1>> -> <<2>>", companionState[oldState], companionState[newState]))
    end)
end
