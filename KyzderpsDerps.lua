-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "1.33.0"

-- Defaults
local defaultOptions = {
    general = {
        debug = false,
        experimental = false,
    },
    ui = {
        reposition = false,
        hideQuestInTrial = false,
        aoeColors = false,
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
        savedWheels = {},
    },
    misc = {
        loginCollectible = 0, -- None
        blockItemNotReady = false,
        combatReticle = false,
        repair = true,
        hideOnLogout = false,
        tributeTimer = true,
        printScoreFormat = false,
        startChatScoreFormat = false,
        wayshrineZoneId = 849, -- Vvardenfell
        autoRefreshSurvey = false,
    },
    preLogout = {
        loadFewAddons = false,
        -- Some defaults will be added on first initialization
        addonsToLoadFirstTime = true,
        addonsToLoad = {},
    },
    companion = {
        resummon = true,
        showRapport = true,
        showSummonResult = true,
    },
    antispud = {
        equipped = {
            enable = false,
            printToChat = false,
            fourPieceExceptions = {}, -- Note: I didn't rename the var, but this means general exception now, not just 4-piece. See Equipped.lua
            buffTheGroup = {
                pa = false,
                majorSlayer = false,
                majorCourage = false,
                minorBerserk = false,
                majorResolve = false,
                empower = false,
                spaulder = false,
                pp = false,
            },
            spaulder = false,
        },
        state = {
            includeActivityFinder = true,
        },
        mundus = {
            checkPve = false,
            pve = {},
            checkPvp = false,
            pvp = {},
        },
        food = {
            pve = false,
            pvp = false,
            boss = false,
        },
        log = false,
        torte = false,
    },
    hodor = {
        horn = false,
        hornLabel = false,
    },
    fashion = {
        equipSkinForVamp = false,
        restoreAfterVamp = false,
        restoreAfterVampSameOnly = true,
        vampSkinId = 0,
        autoTabard = false,
        changeRecallStyle = "Do nothing",
        recallIncludeDefault = false,
    },
    chatSpam = {
        useLFCP = true,
        printScore = false,
        printChest = false,
        printChestSummary = false,
    },
    infoPanel = {
        chestsLooted = false,
        chestsLootedDungeonsOnly = true,
    },
    integrations = {
        checkBRHelper = false,
        checkAsylumTracker = false,
        checkAsylumStatusPanel = false,
    },
    opener = {
        delay = 0,
        openMirriBag = false,
        openGunnySack = false,
        openToxinSatchel = false,
        openPurpleZenithar = false,
        openZenitharCurrency = false,
        -- openEmberWallet = false,
        openPelinalsBoonBox = false,
        openPelinalsBoonBoxInIC = false,
        openPurplePlunderSkull = false,
        openCrowTouchedCoffer = false,
    },
    sync = {
        mementos = {
            party = false,
            delay = 0,
            random = false,
            ignoreInCombat = true,
        },
    },
    worldIcons = {
        destination = false,
        dungeonChest = 1, -- 1 = off, 2 = not in combat, 3 = always
        dungeonSack = 1,
        trialChest = 1,
        trialSack = 1,
        xalvakka = false,
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
    },
    chestsLooted = {
        x = GuiRoot:GetWidth() - 300,
        y = 0,
    },
}

---------------------------------------------------------------------
local debugFilter

---------------------------------------------------------------------
function KyzderpsDerps.SavePosition()
    KyzderpsDerps.savedValues.customTargetFrame.x = CustomTargetCustomName:GetLeft()
    KyzderpsDerps.savedValues.customTargetFrame.y = CustomTargetCustomName:GetTop()

    KyzderpsDerps.savedValues.deathAlert.x = DeathAlertContainer:GetLeft()
    KyzderpsDerps.savedValues.deathAlert.y = DeathAlertContainer:GetTop()

    KyzderpsDerps.savedValues.spawnTimer.x = SpawnTimerContainer:GetLeft()
    KyzderpsDerps.savedValues.spawnTimer.y = SpawnTimerContainer:GetTop()

    KyzderpsDerps.savedValues.chestsLooted.x = KDDInfoPanel:GetLeft()
    KyzderpsDerps.savedValues.chestsLooted.y = KDDInfoPanel:GetTop()
end

