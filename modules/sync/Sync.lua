KyzderpsDerps = KyzderpsDerps or {}

KyzderpsDerps.Sync = KyzderpsDerps.Sync or {}
local Sync = KyzderpsDerps.Sync

---------------------------------------------------------------------
-- Memento syncing for totally not nefarious purposes
---------------------------------------------------------------------

local function HandleCommand(argString)
    if (string.len(argString) < 1) then
        KyzderpsDerps:msg("Usage: /kddsync <searchterm>\nExample: /kddsync cadwell's surprise")
        return
    end

    local search = string.lower(argString)
    for i = 1, GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO) do
        local id = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_MEMENTO, i)
        if (string.find(string.lower(GetCollectibleName(id)), search, 1, true)) then
            StartChatInput(string.format("KDD %s", GetCollectibleLink(id, LINK_STYLE_BRACKETS)), CHAT_CHANNEL_PARTY)
            return
        end
    end
end


---------------------------------------------------------------------
-- Chat parsing: "KDD |H1:collectible:10235|h|h" "KDD 10235"
---------------------------------------------------------------------

local function AttemptCollectible(id)
    if (not IsCollectibleUsable(id)) then return end
    if (IsUnitInCombat("player") and KyzderpsDerps.savedOptions.sync.mementos.ignoreInCombat) then KyzderpsDerps:dbg("ignoring sync because in combat") return end
    UseCollectible(id)
end

-- EVENT_CHAT_MESSAGE_CHANNEL (*[ChannelType|#ChannelType]* _channelType_, *string* _fromName_, *string* _text_, *bool* _isCustomerService_, *string* _fromDisplayName_)
local function OnChatMessage(_, channelType, fromName, text)
    if (channelType ~= CHAT_CHANNEL_PARTY) then return end

    -- |H1:collectible:10235|h|h
    local id
    for collectibleId in string.gmatch(text, "^KDD |H1:collectible:(%d+)|h|h$") do
        id = tonumber(collectibleId)
    end
    if (not id) then
        for collectibleId in string.gmatch(text, "^KDD (%d+)$") do
            id = tonumber(collectibleId)
        end
    end

    if (not IsCollectibleUnlocked(id)) then return end

    -- Randomized delay
    local delay = KyzderpsDerps.savedOptions.sync.mementos.delay
    if (KyzderpsDerps.savedOptions.sync.mementos.random) then
        delay = math.random(0, delay)
        KyzderpsDerps:dbg(string.format("waiting %dms", delay))
    end

    if (delay == 0) then
        AttemptCollectible(id)
    else
        zo_callLater(function()
            AttemptCollectible(id)
        end, delay)
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function Sync.Initialize()
    KyzderpsDerps:dbg("    Initializing Sync module...")

    SLASH_COMMANDS["/kddsync"] = HandleCommand

    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    if (KyzderpsDerps.savedOptions.sync.mementos.party) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SyncChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)
    end
end