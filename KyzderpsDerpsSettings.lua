-----------------------------------------------------------
-- Kyzderp's Derps
-- @author Kyzeragon
-----------------------------------------------------------

function KyzderpsDerps:CreateSettingsMenu()
    local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
    -- Register the Options panel with LAM
    local panelData = 
    {
        type = "panel",
        name = "Kyzderp's Derps",
        author = "Kyzeragon",
        version = KyzderpsDerps.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    -- Set the actual panel data
    local optionsData = {
        [1] = {
            type = "description",
            title = nil,
            text = "|c99FF99/kdd grievous|r - Toggles Grievous Retaliation overlay (in case it gets stuck)",
            width = "full",
        },
        [2] = {
            type = "header",
            name = "General Settings",
            width = "full",
        },
        [3] = {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show lots of spam",
            default = false,
            getFunc = function() return KyzderpsDerps.SavedOptions.Debug end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.Debug = value end,
            width = "full",
        },
        [4] = {
            type = "checkbox",
            name = "Show Frame (Read Tooltip)",
            tooltip = "Show frame to allow moving. I haven't made this very good yet, you'll need to hover over a target to get the display first and then it will remain on your screen.",
            default = false,
            getFunc = function() return KyzderpsDerps.SavedOptions.Move end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.Move = value end,
            width = "full",
        },
        [5] = {
            type = "header",
            name = "NPC Target",
            width = "full",
        },
        [6] = {
            type = "checkbox",
            name = "Enable Npc Name",
            tooltip = "Display large target name for NPCs",
            default = true,
            getFunc = function() return KyzderpsDerps.SavedOptions.EnableNpc end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.EnableNpc = value end,
            width = "full",
        },
        [7] = {
            type = "checkbox",
            name = "Npc Name Filter",
            tooltip = "Use NPC filter when displaying NPC target",
            default = false,
            getFunc = function() return KyzderpsDerps.SavedOptions.NpcFilterOn end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.NpcFilterOn = value end,
            width = "full",
            disabled = function() return not KyzderpsDerps.SavedOptions.EnableNpc end,
        },
        [8] = {
            type = "header",
            name = "Player Target",
            width = "full",
        },
        [9] = {
            type = "checkbox",
            name = "Enable Player Name",
            tooltip = "Display large target name for players",
            default = true,
            getFunc = function() return KyzderpsDerps.SavedOptions.EnablePlayer end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.EnablePlayer = value end,
            width = "full",
        },
        [10] = {
            type = "checkbox",
            name = "Player Name Filter (TODO)",
            tooltip = "Use player filter when displaying player target",
            default = false,
            getFunc = function() return KyzderpsDerps.SavedOptions.PlayerFilterOn end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.PlayerFilterOn = value end,
            width = "full",
            disabled = function() return not KyzderpsDerps.SavedOptions.EnablePlayer end,
        },
        [11] = {
            type = "header",
            name = "Grievous Retaliation",
            width = "full",
        },
        [12] = {
            type = "checkbox",
            name = "Enable Overlay",
            tooltip = "Display *very noticeable* text on screen when ANYONE is taking damage from rezzing a player whose shade is not killed yet in vCR",
            default = true,
            getFunc = function() return KyzderpsDerps.SavedOptions.EnableGrievous end,
            setFunc = function(value) KyzderpsDerps.SavedOptions.EnableGrievous = value end,
            width = "full",
        },
    }

    LAM:RegisterAddonPanel("KyzderpsDerpsOptions", panelData)
    LAM:RegisterOptionControls("KyzderpsDerpsOptions", optionsData)
end