KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Hodor = KyzderpsDerps.Hodor or {}
local Hodor = KyzderpsDerps.Hodor


---------------------------------------------------------------------
-- Update player data to get them off the horn list
---------------------------------------------------------------------
local function Unhorn(atName)
    if (not atName or atName == "") then
        KyzderpsDerps:msg("Usage: /unhorn <@name>")
        return
    end

    for i = 1, GetGroupSize() do
        local unitTag = "group" .. tostring(i)
        if (GetUnitDisplayName(unitTag) == atName) then
            HodorReflexes.modules.share.UpdatePlayerData(unitTag, 0, 1, 0, 0, 0)
            KyzderpsDerps:msg("Updating player data for " .. unitTag .. " to maybe reset horn")
            return
        end
    end

    KyzderpsDerps:msg("Couldn't find player " .. atName .. " in group!")
end


---------------------------------------------------------------------
-- When horn updates, also add/update icon for horn in range
---------------------------------------------------------------------
local function UpdateInRange()
    for atName, data in pairs(HodorReflexes.modules.share.playersData) do
        if (data.ultRow) then
            local name = string.gsub(atName, "^@", "")
            local texture = WINDOW_MANAGER:GetControlByName("KDDHodor" .. name)
            local label = WINDOW_MANAGER:GetControlByName("KDDHodor" .. name .. "Label")
            if (not texture) then
                texture = WINDOW_MANAGER:CreateControl("KDDHodor" .. name, data.ultRow, CT_TEXTURE)
                texture:SetDimensions(18, 18)
                texture:SetAnchor(RIGHT, data.ultRow, LEFT, -4)
                texture:SetTexture("esoui/art/unitattributevisualizer/attributebar_arrow.dds")
                texture:SetDrawTier(2)

                local outline = WINDOW_MANAGER:CreateControl("KDDHodor" .. name .. "Outline", texture, CT_TEXTURE)
                outline:SetTexture("esoui/art/unitattributevisualizer/attributebar_arrow.dds")
                outline:SetColor(0, 0, 0)
                outline:SetDimensions(18, 18)
                outline:SetAnchor(TOPLEFT, texture, TOPLEFT, 3, 3)
                outline:SetDrawTier(1)

                label = WINDOW_MANAGER:CreateControl("KDDHodor" .. name .. "Label", texture, CT_LABEL)
                label:SetFont("ZoFontGameSmall")
                label:SetColor(0.6, 0.6, 0.6)
                label:SetAnchor(RIGHT, texture, LEFT, -4)
            end
            texture:SetParent(data.ultRow)
            texture:SetAnchor(RIGHT, data.ultRow, LEFT, -4)

            if ((data.ult and data.ult >= 90) -- Old Hodor, probably incorrect too
                or (data.ult1ID == 40223 and data.ultValue / data.ult1Cost >= 0.9)
                or (data.ult2ID == 40223 and data.ultValue / data.ult2Cost >= 0.9)) then
                if (IsUnitInGroupSupportRange(data.tag)) then
                    local distance = HodorReflexes.player.GetDistanceToPlayerM(data.tag)
                    if (distance) then
                        label:SetText(string.format("%.1fm", distance))
                    else
                        distance = 30
                    end

                    local red = 0
                    local green = 1
                    if (distance >= 20) then
                        red = 1
                        green = 0.3
                    elseif (distance >= 16) then
                        red = 1
                        green = 1
                    end
                    texture:SetColor(red, green, 0)
                    texture:SetHidden(false)
                    label:SetHidden(not KyzderpsDerps.savedOptions.hodor.hornLabel)
                else
                    texture:SetHidden(true)
                end
            else
                -- If ult isn't ready or close to ready, just hide it
                texture:SetHidden(true)
            end
        end
    end
end


---------------------------------------------------------------------
-- Initialize
---------------------------------------------------------------------
local origFunction

function Hodor.Initialize()
    if (not HodorReflexes) then return end
    SLASH_COMMANDS["/unhorn"] = Unhorn

    if (not KyzderpsDerps.savedOptions.hodor.horn) then return end

    KyzderpsDerps:dbg("    Initializing Hodor integration...")

    if (origFunction ~= nil) then return end

    origFunction = HodorReflexes.modules.share.RefreshControls
    HodorReflexes.modules.share.RefreshControls = function(...)
            UpdateInRange()
            origFunction(...)
        end

    -- If it's aligned to the right of the screen it gets pushed to the left, annoying
    HodorReflexes_Share_Ultimates:SetClampedToScreen(false)
end

function Hodor.Uninitialize()
    if (not HodorReflexes) then return end

    -- Note: the function restoration only takes effect after Hodor restarts polling (like after leaving group?)
    if (origFunction ~= nil) then
        HodorReflexes.modules.share.RefreshControls = origFunction
        origFunction = nil
    end
    HodorReflexes_Share_Ultimates:SetClampedToScreen(true)

    KyzderpsDerps:dbg("    Removed Hodor integration...")
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function Hodor.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Enable horn distance icon",
            tooltip = "When enabled, a colored icon will show next to the horn list if the player almost has horn ready and is within support range. The icon shows green, yellow, or orange depending on distance to yourself. Useful for raid leads especially in vCR with tank gone in portal",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.hodor.horn end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.hodor.horn = value

                Hodor.Uninitialize()
                Hodor.Initialize()
            end,
            width = "full",
        },
        {
            type = "checkbox",
            name = "Enable horn distance label",
            tooltip = "Additionally shows the horn player's distance in meters to yourself",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.hodor.hornLabel end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.hodor.hornLabel = value
            end,
            width = "full",
            disabled = function()
                return not KyzderpsDerps.savedOptions.hodor.horn
            end,
        },
    }
end
