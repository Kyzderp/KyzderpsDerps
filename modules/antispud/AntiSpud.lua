KyzderpsDerps = KyzderpsDerps or {}

KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

--[[
summon pets after dying
resummon pets on zhajhassa
addons not enabled
wrong cp
missing gear
incomplete sets
]]

local currentState = "NONE"

function Spud.DisplayWarning(message)
    -- TODO: other methods of warnings like popup dialogs
    local chatWarning = "|cFF0000W" ..
                        "|cFF7F00A" ..
                        "|cFFFF00R" ..
                        "|c00FF00N" ..
                        "|c0000FFI" ..
                        "|c2E2B5FN" ..
                        "|c8B00FFG" ..
                        "|r: " .. message
    KyzderpsDerps:dbg(chatWarning)
end

---------------------------------------------------------------------
-- Entry
function Spud.Initialize()
    KyzderpsDerps:dbg("    Initializing AntiSpud module...")

    Spud.InitializeSpaulder()
    Spud.InitializeMundus()
    Spud.InitializeFood()
    Spud.InitializeTorte()
    Spud.InitializeLog()

    if (KyzderpsDerps.savedOptions.antispud.equipped.enable) then
        Spud.InitializeEquipped()
    end

    -- Needs to go last in case others register listeners
    Spud.InitializeState()
end