---------------------------------------------------------------------
-- Post Load (player loaded) one-time only
local function OnPlayerActivated(_, initial)
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

    KyzderpsDerps.QuickSlots.Initialize()
    KyzderpsDerps.Companion.Initialize()
    KyzderpsDerps.Hodor.Initialize()
    KyzderpsDerps.AntiSpud.Initialize()
    KyzderpsDerps.ChatSpam.Initialize()
    KyzderpsDerps.Reticle.Initialize()
    KyzderpsDerps.Sync.Initialize()
    KyzderpsDerps.Fashion.Initialize()
    KyzderpsDerps.ScoreFormat.Initialize()
    KyzderpsDerps.UIElements.Initialize()
    KyzderpsDerps.WorldIcons.Initialize()
    KyzderpsDerps.Loot.InitializeSurvey()
    if (KyzderpsDerps.savedOptions.general.experimental) then
        if (btg) then btg.debug = true end
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
    msg = tostring(msg)
    if (not KyzderpsDerps.savedOptions.general.debug) then return end
    if (debugFilter) then
        debugFilter:AddMessage(msg)
    elseif (CHAT_SYSTEM.primaryContainer) then
        d("|c3bdb5e[KD] |r" .. msg)
    else
        KyzderpsDerps.dbgMessages[#KyzderpsDerps.dbgMessages + 1] = "|c3bdb5e[KDDelay] |r" .. msg
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
-- Initialize
local function Initialize()
    -- Settings and saved variables
    KyzderpsDerps.savedOptions = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 3, "Options", defaultOptions)
    KyzderpsDerps.savedValues = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 3, "Values", defaultValues)

    local filterIcon = "/esoui/art/mappins/dragon_fly.dds"
    if (LibFilteredChatPanel) then
        debugFilter = LibFilteredChatPanel:CreateFilter(KyzderpsDerps.name .. "Debug", filterIcon, {0.5, 0.7, 0.5}, false)
    end

    KyzderpsDerps:dbg("Initializing Kyzderp's Derps...")

    KyzderpsDerps.InitializeCommands()

    -- Initialize modules
    KyzderpsDerps.InitializeCustomTargetName()
    KyzderpsDerps.InitializeGrievous()
    KyzderpsDerps.SpawnTimer.Initialize()
    KyzderpsDerps.DeathAlert.Initialize()
    KyzderpsDerps.Altoholic.Initialize()
    KyzderpsDerps.KHouse.Initialize()
    KyzderpsDerps.AutoRepair.Initialize()
    KyzderpsDerps.Opener.Initialize()
    KyzderpsDerps.Integrations.Initialize()
    KyzderpsDerps.Tribute.Initialize()
    KyzderpsDerps.PreLogout.Initialize()
    KyzderpsDerps.InitializeAOE()

    -- Key bindings
    ZO_CreateStringId("SI_BINDING_NAME_KDD_CLEARSEARCH", "Clear Search Text")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_1", "Select Quickslot 1")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_2", "Select Quickslot 2")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_3", "Select Quickslot 3")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_4", "Select Quickslot 4")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_5", "Select Quickslot 5")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_6", "Select Quickslot 6")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_7", "Select Quickslot 7")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_QUICKSLOT_8", "Select Quickslot 8")
    ZO_CreateStringId("SI_BINDING_NAME_KDD_ANTISPUD_DISMISS", "Dismiss AntiSpud Notification")

    -- BEHOLD! My stuff.
    if (KyzderpsDerps.savedOptions.general.experimental) then
        ZO_CreateStringId("SI_BINDING_NAME_KDD_PRINTPOS", "Print Position & Draw Icon")
        KyzderpsDerps.InitializeSpam()
        SLASH_COMMANDS["/wyrdsight"] = function() UseCollectible(10305) end
    end

    -- Block "Item not ready" spam
    ZO_PreHook(ZO_AlertText_GetHandlers(), EVENT_ITEM_ON_COOLDOWN, function()
        return KyzderpsDerps.savedOptions.misc.blockItemNotReady
    end)

    -- Initialize some tables: this is a workaround in order to populate tables with default values but still
    -- have the keys be deletable, because the deleted keys get repopulated when loaded otherwise reeeeeee
    if (KyzderpsDerps.savedOptions.spawnTimer.ignoreListFirstTime) then
        KyzderpsDerps.savedOptions.spawnTimer.ignoreListFirstTime = false
        KyzderpsDerps.savedOptions.spawnTimer.ignoreList = {
            ["Bone Colossus"] = true,
            ["Dremora Kynreeve"] = true,
            ["Seducer Predator"] = true,
            ["Watcher"] = true,
        }
        KyzderpsDerps:dbg("Populated boss timer ignore list defaults")
    end
    if (KyzderpsDerps.savedOptions.preLogout.addonsToLoadFirstTime) then
        KyzderpsDerps.savedOptions.preLogout.addonsToLoadFirstTime = false
        KyzderpsDerps.savedOptions.preLogout.addonsToLoad = {
            ["AddonSelector"] = true,
            ["AlphaGear"] = true,
            ["CarosSkillPointSaver"] = true,
            ["DolgubonsLazyWritCreator"] = true,
            ["IIfA"] = true,
            ["KyzderpsDerps"] = true,
            ["LibVotansAddonList"] = true,
            ["RulebasedInventory"] = true,
            ["VotansKeybinder"] = true,

            ["libAddonKeybinds"] = true,
            ["LibAddonMenu-2.0"] = true,
            ["LibAsync"] = true,
            ["LibCustomMenu"] = true,
            ["LibDialog"] = true,
            ["LibLazyCrafting"] = true,
            ["LibScrollableMenu"] = true,
        }
        KyzderpsDerps:dbg("Populated addonsToLoad list defaults")
    end

    -- TODO: remove this at some point
    -- I accidentally left this in the top level in defaults, so this is for clearing people's SV
    KyzderpsDerps.savedOptions.printScoreFormat = nil

    -- This needs to go after the options changes obviously... dumb programmer
    KyzderpsDerps:CreateSettingsMenu()

    KyzderpsDerps:dbg("Kyzderp's Derps initialized!")
end

---------------------------------------------------------------------
-- On Load
local function OnAddOnLoaded(_, addonName)
    if addonName == KyzderpsDerps.name then
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED)
        Initialize()
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
