-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "1.8.1"

-- Defaults
local defaultOptions = {
    general = {
        debug = false,
        experimental = false,
    },
    customTargetFrame = {
        move = false,
        size = 48,
        npc = {
            enable = true,
            useFilter = true,
        },
        player = {
            enable = true,
            useFilter = true,
        },
    },
    grievous = {
        enable = true,
        selfOnly = true,
        timer = 1000,
    },
    spawnTimer = {
        enable = false,
        background = true,
        alert = {
            enable = false,
            seconds = 10,
        },
        chat = {
            enable = false,
            timestamp = false,
        },
        -- Some defaults will be added on first initialization
        ignoreListFirstTime = true,
        ignoreList = {
        },
        scamp = 150,
    },
    deathAlert = {
        enable = true,
        unlock = false,
        size = 30,
    },
    quickSlots = {
        enable = true,
    },
    misc = {
        loginCollectible = 0, -- None
    },
    companion = {
        resummon = true,
        showRapport = true,
    },
}

local defaultValues = {
    customTargetFrame = {
        x = GuiRoot:GetWidth() / 2,
        y = GuiRoot:GetHeight() / 4 * 3,
        -- This stuff should go in options, but uhhhh would have to fix and migrate
        npcCustom = {
            ["Saint Olms the Just"] = {
                customName = "[Olms]",
                color = {1, 0.7, 0.2},
            },
            ["Saint Felms the Bold"] = {
                customName = "[Felms]",
                color = {1, 0, 0},
            },
            ["Saint Llothis the Pious"] = {
                customName = "[Llothis]",
                color = {0, 1, 0},
            },
        },
        playerCustom = {
        },
    },
    grievous = {
        x = GuiRoot:GetWidth() / 2,
        y = GuiRoot:GetHeight() / 2,
    },
    spawnTimer = {
        x = GuiRoot:GetWidth() / 3,
        y = GuiRoot:GetHeight() / 3,
        timers = {
        },
    },
    deathAlert = {
        x = GuiRoot:GetWidth() / 3 * 2,
        y = GuiRoot:GetHeight() / 3,
    },
    playedChart = {
        characters = {},
    },
    charInfo = {
        characters = {},
    }
}

---------------------------------------------------------------------
-- Initialize 
function KyzderpsDerps:Initialize()
    -- Settings and saved variables
    self.savedOptions = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 3, "Options", defaultOptions)
    self.savedValues = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 3, "Values", defaultValues)

    KyzderpsDerps:dbg("Initializing Kyzderp's Derps...")

    -- Initialize modules
    CustomTargetName:Initialize()
    Grievous:Initialize()
    SpawnTimer:Initialize()
    DeathAlert:Initialize()
    PlayedChart:Initialize()
    KyzderpsDerps.InitializeKHouse() -- I think I want to use this format from now on. Gotta refactor.

    ZO_CreateStringId("SI_BINDING_NAME_KDD_CLEARSEARCH", "Clear Search Text")

    if (KyzderpsDerps.savedOptions.general.experimental) then
        ZO_CreateStringId("SI_BINDING_NAME_KDD_PRINTPOS", "Print Position & Draw Icon")
        KDD_Aoe:Initialize()
        KyzderpsDerps.InitializeFocusedFire()
    end

    -- Initialize some tables: this is a workaround in order to populate tables with default values but still
    -- have the keys be deletable, because the deleted keys get repopulated when loaded otherwise reeeeeee
    if (self.savedOptions.spawnTimer.ignoreListFirstTime) then
        self.savedOptions.spawnTimer.ignoreListFirstTime = false
        self.savedOptions.spawnTimer.ignoreList = {
            ["Bone Colossus"] = true,
            ["Dremora Kynreeve"] = true,
            ["Seducer Predator"] = true,
            ["Watcher"] = true,
        }
        KyzderpsDerps:dbg("Populated boss timer ignore list defaults")
    end

    -- This needs to go after the options changes obviously... dumb programmer
    KyzderpsDerps:CreateSettingsMenu()

    KyzderpsDerps:dbg("Kyzderp's Derps initialized!")
end
 
---------------------------------------------------------------------
-- On Load
function KyzderpsDerps.OnAddOnLoaded(_, addonName)
    if addonName == KyzderpsDerps.name then
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED)
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_PLAYER_ACTIVATED, KyzderpsDerps.OnPlayerActivated)
        KyzderpsDerps:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED, KyzderpsDerps.OnAddOnLoaded)

