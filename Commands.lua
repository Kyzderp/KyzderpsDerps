KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------
-- Commands
local function HandleKDDCommand(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    local usage = "Usage: /kdd <grievous || bosstimer || played || points || totalpoints || armory || junkstyle || hidelogout || normlogout || questtracker || openall || writhing>"

    if (length == 0) then
        CHAT_ROUTER:AddSystemMessage(usage)
        return
    end

    KyzderpsDerps:dbg(args)

    -- Toggle grievous retaliation overlay
    if (args[1] == "grievous") then
        GrievousRetaliation:SetHidden(not GrievousRetaliation:IsHidden())

    -- toggle bosstimer
    elseif (args[1] == "bosstimer") then
        KyzderpsDerps.savedOptions.spawnTimer.enable = not KyzderpsDerps.savedOptions.spawnTimer.enable
        SpawnTimerContainer:SetHidden(not SpawnTimerContainer:IsHidden())
        if (WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable")) then
            WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable"):UpdateValue()
        end

    -- played
    elseif (args[1] == "played") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildPlayed())

    -- points
    elseif (args[1] == "points") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildPoints())

    -- totalpoints
    elseif (args[1] == "totalpoints") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildTotalPoints())

    -- armory
    elseif (args[1] == "armory") then
        CHAT_ROUTER:AddSystemMessage(KyzderpsDerps.Altoholic.BuildArmory())

    -- junk style pages
    elseif (args[1] == "junkstyle" or args[1] == "junkstyles") then
        local junkedItems = {}
        local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
        for _, item in pairs(bagCache) do
            -- Skip items that are already junk, obviously
            if (not IsItemJunk(item.bagId, item.slotIndex)) then
                local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
                local itemType, specializedType = GetItemLinkItemType(itemLink)
                if (itemType == ITEMTYPE_CONTAINER and specializedType == SPECIALIZED_ITEMTYPE_CONTAINER_STYLE_PAGE) then
                    SetItemIsJunk(item.bagId, item.slotIndex, true)
                    if (not junkedItems[itemLink]) then
                        junkedItems[itemLink] = 0
                    end
                    junkedItems[itemLink] = junkedItems[itemLink] + 1
                end
            end
        end

        local displayMessage = "Marked the following items as junk:"
        for itemLink, num in pairs(junkedItems) do
            displayMessage = string.format("%s\n|cDDDDDD%s x%d", displayMessage, itemLink, num)
        end
        KyzderpsDerps:msg(displayMessage)

    -- resetchests
    elseif (args[1] == "resetchests") then
        KyzderpsDerps.ChatSpam.ResetCounter()

    -- List furnishings in a home with a filter, undocumented because could be... controversial
    elseif (args[1] == "furn") then
        if (length ~= 2) then
            CHAT_ROUTER:AddSystemMessage("Usage: /kdd furn <itemnamefilter>")
            return
        end

        KyzderpsDerps:msg("Furnishings in this house matching \"" .. args[2] .. "\":")
        local furnitureId = nil
        local itemId = nil
        repeat
            furnitureId = GetNextPlacedHousingFurnitureId(furnitureId)
            if furnitureId ~= nil then
                local link = GetPlacedFurnitureLink(furnitureId, LINK_STYLE_BRACKETS)
                if (string.find(string.lower(GetItemLinkName(link)), string.lower(args[2]))) then
                    CHAT_ROUTER:AddSystemMessage(link)
                end
            end
        until furnitureId == nil

    -- toggles hiding on logout
    elseif (args[1] == "hide") then
        KyzderpsDerps.savedOptions.misc.hideOnLogout = not KyzderpsDerps.savedOptions.misc.hideOnLogout
        KyzderpsDerps:msg(string.format("Hiding upon logout is now set to %s", tostring(KyzderpsDerps.savedOptions.misc.hideOnLogout)))

    -- logs out without loading few addons
    elseif (args[1] == "normlogout") then
        KyzderpsDerps.PreLogout.doNotLoadOverride = true
        KyzderpsDerps:msg("Logging out without loading few addons...")
        Logout()

    -- toggles the quest tracker panel
    elseif (args[1] == "questtracker") then
        ZO_FocusedQuestTrackerPanel:SetHidden(not ZO_FocusedQuestTrackerPanel:IsHidden())

    -- re-scans and opens containers
    elseif (args[1] == "openall") then
        KyzderpsDerps.Opener.OpenAllInBackpack()

    -- opens writhing wall event crafting boxes
    elseif (args[1] == "writhing") then
        KyzderpsDerps.Opener.OpenAllWrithingCrafting()

    -- Unknown
    else
        CHAT_ROUTER:AddSystemMessage(usage)
    end
end

local function FixUI()
    if (MajorCourageTracker) then
        MajorCourageTracker.Reset()
    end
    if (PurgeTracker) then
        PurgeTracker.Reset()
    end
    if (HealerBFF) then
        HealerBFF.Reset()
    end
    if (JoGroup) then
        JoGroup.ReAnchor()
    end
    if (btg) then
        btg.CheckActivation()
    end
