KDD_AntiSpud = KDD_AntiSpud or {}
local Spud = KDD_AntiSpud

local enabledBTG = {}
local disabledBTG = {}

local function SetBTG(btgIndex, enable)
    btg.savedVars.trackedBuffs[btgIndex] = enable
    if (enable) then
        table.insert(enabledBTG, btgData.buffs[btgIndex])
    else
        table.insert(disabledBTG, btgData.buffs[btgIndex])
    end
    return enable
end

local function AreSkillsSlotted()
    local combatPrayer = false
    local empoweringGrasp = false
    local expansiveFrostCloak = false
    -- /script for i=3,8 do local id = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY) d(tostring(id) .. " " .. GetAbilityName(id)) end
    for i = 3, 8 do
        local id = GetSlotBoundId(i, HOTBAR_CATEGORY_PRIMARY)
        if (id == 118352) then
            empoweringGrasp = true
        elseif (id == 40094) then
            combatPrayer = true
        elseif (id == 86126) then
            expansiveFrostCloak = true
        end
    end
    for i = 3, 8 do
        local id = GetSlotBoundId(i, HOTBAR_CATEGORY_BACKUP)
        if (id == 118352) then
            empoweringGrasp = true
        elseif (id == 40094) then
            combatPrayer = true
        elseif (id == 86126) then
            expansiveFrostCloak = true
        end
    end

    return combatPrayer, empoweringGrasp, expansiveFrostCloak
end

local function UpdateBuffTheGroup(equippedSets)
    if (btg == nil) then return end

    local hasEnabled = false
    enabledBTG = {}
    disabledBTG = {}

    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.pa) then
        hasEnabled = hasEnabled or SetBTG(1, equippedSets["Powerful Assault"] ~= nil)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorSlayer) then
        SetBTG(2, equippedSets["Roaring Opportunist"] ~= nil or equippedSets["Master Architect"] ~= nil or equippedSets["War Machine"] ~= nil)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorCourage) then
        SetBTG(3, equippedSets["Vestment of Olorime"] ~= nil or equippedSets["Spell Power Cure"] ~= nil)
    end

    local combatPrayer, empoweringGrasp, expansiveFrostCloak = AreSkillsSlotted()

    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.minorBerserk) then
        hasEnabled = hasEnabled or SetBTG(6, combatPrayer)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.majorResolve) then
        hasEnabled = hasEnabled or SetBTG(12, expansiveFrostCloak)
    end
    if (KyzderpsDerps.savedOptions.antispud.equipped.buffTheGroup.empower) then
        hasEnabled = hasEnabled or SetBTG(15, empoweringGrasp)
    end

    -- If nothing but slayer and courage are enabled, I (personally) want to see major slayer
    if (not hasEnabled and KyzderpsDerps.savedOptions.general.experimental) then
        SetBTG(2, true)
    end

    KyzderpsDerps:dbg("Enabled in BuffTheGroup: " .. table.concat(enabledBTG, ", "))
    KyzderpsDerps:dbg("Disabled in BuffTheGroup: " .. table.concat(disabledBTG, ", "))

    btg.CheckActivation()
end
Spud.UpdateBuffTheGroup = UpdateBuffTheGroup