KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
Spud.MUNDUS = "Mundus"
Spud.MISSING = "Missing gear"
Spud.FRONTBAR = "Frontbar gear"
Spud.BACKBAR = "Backbar gear"
Spud.FOOD = "Buff food"
Spud.SPAULDER = "Spaulder"
Spud.TORTE = "Torte"
Spud.LOG = "Logging"

local priorities = {Spud.MUNDUS, Spud.MISSING, Spud.FRONTBAR, Spud.BACKBAR, Spud.FOOD, Spud.SPAULDER, Spud.TORTE, Spud.LOG}

--[[
displaying = {
    [MUNDUS] = "You are using the Lover mundus",
    [MISSING] = "You are nekkid",
    [FRONTBAR] = "You are wearing 6 pieces of Bahsei's Mania on frontbar",
    [BACKBAR] = "You are wearing 2 pieces of Advancing Yokeda on backbar",
    [FOOD] = "You have no buff food",
    [SPAULDER] = "Spudler is OFF",
    [TORTE] = "You don't have torte buff on",
    [LOG] = "You are not logging",
}
]]
local displaying = {}

---------------------------------------------------------------------
-- Snooze the currently displaying for 1 hour
local snoozed = {} -- {[MUNDUS] = 19328139}

local function IsSnoozed(priority)
    if (not snoozed[priority]) then return false end
    return snoozed[priority] > GetGameTimeSeconds()
end

local function UpdateSnoozed()
    for priority, targetTime in pairs(snoozed) do
        if (targetTime <= GetGameTimeSeconds()) then
            snoozed[priority] = nil
            KyzderpsDerps:msg(string.format("\"%s\" is done sleeping.", priority))
        end
    end
    Spud.UpdateDisplay()
end

function Spud.SnoozeCurrent()
    -- First find which is displaying
    local current
    for _, priority in ipairs(priorities) do
        if (displaying[priority] and not IsSnoozed(priority)) then
            current = priority
            break
        end
    end

    -- Save target time, update current display, and also call update later
    snoozed[current] = GetGameTimeSeconds() + 3600
    Spud.UpdateDisplay()
    EVENT_MANAGER:RegisterForUpdate("KyzderpsAntiSpudSnooze" .. current, 3600000, function()
        EVENT_MANAGER:UnregisterForUpdate("KyzderpsAntiSpudSnooze" .. current)
        UpdateSnoozed()
    end)
    KyzderpsDerps:msg(string.format("Snoozing \"%s\" for 1 hour. Reloading UI or logging out will un-snooze.", current))
end

---------------------------------------------------------------------
local function UpdateDisplay()
    for _, priority in ipairs(priorities) do
        if (displaying[priority] and not IsSnoozed(priority)) then
            -- Found priority message to display
            AntiSpudEquippedLabel:SetText(displaying[priority])
            AntiSpudEquipped:SetWidth(1000)
            AntiSpudEquipped:SetWidth(AntiSpudEquippedLabel:GetTextWidth())
            AntiSpudEquipped:SetHidden(false)
            return
        end
    end

    -- Otherwise clear it
    AntiSpudEquipped:SetHidden(true)
end
Spud.UpdateDisplay = UpdateDisplay

local function Display(text, priority)
    displaying[priority] = text
    UpdateDisplay()
end
Spud.Display = Display
