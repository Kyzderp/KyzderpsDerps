KyzderpsDerps = KyzderpsDerps or {}

local initialized = false

---------------------------------------------------------------------
-- /script for i=1, GetGroupSize() do d(tostring(i) .. GetUnitDisplayName("group" .. tostring(i))) end
-- /script HodorReflexes.modules.share.UpdatePlayerData("group3", 0, 1, 0, 0, 0)
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
                outline:SetAnchor(TOPEFT, texture, TOPLEFT, 3, 3)
                outline:SetDrawTier(1)

                label = WINDOW_MANAGER:CreateControl("KDDHodor" .. name .. "Label", texture, CT_LABEL)
                label:SetFont("ZoFontGameSmall")
                label:SetColor(0.6, 0.6, 0.6)
                label:SetAnchor(RIGHT, texture, LEFT, -4)
            end
            texture:SetParent(data.ultRow)
            texture:SetAnchor(RIGHT, data.ultRow, LEFT, -4)

            if (data.ult >= 90) then
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
function KyzderpsDerps.InitializeHodor()
    if (not HodorReflexes) then return end
    SLASH_COMMANDS["/unhorn"] = Unhorn

    if (not KyzderpsDerps.savedOptions.hodor.horn) then return end

    KyzderpsDerps:dbg("    Initializing Hodor integration...")

    if (initialized) then return end


    initialized = true
    local origFunction = HodorReflexes.modules.share.RefreshControls
    HodorReflexes.modules.share.RefreshControls = function(...)
            UpdateInRange()
            origFunction(...)
        end

    -- If it's aligned to the right of the screen it gets pushed to the left, annoying
    HodorReflexes_Share_Ultimates:SetClampedToScreen(false)
end
