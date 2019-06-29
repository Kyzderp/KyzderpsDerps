-----------------------------------------------------------
-- KyzderpsDerps
-- @author Kyzeragon
-----------------------------------------------------------

KyzderpsDerps = {}
KyzderpsDerps.name = "KyzderpsDerps"
KyzderpsDerps.version = "0.0.2"

-- Defaults
local defaultOptions = {
    general = {
        debug = false,
    },
    customTargetFrame = {
        move = false,
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

local defaultValues = {
    customTargetFrame = {
        x = GuiRoot:GetWidth() / 2,
        y = GuiRoot:GetHeight() / 4 * 3,
        npcFilter = {},
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
