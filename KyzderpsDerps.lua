-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "0.1.0"

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
    },
}

-- TODO: make name the key?
local defaultValues = {
    customTargetFrame = {
        x = GuiRoot:GetWidth() / 2,
        y = GuiRoot:GetHeight() / 4 * 3,
        npcCustom = {
            {
                name = "Saint Olms the Just",
                customName = "[Olms]",
                color = {1, 0.7, 0.2},
            },
            {
                name = "Saint Felms the Bold",
                customName = "[Felms]",
                color = {1, 0, 0},
            },
            {
                name = "Saint Llothis the Pious",
                customName = "[Llothis]",
                color = {0, 1, 0},
            },
        },
        playerFilter = {},
    },
    grievous = {
        x = GuiRoot:GetWidth() / 2,
        y = GuiRoot:GetHeight() / 2,
    },
}

---------------------------------------------------------------------
-- Initialize 
function KyzderpsDerps:Initialize()
    d("Initializing Kyzderp's Derps...")

    -- Settings and saved variables
    self.savedOptions = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 2, "Options", defaultOptions)
    self.savedValues = ZO_SavedVars:NewAccountWide("KyzderpsDerpsSavedVariables", 2, "Values", defaultValues)
    KyzderpsDerps:CreateSettingsMenu()

    -- Initialize modules
    CustomTargetName:Initialize()
    Grievous:Initialize()

    if (KyzderpsDerps.savedOptions.general.debug) then
        d("Kyzderp's Derps initialized!")
    end
end
 
---------------------------------------------------------------------
-- On Load
function KyzderpsDerps.OnAddOnLoaded(event, addonName)
    if addonName == KyzderpsDerps.name then
        KyzderpsDerps:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name, EVENT_ADD_ON_LOADED, KyzderpsDerps.OnAddOnLoaded)

---------------------------------------------------------------------
-- Commands
function KyzderpsDerps.handleCommand(argString)
    local args = {}
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
    end

    if (args.length == 0) then
        d("/kdd <grievous>")
        return
    end

    if (KyzderpsDerps.savedOptions.general.debug) then
        d(args)
    end

    if (args[1] == "grievous") then
        GrievousRetaliation:SetHidden(not GrievousRetaliation:IsHidden())
    else
        d("/kdd <grievous>")
    end
end

SLASH_COMMANDS["/kdd"] = KyzderpsDerps.handleCommand
