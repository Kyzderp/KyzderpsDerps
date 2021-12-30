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

    local usage = "Usage: /kdd <grievous || bosstimer || played || points || totalpoints || armory || junkstyle>"

    if (length == 0) then
        CHAT_SYSTEM:AddMessage(usage)
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
        CHAT_SYSTEM:AddMessage(KyzderpsDerps.BuildPlayed())

    -- points
    elseif (args[1] == "points") then
        CHAT_SYSTEM:AddMessage(KyzderpsDerps.BuildPoints())

    -- totalpoints
    elseif (args[1] == "totalpoints") then
        CHAT_SYSTEM:AddMessage(KyzderpsDerps.BuildTotalPoints())

    -- armory
    elseif (args[1] == "armory") then
        CHAT_SYSTEM:AddMessage(KyzderpsDerps.BuildArmory())

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
            CHAT_SYSTEM:AddMessage("Usage: /kdd furn <itemnamefilter>")
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
                    CHAT_SYSTEM:AddMessage(link)
                end
            end
        until furnitureId == nil

    -- Unknown
    else
        CHAT_SYSTEM:AddMessage(usage)
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

function KyzderpsDerps.InitializeCommands()
    SLASH_COMMANDS["/kdd"] = HandleKDDCommand
    SLASH_COMMANDS["/fixui"] = FixUI
    SLASH_COMMANDS["/ids"] = ToggleLuiIds

    -- Shortcut commands
    SLASH_COMMANDS["/bastian"] = function() UseCollectible(9245) end
    SLASH_COMMANDS["/mirri"] = function() UseCollectible(9353) end

    SLASH_COMMANDS["/tythis"] = function() UseCollectible(267) end
    SLASH_COMMANDS["/nuzhimeh"] = function() UseCollectible(301) end
    SLASH_COMMANDS["/ezabi"] = function() UseCollectible(6376) end
    SLASH_COMMANDS["/fezez"] = function() UseCollectible(6378) end
    SLASH_COMMANDS["/jangleplume"] = function() UseCollectible(8994) end
    SLASH_COMMANDS["/peddler"] = function() UseCollectible(8995) end

    SLASH_COMMANDS["/armory"] = function() UseCollectible(9745) end
    SLASH_COMMANDS["/ghrasharog"] = function() UseCollectible(9745) end
end
