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
-- Can be called multiple times because the quest could have multiple
-- dialogues before actually being accepted
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
-- Chatter start handler. This is just for "normal" chatter, and
-- doesn't include the starting of quests
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
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterBegin", EVENT_CHATTER_BEGIN)
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterEnd", EVENT_CHATTER_END)

    EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterBegin", EVENT_CHATTER_BEGIN, OnChatter)
    EVENT_MANAGER:RegisterForEvent(KD.name .. "ChatterEnd", EVENT_CHATTER_END, function()
        EVENT_MANAGER:UnregisterForEvent(KD.name .. "ChatterQuestOffered", EVENT_QUEST_OFFERED)
    end)
end

function Chatter.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Reroll writhing crafting quests",
            tooltip = "When you interact with Armorer Reistaff, automatically accepts or rerolls the quest. Currently, enchanting, provisioning, and alchemy quests are rerolled, while only blacksmithing, woodworking, and clothier quests are accepted. English client only. You can adjust this or add different languages in KyzderpsDerps/modules/questchatter",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.chatter.rerollReistaff end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.chatter.rerollReistaff = value
                    Chatter.Initialize()
                end,
            width = "full",
        },
    }
end
