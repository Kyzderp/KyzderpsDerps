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
local function IndexOf(tab, item)
    for i, v in ipairs(tab) do
        if (v == item) then
            return i
        end
    end
    return -1
end

local function NameIsPlayer(name)
    return GetUnitName("player") == name or GetUnitDisplayName("player") == name
end

local drivers = {}
local onlineCharNames = {}
local passengers = {}
local riders = {}
local function FindNearestDriver(fromName)
    ZO_ClearTable(drivers)
    ZO_ClearTable(onlineCharNames)
    ZO_ClearTable(passengers)

    local isPassenger = false

    -- Only online in group
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local atName = GetUnitDisplayName(unitTag)
        -- if (IsMe(atName) and IsUnitOnline(unitTag)) then
        if (IsUnitOnline(unitTag)) then
            local charName = GetUnitName(unitTag)
            onlineCharNames[atName] = charName

            local mountedState, isRidingGroupMount, hasFreePassengerSlot = GetTargetMountedStateInfo(charName)
            KyzderpsDerps:dbg(zo_strformat("<<1>>: mountedState <<2>> isRidingGroupMount <<3>> hasFreePassengerSlot <<4>>", charName, mountedState, isRidingGroupMount and "true" or "false", hasFreePassengerSlot and "true" or "false"))
            if (mountedState == MOUNTED_STATE_MOUNT_RIDER and isRidingGroupMount and hasFreePassengerSlot) then
                table.insert(drivers, unitTag)
            else
                table.insert(passengers, unitTag)
                if (AreUnitsEqual(unitTag, "player")) then
                    isPassenger = true
                end
            end
        end
    end

    table.sort(drivers)
    table.sort(passengers)
    d("drivers", drivers)
    d("passengers", passengers)

    -- look for closest driver
    local driver
    local distance = math.huge
    if (isPassenger) then
        local _, pX, pY, pZ = GetUnitRawWorldPosition("player")
        for _, unitTag in ipairs(drivers) do
            if (IsUnitInGroupSupportRange(unitTag)) then
                local _, x, y, z = GetUnitRawWorldPosition(unitTag)
                local dist = math.pow(x - pX, 2) + math.pow(y - pY, 2) + math.pow(z - pZ, 2)
                d(GetUnitDisplayName(unitTag) .. " " .. dist)
                if (dist < distance) then
                    driver = unitTag
                    distance = dist
                end
            end
        end
    end

    return GetUnitDisplayName(driver)
end

local function KMount()
    local driver = FindNearestDriver()
    if (driver) then
        KyzderpsDerps:msg("Trying to use " .. driver .. "'s mount")
        UseMountAsPassenger(driver)
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

    -- TODO: port to crown

    -- Port to house
    khouse = function(_, text)
        KD.KHouse.PortToHouse(string.sub(text, 8))
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
        if (not NameIsPlayer(fromName)) then return end
        for name, _ in pairs(GetSVTable()) do
            if (name ~= GetUnitDisplayName("player")) then
                KyzderpsDerps:msg("Inviting " .. name)
                GroupInviteByName(name)
            end
        end
    end,

    -- PTE
    kpte = ExitInstanceImmediately,

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
    krl = ReloadUI,

    -- log out
    klog = Logout,

    -- quit
    kquit = Quit,

    -- Get on multi rider mount as passenger
    kmount = KMount,

    -- Equip multi rider mount
    kmm = function()
        local multiMounts = { -- Incomprehensive. Just the ones I have
            13808, -- Warparty Timber Mammoth
            13897, -- Duo-Dynamo Dungeon Delver Spider
            6972, -- Duo-Dynamo Dwarven Spider
            13552, -- Duo-Dynamo Hollowsteel Spider
            11887, -- Nightmare Pillion Courser
            10254, -- Wayrest Vanner Pillion Steed
        }

        for _, id in ipairs(multiMounts) do
            if (IsCollectibleUnlocked(id) and not IsCollectibleActive(id, GAMEPLAY_ACTOR_CATEGORY_PLAYER)) then
                UseCollectible(id)
                return
            end
        end
    end,

    -- ktp
    ktp = function(_, text)
        KD.PortToAny(string.sub(text, 5))
    end,

    -- krez
    krez = Revive,
}

function Kyzerg.PrintCommands()
    for cmd, _ in pairs(COMMANDS) do
        KyzderpsDerps:msg(cmd)
    end
end


---------------------------------------------------------------------
-- Chat handler
---------------------------------------------------------------------
local validChannels = {}

local function OnChatMessage(_, channelType, fromName, text)
    if (not validChannels[channelType]) then return end

    local cmd
    for word in text:gmatch("%S+") do
        if (word and word ~= "") then
            cmd = word
            break
        end
    end
    if (not cmd) then return end

    local func = COMMANDS[cmd]
    if (func) then
        func(zo_strformat("<<1>>", fromName), text)
    end
end


---------------------------------------------------------------------
-- Quest share handler
---------------------------------------------------------------------
local function OnQuestShared(_, questId)
    local questName, _, _, displayName = GetOfferedQuestShareInfo(questId)
    KD:msg(displayName .. " shared " .. questName .. " (" .. questId .. ")")

    if (IsMe(displayName)) then
        AcceptSharedQuest(questId)
        KD:msg("Accepting quest " .. questName .. " (" .. questId .. ") from " .. displayName)
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local function OnFocusChanged(_, hasFocus)
    if (hasFocus) then
        StopAllMovement()
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
function Kyzerg.Initialize()
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "KyzergChatMessage", EVENT_CHAT_MESSAGE_CHANNEL)
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "KyzergFocus", EVENT_GAME_FOCUS_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(KD.name .. "KyzergQuestShared", EVENT_QUEST_SHARED)

    if (KD.savedOptions.general.experimental or KD.savedOptions.kyzerg.group) then
        KD:dbg("    Initializing Kyzerg module...")

        EVENT_MANAGER:RegisterForEvent(KD.name .. "KyzergChatMessage", EVENT_CHAT_MESSAGE_CHANNEL, OnChatMessage)

        if (KD.savedOptions.general.experimental) then
            -- Stop moving when tabbing back in
            EVENT_MANAGER:RegisterForEvent(KD.name .. "KyzergFocus", EVENT_GAME_FOCUS_CHANGED, OnFocusChanged)

            -- Put zerg guild channel in valid. This breaks if leaving or joining, but it's not like I do that often
            for i = 1, GetNumGuilds() do
                if (GetGuildId(i) == 580319) then
                    local channel = _G["CHAT_CHANNEL_GUILD_" .. tostring(i)]
                    validChannels[channel] = true
                end
            end

            -- Auto accept quests from myself
            EVENT_MANAGER:RegisterForEvent(KD.name .. "KyzergQuestShared", EVENT_QUEST_SHARED, OnQuestShared)
        end

        validChannels[CHAT_CHANNEL_PARTY] = KD.savedOptions.kyzerg.group
        SLASH_COMMANDS["/kmount"] = KMount

    end
end
-- /script KyzderpsDerps.savedOptions.kyzerg.group = true KyzderpsDerps.Sync.Kyzerg.Initialize()
