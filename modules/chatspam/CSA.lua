KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.ChatSpam = KyzderpsDerps.ChatSpam or {}
local Spam = KyzderpsDerps.ChatSpam

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

local alertCategories = {
    [UI_ALERT_CATEGORY_ERROR] = "ERROR",
    [UI_ALERT_CATEGORY_ALERT] = "ALERT",
}

---------------------------------------------------------------------
local function HookCenterScreenAnnounce(s, messageParams)
    local mainText = messageParams:GetMainText()
    local secondaryText = messageParams:GetSecondaryText()

    if (mainText ~= nil or secondaryText ~= nil) then
        if (LibFilteredChatPanel) then
            LibFilteredChatPanel:GetSystemFilter():AddMessage(string.format("%s - %s / %s",
                csaCategories[messageParams:GetCategory()],
                tostring(mainText),
                tostring(secondaryText)))
        end
    end
    return false
end

---------------------------------------------------------------------
local function HookAlert(category, soundId, message)
    if (LibFilteredChatPanel and category and message) then
        LibFilteredChatPanel:GetSystemFilter():AddMessage(string.format("|cede795%s - %s",
                alertCategories[category],
                tostring(message)))
    end
    return false
end


---------------------------------------------------------------------
function Spam.InitializeCSAHook()
    ZO_PreHook(CENTER_SCREEN_ANNOUNCE, "QueueMessage", HookCenterScreenAnnounce)
    ZO_PreHook("ZO_Alert", HookAlert)
end
