-----------------------------------------------------------
-- Kyzderp's Derps
-- @author Kyzeragon
-----------------------------------------------------------

-- Return a new array of just NPC names, to be used in dropdown
local function getNpcNames()
    local newArray = {}

    if not KyzderpsDerps.savedValues.customTargetFrame.npcCustom then return newArray end

    for name, _ in pairs(KyzderpsDerps.savedValues.customTargetFrame.npcCustom) do
        table.insert(newArray, name)
    end

    return newArray
end

-- Return a new array of just player names, to be used in dropdown
local function getPlayerNames()
    local newArray = {}

    if not KyzderpsDerps.savedValues.customTargetFrame.playerCustom then return newArray end

    for name, _ in pairs(KyzderpsDerps.savedValues.customTargetFrame.playerCustom) do
        table.insert(newArray, name)
    end

    return newArray
end

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
        {
            type = "header",
            name = "General Settings",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Debug",
            tooltip = "Show lots of spam",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.general.debug end,
            setFunc = function(value) KyzderpsDerps.savedOptions.general.debug = value end,
            width = "full",
        },
        {
            type = "submenu",
            name = "Custom Target Name",
            controls = {
                {
                    type = "checkbox",
                    name = "Show Frame",
                    tooltip = "Show frame to allow moving or editing settings",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.move end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.customTargetFrame.move = value
                        CustomTargetCustomName:SetHidden(not value)
                        if (value) then
                            CustomTargetCustomNameLabel:SetText("Sample Name")
                        end
                    end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Text Size",
                    min = 12,
                    max = 72,
                    step = 2,
                    default = 48,
                    width = full,
                    getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.size end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.customTargetFrame.size = value
                        CustomTargetCustomNameLabel:SetFont("$(BOLD_FONT)|"..value.."|soft-shadow-thick")
                    end,
                },
-------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = "NPC Target",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show NPC Names",
                            tooltip = "Display large target name for NPCs",
                            default = true,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.npc.enable end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.npc.enable = value end,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show Only Filter",
                            tooltip = "Display names for NPCs only if they are in the custom filter",
                            default = false,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.npc.useFilter = value end,
                            width = "full",
                            disabled = function() return not KyzderpsDerps.savedOptions.customTargetFrame.npc.enable end,
                        },
                        {
                            type = "header",
                            name = "Custom Filter",
                            width = "half",
                        },
                        {
                            type = "editbox",
                            name = "Add an NPC",
                            width = "full",
                            tooltip = "Enter the full NPC name exactly as it appears, case sensitive!",
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox:GetText() end,
                            setFunc = function(name)
                                if (name == "") then return end

                                -- Clear the textbox
                                WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox:SetText("")

                                -- Add it to the dropdown
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList")
                                local newEntry = {
                                    customName = name,
                                    color = {1, 1, 1},
                                }
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[name] = newEntry
                                namesDropdown:UpdateChoices(getNpcNames())
                                namesDropdown.dropdown:SetSelectedItem(name)
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#NpcFilterBox",
                        },
                        {
                            type = "button",
                            name = "Most Recent Target",
                            tooltip = "Uses the most recently *displayed* NPC name",
                            width = "full",
                            func = function()
                                local editbox = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterBox").editbox
                                editbox:SetText(CustomTargetName.recentNpc)
                                editbox:TakeFocus()
                            end
                        },
                        {
                            type = "dropdown",
                            name = "Select NPC",
                            width = "full",
                            tooltip = "Choose an NPC",
                            choices = getNpcNames(),
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem() end,
                            setFunc = function(name) end,
                            reference = "KyzderpsDerps#NpcFilterList",
                        },
                        {
                            type = "editbox",
                            name = "Custom Name",
                            width = "full",
                            tooltip = "Enter what you want the name to show up as",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                local selected = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName]
                                if (selected) then return selected.customName end
                                return ""
                            end,
                            setFunc = function(name)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName].customName = name
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#NpcCustomBox",
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "colorpicker",
                            name = "Custom Color",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()

                                local selected = KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName]
                                if (selected) then return unpack(selected.color) end
                                return unpack({1, 1, 1})
                            end,
                            setFunc = function(r, g, b)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName].color = {r, g, b}
                            end,
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "button",
                            name = "Remove",
                            width = "full",
                            func = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.npcCustom[selectedName] = nil
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#NpcFilterList")
                                namesDropdown:UpdateChoices(getNpcNames())
                            end
                        },
                    },
                },
