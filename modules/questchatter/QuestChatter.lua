local KD = KyzderpsDerps
KD.Chatter = {}
local Chatter = KD.Chatter

---------------------------------------------------------------------
-- Dialogue that should be handled, by title first
---------------------------------------------------------------------
-- Dialogue options to advance (only first option is checked; are there any options that aren't first?)
local optionsToAdvance = {
    ["-Armorer Reistaff-"] = {
        ["What can I do to help?"] = true,
    },
}

-- Quest options for which we should accept the quest
local questOptionToAccept = {
    ["-Armorer Reistaff-"] = {
        ["How many do you need?"] = true,
        ["All right. I'll make three restoration staves."] = true,
        
        ["What kind of armor do you need?"] = true,
        ["All right. I'll craft two cuirasses."] = true,

        ["Why won't your friends replace their damaged armor?"] = true,
        ["All right. I'll make two epaulets."] = true,

        ["How many shields do you need?"] = true,
        ["All right. I'll make two shields."] = true,

        ["What do you need?"] = true,
        ["All right. I'll make two arm cops."] = true,

        ["What kind of weapons do you need?"] = true,
        ["All right. I'll craft three axes."] = true,
    },
}

-- Quest options for which we should reset the dialogue
local questOptionToReset = {
    ["-Armorer Reistaff-"] = {
        ["How many potions do you need?"] = true,
        ["What kind of enchantments are you looking for?"] = true,
    },
}


---------------------------------------------------------------------
-- Quest offered handler, called immediately after advancing dialogue
---------------------------------------------------------------------
local function OnQuestOffered()
    local title = ZO_InteractWindowTargetAreaTitle:GetText()

    local dialogue, response = GetOfferedQuestInfo()

    -- Accept based on option text
    if (questOptionToAccept[title] and questOptionToAccept[title][response]) then
        KyzderpsDerps:msg("Accepting quest: " .. response)
        AcceptOfferedQuest()
        -- Don't unregister quest offered yet; it could have more steps before actually accepting
        -- Instead, just listen for quest added, and if so end the interaction, which unregisters
        EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterQuestAdded", EVENT_QUEST_ADDED, function()
            EndInteraction(INTERACTION_CONVERSATION)
            KyzderpsDerps:msg("Chatter ended.")
        end)

    -- Reset based on option text
    elseif (questOptionToReset[title] and questOptionToReset[title][response]) then
        KyzderpsDerps:msg("Rerolling dialogue because: " .. response)
        ResetChatter()
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterQuestOffered", EVENT_QUEST_OFFERED)

    -- Unregister handler if nothing matches: user gets to deal with it
    else
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterQuestOffered", EVENT_QUEST_OFFERED)
    end
end


---------------------------------------------------------------------
-- Chatter start handler. This doesn't include the starting of quests
---------------------------------------------------------------------
local function OnChatter()
    local optionCount = GetChatterOptionCount()
    if (optionCount == 0) then return end

    -- Checking only first option should be fine?
    local optionString, optionType = GetChatterOption(1)

    local title = ZO_InteractWindowTargetAreaTitle:GetText()
    local body = ZO_InteractWindowTargetAreaBodyText:GetText()

    -- Accept based on option text
    if (optionsToAdvance[title] and optionsToAdvance[title][optionString]) then
        KyzderpsDerps:msg("Advancing dialogue: " .. optionString)
        SelectChatterOption(1)
        EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterQuestOffered", EVENT_QUEST_OFFERED, OnQuestOffered)
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Chatter.Initialize()
    EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterBegin", EVENT_CHATTER_BEGIN, OnChatter)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterEnd", EVENT_CHATTER_END, function()
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterQuestOffered", EVENT_QUEST_OFFERED)
    end)
end
