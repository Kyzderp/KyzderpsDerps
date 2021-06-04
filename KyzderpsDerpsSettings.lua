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

-- Return a new array of just boss names, to be used in dropdown
local function getBossNames()
    local newArray = {}

    if not KyzderpsDerps.savedOptions.spawnTimer.ignoreList then return newArray end

    for name, _ in pairs(KyzderpsDerps.savedOptions.spawnTimer.ignoreList) do
        table.insert(newArray, name)
    end

    return newArray
end

local collectibleIds = {
    479, -- Witchmother's Whistle
    1167, -- The Pie of Misrule
    1168, -- Breda's Bottomless Mead Mug
    9012, -- Jubilee Cake 2021
    0, -- None
}
local collectibleNames = {
    GetCollectibleName(479), -- Witchmother's Whistle
    GetCollectibleName(1167), -- The Pie of Misrule
    GetCollectibleName(1168), -- Breda's Bottomless Mead Mug
    GetCollectibleName(9012), -- Jubilee Cake 2021
    "- None -", -- None
}

function KyzderpsDerps:CreateSettingsMenu()
    local LAM = LibAddonMenu2
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
-------------------------------------------------------------------------------
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
                    type = "slider",
                    name = "Fade Time",
                    tooltip = "Time in milliseconds after the damage taken in which the overlay will fade. Grievous Retaliation ticks every half a second",
                    min = 100,
                    max = 3000,
                    step = 100,
                    default = 1000,
                    width = full,
                    getFunc = function() return KyzderpsDerps.savedOptions.grievous.timer end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.grievous.timer = value
                    end,
                },
                {
                    type = "description",
                    title = nil,
                    text = "|c99FF99/kdd grievous|r - Toggles Grievous Retaliation overlay (in case it gets stuck)",
                    width = "full",
                },
            }
        },
