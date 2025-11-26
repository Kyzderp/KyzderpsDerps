local KD = KyzderpsDerps
local Sync = KD.Sync

Sync.Kyzerg = {}
local Kyzerg = Sync.Kyzerg

---------------------------------------------------------------------
-- Known accounts
---------------------------------------------------------------------
local function GetSVTable()
    if (not KyzderpsDerpsSavedVariables.Default) then return {} end
    return KyzderpsDerpsSavedVariables.Default
end

local function IsMe(name)
    -- @name
    if (GetSVTable()[name]) then
        return true
    end

    -- char name
    for _, accountData in pairs(GetSVTable()) do
        if (accountData.Values
            and accountData.Values.charInfo
            and accountData.Values.charInfo.characters
            and accountData.Values.charInfo.characters[name]) then
            return true
        end
    end

    return false
end


---------------------------------------------------------------------
-- Misc
---------------------------------------------------------------------
local HAS_MULTIRIDER = {
    ["@Kyzeragon"] = true,
}

local function IndexOf(tab, item)
    for i, v in ipairs(tab) do
        if (v == item) then
            return i
        end
    end
    return -1
end

local drivers = {}
local passengers = {}
local function SortRiders()
    -- TODO: maybe only online in group
    if (#drivers == 0) then
        for name, _ in pairs(GetSVTable()) do
            if (HAS_MULTIRIDER[name]) then
                table.insert(drivers, name)
            else
                table.insert(passengers, name)
            end
        end
        table.sort(drivers)
        table.sort(passengers)
    end

    local index = IndexOf(passengers, GetUnitDisplayName("player"))
    if (index > 0 and index <= #drivers) then
        return drivers[index]
    end
end


---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------
local COMMANDS = {
    -- Port to sender
    k2me = function(fromName)
        if (fromName == GetUnitDisplayName("player") or fromName == GetUnitName("player")) then return end
        if (IsPlayerInGroup(fromName)) then
            JumpToGroupMember(fromName)
        else
            JumpToGuildMember(fromName)
        end
    end,

    -- Port to my house
    khouse = function()
        KD.KHouse.PortToKyzersHouse()
    end,

    -- Port to self house
    khouseself = function()
        RequestJumpToHouse(GetHousingPrimaryHouse())
    end,

    -- Mudball
    kmud = function()
        UseCollectible(601)
    end,

    -- Snowball
    ksnow = function()
        UseCollectible(6932)
    end,

    -- Invite all (CURRENT PLAYER ONLY)
    kinvite = function(fromName)
        if (fromName ~= GetUnitDisplayName("player") and fromName ~= GetUnitName("player")) then return end
        for name, _ in pairs(GetSVTable()) do
            if (name ~= GetUnitDisplayName("player")) then
                KyzderpsDerps:msg("Inviting " .. name)
                GroupInviteByName(name)
            end
        end
    end,

    -- PTE
    kpte = function()
        ExitInstanceImmediately()
    end,

    -- Accept whatever?
    kyes = function()
        local groupInvite = GetGroupInviteInfo()
        if (groupInvite and groupInvite ~= "") then
            AcceptGroupInvite()
            KyzderpsDerps:msg("Accepting group invite")
        elseif (HasLFGReadyCheckNotification()) then
            AcceptLFGReadyCheckNotification()
            KyzderpsDerps:msg("Accepting ready check")
        elseif (GetOfferedQuestShareIds()) then
            local id = GetOfferedQuestShareIds()
            AcceptSharedQuest(id)
            KyzderpsDerps:msg("Accepting quest " .. tostring(id))
        else
            KyzderpsDerps:msg("Nothing to accept")
        end
    end,

    -- reloadui
    krl = function()
        ReloadUI()
    end,

    -- log out
    klog = function()
        Logout()
    end,

    -- quit
    kquit = function()
        Quit()
    end,

    -- Get on multi rider mount
    kmount = function()
        if (HAS_MULTIRIDER[GetUnitDisplayName("player")]) then
            -- TODO: switch to multi rider? maybe automatically when joined group?
            return
        end

        local driver = SortRiders()
        if (driver) then
            UseMountAsPassenger(driver)
        end
        -- TODO: do i even have more multi rider mounts?
    end,
}

function Kyzerg.PrintCommands()
    for cmd, _ in pairs(COMMANDS) do
        KyzderpsDerps:msg(cmd)
    end
end


---------------------------------------------------------------------
-- Chat handler
---------------------------------------------------------------------
local validChannels = {
    -- [CHAT_CHANNEL_PARTY] = true,
}

local function OnChatMessage(_, channelType, fromName, text)
    if (not validChannels[channelType]) then return end

    local func = COMMANDS[text]
    if (func) then
        func(zo_strformat("<<1>>", fromName))
    end
end


---------------------------------------------------------------------
-- Quest share handler
---------------------------------------------------------------------
local function OnQuestShared(_, questId)
    local _, _, _, displayName = GetOfferedQuestShareInfo(questId)

    if (IsMe(displayName)) then
        AcceptSharedQuest(questId)
        KD:msg("Accepting quest " .. questId .. " from " .. displayName)
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function Kyzerg.Initialize()
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "KyzergChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    if (KD.savedOptions.general.experimental) then
        KD:dbg("    Initializing Kyzerg module...")

        EVENT_MANAGER:RegisterForEvent(KD.name .. "KyzergChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)

        -- Put zerg guild channel in valid. This breaks if leaving or joining, but it's not like I do that often
        for i = 1, GetNumGuilds() do
            if (GetGuildId(i) == 580319) then
                local channel = _G["CHAT_CHANNEL_GUILD_" .. tostring(i)]
                validChannels[channel] = true
            end
        end

        EVENT_MANAGER:RegisterForEvent(KD.name .. "KyzergQuestShared", EVENT_QUEST_SHARED, OnQuestShared)
    end
end
