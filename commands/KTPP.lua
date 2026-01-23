local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

local function StripAtAndLower(name)
    if (StartsWith(atName, "@")) then
        return string.lower(string.sub(atName, 2))
    end
    return string.lower(atName)
end

local function IsTargetPlayer(atName, target)
    return StripAtAndLower(atName) == target
end

local function PortToPlayerName(atName)
    local target = StripAtAndLower(atName)

    -- Check group
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitDisplayName(unitTag)
        if (IsUnitOnline(unitTag) and IsTargetPlayer(name, target)) then
            local zoneName = GetZoneNameById(GetZoneId(GetUnitZoneIndex(unitTag)))
            KyzderpsDerps:msg(zo_strformat("Porting to group member <<1>> in <<2>>", name, zoneName))
            JumpToGroupMember(name)
            return
        end
    end

    -- Check friends
    for i = 1, GetNumFriends() do
        local name, _, status = GetFriendInfo(i)
        if (status ~= PLAYER_STATUS_OFFLINE and IsTargetPlayer(name, target)) then
            local _, _, _, _, _, _, _, zoneId = GetFriendCharacterInfo(i)
            KyzderpsDerps:msg(zo_strformat("Porting to friend <<1>> in <<2>>", name, GetZoneNameById(zoneId)))
            JumpToFriend(name)
            return
        end
    end

    -- Check guilds
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        for j = 1, GetNumGuildMembers(guildId) do
            local name, _, _, status = GetGuildMemberInfo(guildId, j)
            if (status ~= PLAYER_STATUS_OFFLINE and IsTargetPlayer(name, target)) then
                local _, _, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, j)
                KyzderpsDerps:msg(zo_strformat("Porting to guild member <<1>> in <<2>>", name, GetZoneNameById(zoneId)))
                JumpToGuildMember(name)
                return
            end
        end
    end

    KyzderpsDerps:msg("Couldn't find any player named " .. atName)
end

function KyzderpsDerps.PortToPlayer(argString)
    if (not argString or argString == "") then
        KyzderpsDerps:msg("Usage: /ktpp <@name>  ||  Example: /ktpp @Kyzeragon")
        return
    end

    PortToPlayerName(argString)
end
