local KD = KyzderpsDerps
local Sync = KD.Sync

Sync.HiveMind = {}
local HM = Sync.HiveMind

---------------------------------------------------------------------
-- Functions
---------------------------------------------------------------------
local COMMANDS = {
    -- Port to sender
    porttome = function(fromName)
        if (IsPlayerInGroup(fromName)) then
            JumpToGroupMember(fromName)
        else
            JumpToGuildMember(fromName)
        end
    end,

    -- Accept ready check
    acceptready = function()
        AcceptLFGReadyCheckNotification()
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
        UseCollectible(0) -- TODO
    end,

    -- Snowball
    snow = function()
        UseCollectible(0) -- TODO
    end,
}


---------------------------------------------------------------------
-- Chat handler
---------------------------------------------------------------------
local validChannels = {CHAT_CHANNEL_PARTY}

local function OnChatMessage(_, channelType, fromName, text)
    if (not validChannels[channelType]) then return end

    local func = COMMANDS[text]
    if (func) then
        func(fromName)
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
            local guildId = GetGuildId(i)
            if (GetGuildName(guildId) == "The Flawless Conquerors") then
                d(guildId)
                local channel = _G["CHAT_CHANNEL_GUILD_" .. tostring(i)]
                validChannels[channel] = true
            end
        end
    end
end
