KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
local function CheckLog()
    if (KyzderpsDerps.savedOptions.antispud.log
        and Spud.GetCurrentState() == Spud.PVE
        and not IsEncounterLogEnabled()) then
        Spud.Display("You are not logging", Spud.LOG)
    else
        Spud.Display(nil, Spud.LOG)
    end
end
Spud.CheckLog = CheckLog

local function OnSpudStateChanged(oldState, newState)
    CheckLog()
end

---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Spud.InitializeLog()
    KyzderpsDerps:dbg("    Initializing AntiSpud Log...")

    Spud.RegisterStateListener("Log", OnSpudStateChanged)

    CheckLog()

    ZO_PreHook("SetEncounterLogEnabled", function() zo_callLater(CheckLog, 100) end)
end
