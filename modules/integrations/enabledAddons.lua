KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Integrations = KyzderpsDerps.Integrations or {}
local Integrations = KyzderpsDerps.Integrations
Integrations.name = KyzderpsDerps.name .. "Integrations"

---------------------------------------------------------------------
-- RAAAAAINBOW
---------------------------------------------------------------------
local function DisplayWarning(msg)
    local chatWarning = "|cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|cFF00FF: " .. msg .. "|r"
    CHAT_SYSTEM:AddMessage(chatWarning)
end

---------------------------------------------------------------------
-- Check specific zones
---------------------------------------------------------------------
local function OnPlayerActivated()
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))

    -- Blackrose Prison (1082)
    if (zoneId == 1082 and not BRHelper and KyzderpsDerps.savedOptions.integrations.checkBRHelper) then
        DisplayWarning("BRHelper is not enabled!")
    end

    -- Asylum Sanctorium (1000)
    if (zoneId == 1000 and not AsylumNotifier and KyzderpsDerps.savedOptions.integrations.checkAsylumStatusPanel) then
        DisplayWarning("Asylum Sanctorium Status Panel is not enabled!")
    end
    if (zoneId == 1000 and not AsylumTracker and KyzderpsDerps.savedOptions.integrations.checkAsylumTracker) then
        DisplayWarning("Asylum Tracker is not enabled!")
    end
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Integrations.Initialize()
    EVENT_MANAGER:RegisterForEvent(Integrations.name .. "Activated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end