end

local function ToggleLuiIds()
    if (not LUIE or not LUIE.SpellCastBuffs) then
        KyzderpsDerps:msg("LUI SpellCastBuffs is not enabled")
        return
    end
    LUIE.SpellCastBuffs.SV.ShowDebugAbilityId = not LUIE.SpellCastBuffs.SV.ShowDebugAbilityId
    LUIE.SpellCastBuffs.Reset()
    KyzderpsDerps:msg("Toggled showing IDs on LUI buffs/debuffs")
end

---------------------------------------------------------------------
-- Port to zone
---------------------------------------------------------------------
local overlandZones = {
    [104] = true, -- Alik'r Desert
    [1413] = true, -- Apocrypha
    [1027] = true, -- Artaeum
    [381] = true, -- Auridon
    [281] = true, -- Bal Foyen
    [92] = true, -- Bangkorai
    [535] = true, -- Betnikh
    [1191] = true, -- Blackreach
    [1208] = true, -- Blackreach: Arkthzand Cavern
    [1161] = true, -- Blackreach: Greymoor Caverns
    [1261] = true, -- Blackwood
    [280] = true, -- Bleakrock Isle
    [980] = true, -- Clockwork City
    [981] = true, -- The Brass Fortress
    [347] = true, -- Coldharbour
    [888] = true, -- Craglorn
    [57] = true, -- Deshaan
    [101] = true, -- Eastmarch
    [267] = true, -- Eyevea
    [1463] = true, -- The Scholarium
    [1282] = true, -- Fargrave
    [1283] = true, -- The Shambles
    [1383] = true, -- Galen
    [3] = true, -- Glenumbra
    [823] = true, -- Gold Coast
    [383] = true, -- Grahtwood
    [108] = true, -- Greenshade
    [816] = true, -- Hew's Bane
    [1318] = true, -- High Isle
    [537] = true, -- Khenarthi's Roost
    [58] = true, -- Malabal Tor
    [726] = true, -- Murkmire
    [1086] = true, -- Northern Elsweyr
    [382] = true, -- Reaper's March
    [20] = true, -- Rivenspire
    [117] = true, -- Shadowfen
    [1133] = true, -- Southern Elsweyr
    [41] = true, -- Stonefalls
    [19] = true, -- Stormhaven
    [534] = true, -- Stros M'Kai
    [1011] = true, -- Summerset
    [1414] = true, -- Telvanni Peninsula
    [1286] = true, -- The Deadlands
    [1207] = true, -- The Reach
    [103] = true, -- The Rift
    [849] = true, -- Vvardenfell
    [1443] = true, -- West Weald
    [1160] = true, -- Western Skyrim
    [684] = true -- Wrothgar
}

local function IsZoneValid(zoneId)
    if (not CanJumpToPlayerInZone(zoneId)) then return false end
    
    return overlandZones[zoneId] == true
end

