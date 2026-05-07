local KD = KyzderpsDerps
local WI = KD.WorldIcons


---------------------------------------------------------------------
---------------------------------------------------------------------
local function StartsWith(str, prefix)
    return string.sub(str, 1, #prefix) == prefix
end

-- TODO: companion doesn't work. use companion activated and deactivated
local function GetIconTexture(unitTag)
    if (StartsWith(unitTag, "playerpet")) then
        return "CrutchAlerts/assets/poop.dds"
    end
    if (unitTag == "companion") then
        return "esoui/art/mappins/activecompanion_pin.dds"
    end
end


---------------------------------------------------------------------
---------------------------------------------------------------------
local UNIT_ICON_UNIQUE_NAME = "KyzderpsDerpsUnitIcon"

local function OnUnitCreated(_, unitTag)
    local texture = GetIconTexture(unitTag)
    if (texture) then
        CrutchAlerts.SetAttachedIconForUnit(unitTag, UNIT_ICON_UNIQUE_NAME, 50, texture, nil, nil, true)
    end
end

local function OnUnitDestroyed(_, unitTag)
    CrutchAlerts.RemoveAttachedIconForUnit(unitTag, UNIT_ICON_UNIQUE_NAME)
end


---------------------------------------------------------------------
---------------------------------------------------------------------
function WI.InitializeUnitIcons()
    if (not KD.savedOptions.general.experimental) then return end
    if (not CrutchAlerts or not CrutchAlerts.SetAttachedIconForUnit) then
        return
    end

    EVENT_MANAGER:RegisterForEvent(WI.name .. "UnitCreated", EVENT_UNIT_CREATED, OnUnitCreated)
    EVENT_MANAGER:RegisterForEvent(WI.name .. "UnitDestroyed", EVENT_UNIT_DESTROYED, OnUnitDestroyed)
end
