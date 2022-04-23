KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.AntiSpud = KyzderpsDerps.AntiSpud or {}
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
Spud.MUNDUS = 1
Spud.MISSING = 2
Spud.FRONTBAR = 3
Spud.BACKBAR = 4
Spud.FOOD = 5
Spud.SPAULDER = 6
Spud.LOG = 7

local priorities = {Spud.MUNDUS, Spud.MISSING, Spud.FRONTBAR, Spud.BACKBAR, Spud.FOOD, Spud.SPAULDER, Spud.LOG}

--[[
displaying = {
    [MUNDUS] = "You are using the Lover mundus",
    [MISSING] = "You are nekkid",
    [FRONTBAR] = "You are wearing 6 pieces of Bahsei's Mania on frontbar",
    [BACKBAR] = "You are wearing 2 pieces of Advancing Yokeda on backbar",
    [FOOD] = "You have no buff food",
    [SPAULDER] = "Spudler is OFF",
    [LOG] = "You are not logging",
}
]]
local displaying = {}

---------------------------------------------------------------------
local function UpdateDisplay()
    for _, priority in ipairs(priorities) do
        if (displaying[priority]) then
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

local function Display(text, priority)
    displaying[priority] = text
    UpdateDisplay()
end
Spud.Display = Display
