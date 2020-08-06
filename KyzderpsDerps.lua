-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "1.0.1"

-- Defaults
local defaultOptions = {
    general = {
        debug = false,
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
-- Post Load (player loaded)
function KyzderpsDerps.OnPlayerActivated(_, initial)
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name, EVENT_PLAYER_ACTIVATED)

    -- Soft dependency on pChat because its chat restore will overwrite
    for i = 1, #KyzderpsDerps.messages do
        d(KyzderpsDerps.messages[i])
    end
    KyzderpsDerps.messages = {}
end

-- Collect messages for displaying later when addon is not fully loaded
KyzderpsDerps.messages = {}
function KyzderpsDerps:dbg(msg)
    if (not KyzderpsDerps.savedOptions.general.debug) then return end
    if (CHAT_SYSTEM.primaryContainer) then
        d(msg)
    else
        KyzderpsDerps.messages[#KyzderpsDerps.messages + 1] = msg
    end
end

---------------------------------------------------------------------
-- Commands
function KyzderpsDerps.handleCommand(argString)
    local args = {}
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
    end

    if (args.length == 0) then
        CHAT_SYSTEM:AddMessage("Usage: /kdd <grievous||bosstimer>")
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

    -- Unknown
    else
        CHAT_SYSTEM:AddMessage("Usage: /kdd <grievous||bosstimer>")
    end
end

SLASH_COMMANDS["/kdd"] = KyzderpsDerps.handleCommand
