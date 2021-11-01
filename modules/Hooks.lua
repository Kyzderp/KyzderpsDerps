KyzderpsDerps = KyzderpsDerps or {}

local csaCategories = {
    [CSA_CATEGORY_COUNTDOWN_TEXT] = "COUNTDOWN_TEXT",
    [CSA_CATEGORY_EXTERNAL_HANDLE] = "EXTERNAL_HANDLE",
    [CSA_CATEGORY_INVALID] = "INVALID",
    [CSA_CATEGORY_LARGE_TEXT] = "LARGE_TEXT",
    [CSA_CATEGORY_MAJOR_TEXT] = "MAJOR_TEXT",
    [CSA_CATEGORY_NO_TEXT] = "NO_TEXT",
    [CSA_CATEGORY_RAID_COMPLETE_TEXT] = "RAID_COMPLETE_TEXT",
    [CSA_CATEGORY_SCRYING_PROGRESS_TEXT] = "SCRYING_PROGRESS_TEXT",
    [CSA_CATEGORY_SMALL_TEXT] = "SMALL_TEXT",
}

---------------------------------------------------------------------
local function HookCenterScreenAnnounce()
    local origQueueMessage = CENTER_SCREEN_ANNOUNCE.QueueMessage
    CENTER_SCREEN_ANNOUNCE.QueueMessage = function(s, messageParams)
        KyzderpsDerps.PrintSpam("|c3bdb5e" .. tostring(messageParams:GetMainText()) .. "|r")
        KyzderpsDerps.PrintSpam("|c3bdb5e" .. tostring(messageParams:GetSecondaryText()) .. "|r")
        KyzderpsDerps.PrintSpam("|c207532" .. csaCategories[messageParams:GetCategory()] .. "|r")
        KyzderpsDerps.PrintSpam(messageParams)
        return origQueueMessage(s, messageParams)
    end
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeHooks()
    HookCenterScreenAnnounce()
end