-------------------------------------------------------------------------------
                {
                    type = "submenu",
                    name = "Player Target",
                    controls = {
                        {
                            type = "checkbox",
                            name = "Show Player Names",
                            tooltip = "Display large target name for players",
                            default = true,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.player.enable end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.player.enable = value end,
                            width = "full",
                        },
                        {
                            type = "checkbox",
                            name = "Show Only Filter",
                            tooltip = "Show player name only if they are in the custom filter",
                            default = false,
                            getFunc = function() return KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter end,
                            setFunc = function(value) KyzderpsDerps.savedOptions.customTargetFrame.player.useFilter = value end,
                            width = "full",
                            disabled = function() return not KyzderpsDerps.savedOptions.customTargetFrame.player.enable end,
                        },
                        {
                            type = "header",
                            name = "Custom Filter",
                            width = "half",
                        },
                        {
                            type = "editbox",
                            name = "Add a Player",
                            width = "full",
                            tooltip = "Enter the full player name exactly as it appears, including the @. Case sensitive!",
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox:GetText() end,
                            setFunc = function(name)
                                if (name == "") then return end

                                -- Clear the textbox
                                WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox:SetText("")

                                -- Add it to the dropdown
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList")
                                local newEntry = {
                                    customName = name,
                                    color = {1, 1, 1},
                                }
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[name] = newEntry
                                namesDropdown:UpdateChoices(getPlayerNames())
                                namesDropdown.dropdown:SetSelectedItem(name)
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#PlayerFilterBox",
                        },
                        {
                            type = "button",
                            name = "Most Recent Target",
                            tooltip = "Uses the most recently *displayed* player name",
                            width = "full",
                            func = function()
                                local editbox = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterBox").editbox
                                editbox:SetText(CustomTargetName.recentPlayer)
                                editbox:TakeFocus()
                            end
                        },
                        {
                            type = "dropdown",
                            name = "Select Player",
                            width = "full",
                            tooltip = "Choose a player",
                            choices = getPlayerNames(),
                            getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem() end,
                            setFunc = function(name) end,
                            reference = "KyzderpsDerps#PlayerFilterList",
                        },
                        {
                            type = "editbox",
                            name = "Custom Name",
                            width = "full",
                            tooltip = "Enter what you want the name to show up as",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                local selected = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName]
                                if (selected) then return selected.customName end
                                return ""
                            end,
                            setFunc = function(name)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName].customName = name
                            end,
                            isMultiline = false,
                            isExtraWide = false,
                            reference = "KyzderpsDerps#PlayerCustomBox",
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "colorpicker",
                            name = "Custom Color",
                            getFunc = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()

                                local selected = KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName]
                                if (selected) then return unpack(selected.color) end
                                return unpack({1, 1, 1})
                            end,
                            setFunc = function(r, g, b)
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName].color = {r, g, b}
                            end,
                            disabled = function()
                                local selected = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                return selected == ""
                            end
                        },
                        {
                            type = "button",
                            name = "Remove",
                            width = "full",
                            func = function()
                                local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList").combobox.m_comboBox:GetSelectedItem()
                                KyzderpsDerps.savedValues.customTargetFrame.playerCustom[selectedName] = nil
                                local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#PlayerFilterList")
                                namesDropdown:UpdateChoices(getPlayerNames())
                            end
                        },
                    },
                },
            },
        },
        {
            type = "submenu",
            name = "Grievous Retaliation Alert",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable Overlay",
                    tooltip = "Display *very noticeable* text on screen when anyone is taking damage from rezzing a player whose shade is not killed yet in vCR",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.enable end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.grievous.enable = value end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Show Self Only",
                    tooltip = "Show the alert only if you are the one dying from rezzing",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.selfOnly end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.grievous.selfOnly = value end,
                    width = "full",
                },
                {
                    type = "description",
                    title = nil,
                    text = "|c99FF99/kdd grievous|r - Toggles Grievous Retaliation overlay (in case it gets stuck)",
                    width = "full",
                },
            }
        },
        
    }

    LAM:RegisterAddonPanel("KyzderpsDerpsOptions", panelData)
    LAM:RegisterOptionControls("KyzderpsDerpsOptions", optionsData)
end