-- Port to any player in group, friends, or guilds who is in the
-- desired zone. As a fallback, port to any overland zone (hopefully)
local function PortToAnyInZone()
    local desiredZoneId = KyzderpsDerps.savedOptions.misc.wayshrineZoneId
    if (not desiredZoneId) then
        KyzderpsDerps:msg("Wayshrine: |cFF0000Invalid zone ID! Please check the Kyzderps setting: Miscellaneous > /wayshrine zone ID")
        return
    end

    local playerName = GetUnitDisplayName("player")
    local zoneName = GetZoneNameById(desiredZoneId)
    local fallbackFunc

    -- Check group
    for i = 1, GetGroupSize() do
        local unitTag = GetGroupUnitTagByIndex(i)
        local name = GetUnitDisplayName(unitTag)
        if (IsUnitOnline(unitTag) and name ~= playerName) then
            local zoneId = GetZoneId(GetUnitZoneIndex(unitTag))
            if (zoneId == desiredZoneId) then
                KyzderpsDerps:msg(zo_strformat("Porting to group member <<1>> in <<2>>", name, zoneName))
                JumpToGroupMember(name)
                return
            elseif (IsZoneValid(zoneId) and not fallbackFunc) then
                fallbackFunc = function()
                    KyzderpsDerps:msg(zo_strformat("Unable to find any players in <<1>>; porting to group member <<2>> in <<3>> instead", zoneName, name, GetZoneNameById(zoneId)))
                    JumpToGroupMember(name)
                end
            end
        end
    end

    -- Check friends
    for i = 1, GetNumFriends() do
        local name, _, status = GetFriendInfo(i)
        if (status ~= PLAYER_STATUS_OFFLINE and name ~= playerName) then
            local _, _, _, _, _, _, _, zoneId = GetFriendCharacterInfo(i)
            if (zoneId == desiredZoneId) then
                KyzderpsDerps:msg(zo_strformat("Porting to friend <<1>> in <<2>>", name, zoneName))
                JumpToFriend(name)
                return
            elseif (IsZoneValid(zoneId) and not fallbackFunc) then
                fallbackFunc = function()
                    KyzderpsDerps:msg(zo_strformat("Unable to find any players in <<1>>; porting to friend <<2>> in <<3>> instead", zoneName, name, GetZoneNameById(zoneId)))
                    JumpToFriend(name)
                end
            end
        end
    end

    -- Check guilds
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        for j = 1, GetNumGuildMembers(guildId) do
            local name, _, _, status = GetGuildMemberInfo(guildId, j)
            if (status ~= PLAYER_STATUS_OFFLINE and name ~= playerName) then
                local _, _, _, _, _, _, _, zoneId = GetGuildMemberCharacterInfo(guildId, j)
                if (zoneId == desiredZoneId) then
                    KyzderpsDerps:msg(zo_strformat("Porting to guild member <<1>> in <<2>>", name, zoneName))
                    JumpToGuildMember(name)
                    return
                elseif (IsZoneValid(zoneId) and not fallbackFunc) then
                    fallbackFunc = function()
                        KyzderpsDerps:msg(zo_strformat("Unable to find any players in <<1>>; porting to guild member <<2>> in <<3>> instead", zoneName, name, GetZoneNameById(zoneId)))
                        JumpToGuildMember(name)
                    end
                end
            end
        end
    end

    -- Fallback to any overland zone, so you can use the wayshrine
    if (fallbackFunc) then
        fallbackFunc()
        return
    end

    -- Fallback to outside owned houses that are near wayshrines
    local decentHouses = {
        68, -- Sugar Bowl Suite
        32, -- Mournoth Keep
        63, -- Enchanted Snow Globe Home
        25, -- Cyrodilic Jungle House
        13, -- Snugpod
        78, -- Proudspire Manor
        80, -- Stillwaters Retreat
        37, -- Serenity Falls Estate

        -- Requires loadscreen
        6, -- Flaming Nix Deluxe Garret
        19, -- Kragenhome
        1, -- Mara's Kiss Public House
        3, -- The Ebony Flask Inn Room
    }
    for _, houseId in ipairs(decentHouses) do
        local collectibleId = GetCollectibleIdForHouse(houseId)
        if (IsCollectibleUnlocked(collectibleId)) then
            KyzderpsDerps:msg(zo_strformat("Unable to find any players in <<1>> or overland zones; porting outside of your <<2>> instead", zoneName, GetCollectibleName(collectibleId)))
            RequestJumpToHouse(houseId, true)
            return
        end
    end

    -- So lonely
    KyzderpsDerps:msg("Couldn't find anywhere to port to :(")
end

---------------------------------------------------------------------
function KyzderpsDerps.InitializeCommands()
    SLASH_COMMANDS["/kdd"] = HandleKDDCommand
    SLASH_COMMANDS["/fixui"] = FixUI
    SLASH_COMMANDS["/ids"] = ToggleLuiIds
    SLASH_COMMANDS["/wayshrine"] = PortToAnyInZone
    SLASH_COMMANDS["/refreshsurvey"] = KyzderpsDerps.Loot.RefreshSurvey

    -- Shortcut commands
    -- TODO: change to a table... and probably add /bank /merchant
    SLASH_COMMANDS["/bastian"] = function() UseCollectible(9245) end
    SLASH_COMMANDS["/mirri"] = function() UseCollectible(9353) end
    SLASH_COMMANDS["/ember"] = function() UseCollectible(9911) end
    SLASH_COMMANDS["/isobel"] = function() UseCollectible(9912) end
    SLASH_COMMANDS["/sharp"] = function() UseCollectible(11113) end
    SLASH_COMMANDS["/azandar"] = function() UseCollectible(11114) end
    SLASH_COMMANDS["/tanlorin"] = function() UseCollectible(12172) end
    SLASH_COMMANDS["/zerith"] = function() UseCollectible(12173) end

    SLASH_COMMANDS["/tythis"] = function() UseCollectible(267) end
    SLASH_COMMANDS["/nuzhimeh"] = function() UseCollectible(301) end
    SLASH_COMMANDS["/ezabi"] = function() UseCollectible(6376) end
    SLASH_COMMANDS["/fezez"] = function() UseCollectible(6378) end
    SLASH_COMMANDS["/jangleplume"] = function() UseCollectible(8994) end
    SLASH_COMMANDS["/peddler"] = function() UseCollectible(8995) end
    SLASH_COMMANDS["/steward"] = function() UseCollectible(9743) end
    SLASH_COMMANDS["/delegate"] = function() UseCollectible(9744) end
    SLASH_COMMANDS["/pyroclast"] = function() UseCollectible(11097) end
    SLASH_COMMANDS["/xyn"] = function() UseCollectible(12414) end

    SLASH_COMMANDS["/armory"] = function() UseCollectible(9745) end
    SLASH_COMMANDS["/ghrasharog"] = function() UseCollectible(9745) end

    SLASH_COMMANDS["/decon"] = function() UseCollectible(10184) end
    SLASH_COMMANDS["/giladil"] = function() UseCollectible(10184) end
end