-------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Boss Timer",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "World and public dungeon bosses respawn approximately 5:06 after they die. Delve bosses have the same base cooldown, but they respawn earlier if a player who has not completed it enters the delve area.",
                    width = "full",
                },
                {
                    type = "description",
                    title = nil,
                    text = "The death detection only works if the boss has a boss HP bar at the top of the screen, which includes all world bosses but not delve or public dungeon bosses except Summerset and newer. There is also currently no smart detection of bosses, so a single boss event with multiple boss enemies will display as separate deaths.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Boss List Panel",
                    tooltip = "Display the timers on recently killed bosses",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.enable end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.spawnTimer.enable = value
                        SpawnTimerContainer:SetHidden(not value)
                    end,
                    width = "full",
                    reference = "KyzderpsDerps#SpawnTimerEnable"
                },
                {
                    type = "checkbox",
                    name = "Boss List Panel Background",
                    tooltip = "Display a background for the panel",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.background end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.spawnTimer.background = value
                        SpawnTimerContainerBackdrop:SetHidden(not value)
                    end,
                    width = "full",
                    disabled = function() return not KyzderpsDerps.savedOptions.spawnTimer.enable end,
                },
                {
                    type = "checkbox",
                    name = "Enable Respawn Alert",
                    tooltip = "Display a center-screen announcement and notification sound when a boss is about to respawn",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.alert.enable end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.spawnTimer.alert.enable = value end,
                    width = "full",
                },
                {
                    type = "slider",
                    name = "Alert Time",
                    tooltip = "How many seconds before a boss is predicted to respawn should the alert be shown?",
                    min = 0,
                    max = 60,
                    step = 1,
                    default = 10,
                    width = full,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.alert.seconds end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.spawnTimer.alert.seconds = value
                    end,
                    disabled = function() return not KyzderpsDerps.savedOptions.spawnTimer.alert.enable end,
                },
                {
                    type = "checkbox",
                    name = "Enable Chat Output",
                    tooltip = "Display a message in chat when a boss dies",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.chat.enable end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.spawnTimer.chat.enable = value end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Chat Timestamp",
                    tooltip = "Add a timestamp to the boss death chat message",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.chat.timestamp end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.spawnTimer.chat.timestamp = value end,
                    width = "full",
                    disabled = function() return not KyzderpsDerps.savedOptions.spawnTimer.chat.enable end,
                },
                {
                    type = "header",
                    name = "Ignore Filter",
                    width = "half",
                },
                {
                    type = "editbox",
                    name = "Add a Boss",
                    width = "full",
                    tooltip = "Enter the full Boss name exactly as it appears, case sensitive!",
                    getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterBox").editbox:GetText() end,
                    setFunc = function(name)
                        if (name == "") then return end

                        -- Clear the textbox
                        WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterBox").editbox:SetText("")

                        -- Add it to the dropdown
                        local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterList")
                        KyzderpsDerps.savedOptions.spawnTimer.ignoreList[name] = true
                        namesDropdown:UpdateChoices(getBossNames())
                        namesDropdown.dropdown:SetSelectedItem(name)
                    end,
                    isMultiline = false,
                    isExtraWide = false,
                    reference = "KyzderpsDerps#IgnoreFilterBox",
                },
                {
                    type = "dropdown",
                    name = "Select Boss",
                    width = "full",
                    tooltip = "Choose a boss name to delete",
                    choices = getBossNames(),
                    getFunc = function() return WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterList").combobox.m_comboBox:GetSelectedItem() end,
                    setFunc = function(name) end,
                    reference = "KyzderpsDerps#IgnoreFilterList",
                },
                {
                    type = "button",
                    name = "Remove",
                    width = "full",
                    func = function()
                        local selectedName = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterList").combobox.m_comboBox:GetSelectedItem()
                        if (not selectedName or selectedName == "") then return end
                        KyzderpsDerps.savedOptions.spawnTimer.ignoreList[selectedName] = nil
                        local namesDropdown = WINDOW_MANAGER:GetControlByName("KyzderpsDerps#IgnoreFilterList")
                        namesDropdown:UpdateChoices(getBossNames())
                    end,
                },
                {
                    type = "header",
                    name = "Imperial City Scamps",
                    width = "half",
                },
                {
                    type = "slider",
                    name = "Respawn Time",
                    tooltip = "How many seconds does it take for the Trove or Cunning Scamp to respawn? This value can be different depending on Imperial City events and location of the scamp, e.g. the EP location with 2 rooms spawns every 150s during the IC event.",
                    min = 150,
                    max = 900,
                    step = 15,
                    default = 150,
                    width = full,
                    getFunc = function() return KyzderpsDerps.savedOptions.spawnTimer.scamp end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.spawnTimer.scamp = value
                    end,
                },
            },
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Death Alert",
            controls = {
                {
                    type = "checkbox",
                    name = "Enable",
                    tooltip = "Show a notification when a group member dies",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.deathAlert.enable end,
                    setFunc = function(value) KyzderpsDerps.savedOptions.deathAlert.enable = value end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Unlock",
                    tooltip = "Show the frame for repositioning",
                    default = false,
                    getFunc = function() return KyzderpsDerps.savedOptions.deathAlert.unlock end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.deathAlert.unlock = value
                        DeathAlertContainer:SetMouseEnabled(value)
                        DeathAlertContainerBackdrop:SetHidden(not value)
                        DeathAlertContainerSkull:SetHidden(not value)
                    end,
                    width = "full",
                    disabled = function() return not KyzderpsDerps.savedOptions.deathAlert.enable end,
                },
                {
                    type = "slider",
                    name = "Text Size",
                    tooltip = "Size of the death alert text",
                    min = 10,
                    max = 64,
                    step = 2,
                    default = 30,
                    width = full,
                    getFunc = function() return KyzderpsDerps.savedOptions.deathAlert.size end,
                    setFunc = function(value)
                        KyzderpsDerps.savedOptions.deathAlert.size = value
                        DeathAlert.changeFontSize()
                    end,
                    disabled = function() return not KyzderpsDerps.savedOptions.deathAlert.enable end,
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Quickslots",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "You can set keybinds in your controls settings to select a quickslot with one key - though you still need to press your Quickslot Item key to use the item!",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Enable Indicator",
                    tooltip = "Show 3 small icons above the default quickslot to indicate which one is selected",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.quickSlots.enable end,
                    setFunc = function(value)
                            KyzderpsDerps.savedOptions.quickSlots.enable = value
                            KDDQuickSlot:SetHidden(not value)
                        end,
                    width = "full",
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Companion",
            controls = {
                {
                    type = "description",
                    title = nil,
                    text = "You can toggle Bastian and Mirri with the |c99FF99/bastian|r and |c99FF99/mirri|r commands respectively.",
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Re-summon companion",
                    tooltip = "Re-summons your previously active companion after you put away your assistant",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.companion.resummon end,
                    setFunc = function(value)
                            KyzderpsDerps.savedOptions.companion.resummon = value
                        end,
                    width = "full",
                },
                {
                    type = "checkbox",
                    name = "Display rapport changes",
                    tooltip = "Shows a message in chat when your companion's rapport changes",
                    default = true,
                    getFunc = function() return KyzderpsDerps.savedOptions.companion.showRapport end,
                    setFunc = function(value)
                            KyzderpsDerps.savedOptions.companion.showRapport = value
                        end,
                    width = "full",
                },
            }
        },
        -------------------------------------------------------------------------------
        {
            type = "submenu",
            name = "Miscellaneous",
            controls = {
                {
                    type = "dropdown",
                    name = "Use collectible on login",
                    tooltip = "Specify a collectible to use when you first load into a character",
                    choices = collectibleNames,
                    choicesValues = collectibleIds,
                    getFunc = function() return KyzderpsDerps.savedOptions.misc.loginCollectible end,
                    setFunc = function(id)
                            KyzderpsDerps:dbg("selected " .. tostring(id))
                            KyzderpsDerps.savedOptions.misc.loginCollectible = id
                        end,
                    width = "full",
                },
            }
        },
    }

    KyzderpsDerps.addonPanel = LAM:RegisterAddonPanel("KyzderpsDerpsOptions", panelData)
    LAM:RegisterOptionControls("KyzderpsDerpsOptions", optionsData)

    CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", DeathAlert.hideAll)
end


