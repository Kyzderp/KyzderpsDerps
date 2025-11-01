local KD = KyzderpsDerps
local Sync = KD.Sync

Sync.HiveMind = {}
local HM = Sync.HiveMind

---------------------------------------------------------------------
-- Known accounts
---------------------------------------------------------------------
local function GetSVTable()
    if (not KyzderpsDerpsSavedVariables.Default) then return {} end
    return KyzderpsDerpsSavedVariables.Default
end

---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------
local COMMANDS = {
    -- Port to sender
    porttome = function(fromName)
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
    gohome = function()
        RequestJumpToHouse(GetHousingPrimaryHouse())
    end,

    -- Mudball
    mud = function()
        UseCollectible(601)
    end,

    -- Snowball
    snow = function()
        UseCollectible(6932)
    end,

    -- Invite all (CURRENT PLAYER ONLY)
    inviteall = function(fromName)
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
}

function HM.PrintCommands()
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
-- Initialize
---------------------------------------------------------------------
function HM.Initialize()
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "HiveMindChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    if (KD.savedOptions.general.experimental) then
        KD:dbg("    Initializing HiveMind module...")

        EVENT_MANAGER:RegisterForEvent(KD.name .. "HiveMindChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)

        -- Put hive mind guild channel in valid. This breaks if leaving or joining, but it's not like I do that often
        for i = 1, GetNumGuilds() do
            if (GetGuildId(i) == 580319) then
                local channel = _G["CHAT_CHANNEL_GUILD_" .. tostring(i)]
                validChannels[channel] = true
            end
        end
    end
end