---------------------------------------------------------------------
-- Post Load (player loaded) one-time only
function KyzderpsDerps.OnPlayerActivated(_, initial)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name, EVENT_PLAYER_ACTIVATED)

    -- Soft dependency on pChat because its chat restore will overwrite
    for i = 1, #KyzderpsDerps.dbgMessages do
        d(KyzderpsDerps.dbgMessages[i])
    end
    KyzderpsDerps.dbgMessages = {}
    for i = 1, #KyzderpsDerps.messages do
        CHAT_SYSTEM:AddMessage(KyzderpsDerps.messages[i])
    end
    KyzderpsDerps.messages = {}

    KDD_QuickSlots:Initialize()
    KyzderpsDerps.InitializeCompanion()
    if (KyzderpsDerps.savedOptions.general.experimental) then
        KDD_AntiSpud:Initialize()
        KyzderpsDerps.InitializeWaypoint()
    end

    if (KyzderpsDerps.savedOptions.misc.loginCollectible ~= 0) then
        if (IsCollectibleUnlocked(KyzderpsDerps.savedOptions.misc.loginCollectible)) then
            KyzderpsDerps:msg("Using " .. GetCollectibleLink(KyzderpsDerps.savedOptions.misc.loginCollectible, LINK_STYLE_BRACKETS))
            UseCollectible(KyzderpsDerps.savedOptions.misc.loginCollectible)
        else
            KyzderpsDerps:msg("You haven't unlocked " .. GetCollectibleLink(KyzderpsDerps.savedOptions.misc.loginCollectible, LINK_STYLE_BRACKETS))
        end
    end
end

-- Collect messages for displaying later when addon is not fully loaded
KyzderpsDerps.dbgMessages = {}
function KyzderpsDerps:dbg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[KD] |r" .. tostring(msg)
    if (not KyzderpsDerps.savedOptions.general.debug) then return end
    if (CHAT_SYSTEM.primaryContainer) then
        d(msg)
    else
        KyzderpsDerps.dbgMessages[#KyzderpsDerps.dbgMessages + 1] = msg
    end
end

-- Collect messages for displaying later when addon is not fully loaded
KyzderpsDerps.messages = {}
function KyzderpsDerps:msg(msg)
    if (not msg) then return end
    msg = "|c3bdb5e[Kyzderp's Derps] |caaaaaa" .. tostring(msg) .. "|r"
    if (CHAT_SYSTEM.primaryContainer) then
        CHAT_SYSTEM:AddMessage(msg)
    else
        KyzderpsDerps.messages[#KyzderpsDerps.messages + 1] = msg
    end
end

---------------------------------------------------------------------
-- Commands
function KyzderpsDerps.handleCommand(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    local usage = "Usage: /kdd <grievous || bosstimer || played || points || junkstyle>"

    if (length == 0) then
        CHAT_SYSTEM:AddMessage(usage)
        return
    end

    KyzderpsDerps:dbg(args)

    -- Toggle grievous retaliation overlay
    if (args[1] == "grievous") then
        GrievousRetaliation:SetHidden(not GrievousRetaliation:IsHidden())

    -- List bosses for debug
    elseif (args[1] == "listbosses") then
        for i = 1, MAX_BOSSES do
            if (DoesUnitExist("boss"..i)) then
                CHAT_SYSTEM:AddMessage("boss"..i.." is "..GetUnitName("boss"..i))
            else
                CHAT_SYSTEM:AddMessage("boss"..i.." does not exist")
            end
        end

    -- toggle bosstimer
    elseif (args[1] == "bosstimer") then
        KyzderpsDerps.savedOptions.spawnTimer.enable = not KyzderpsDerps.savedOptions.spawnTimer.enable
        SpawnTimerContainer:SetHidden(not SpawnTimerContainer:IsHidden())
        if (WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable")) then
            WINDOW_MANAGER:GetControlByName("KyzderpsDerps#SpawnTimerEnable"):UpdateValue()
        end

    -- test death
    elseif (args[1] == "death") then
        if (length > 1) then
            DeathAlert.OnDeathStateChanged(1, args[2], true)
        else
            DeathAlert.OnDeathStateChanged(1, "group1", true)
        end

    -- played
    elseif (args[1] == "played") then
        CHAT_SYSTEM:AddMessage(PlayedChart.buildPlayed())

    -- points
    elseif (args[1] == "points") then
        CHAT_SYSTEM:AddMessage(PlayedChart.buildPoints())

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

SLASH_COMMANDS["/kdd"] = KyzderpsDerps.handleCommand
SLASH_COMMANDS["/fixui"] = FixUI
SLASH_COMMANDS["/ids"] = ToggleLuiIds
