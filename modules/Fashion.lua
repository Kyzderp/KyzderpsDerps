KyzderpsDerps = KyzderpsDerps or {}

---------------------------------------------------------------------------------------------------
local curseTypes = {
    [CURSE_TYPE_NONE] = "CURSE_TYPE_NONE",
    [CURSE_TYPE_VAMPIRE] = "CURSE_TYPE_VAMPIRE",
    [CURSE_TYPE_WEREWOLF] = "CURSE_TYPE_WEREWOLF",
}

local isVampire = false

---------------------------------------------------------------------------------------------------
local function EquipVampSkin()
    local currentId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)

    -- Only equip a skin if there is no skin active
    if (currentId ~= 0) then return end

    KyzderpsDerps:msg(string.format("Equipping |H1:collectible:%d|h|h to cover up your pale skin", KyzderpsDerps.savedOptions.fashion.vampSkinId)) -- 5108
    UseCollectible(KyzderpsDerps.savedOptions.fashion.vampSkinId)
end

local function RestoreNonVampSkin()
    local currentId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_SKIN)
    if (currentId ~= 0) then
        -- No skin
        KyzderpsDerps:msg(string.format("Restoring to no skin because you are no longer a vampire"))
        UseCollectible(currentId)
    end
end

---------------------------------------------------------------------------------------------------
-- * EVENT_ARMORY_BUILD_RESTORE_RESPONSE (*[ArmoryBuildRestoreResult|#ArmoryBuildRestoreResult]* _result_, *luaindex* _buildIndex_)
local function OnBuildLoaded(_, result)
    if (result ~= ARMORY_BUILD_RESTORE_RESULT_SUCCESS) then return end

    local curseType = GetPlayerCurseType()

    if (not isVampire and curseType == CURSE_TYPE_VAMPIRE) then
        -- Turning into a vampire
        isVampire = true
        if (KyzderpsDerps.savedOptions.fashion.equipSkinForVamp) then
            EquipVampSkin()
        end
    elseif (isVampire and curseType ~= CURSE_TYPE_VAMPIRE) then
        -- No longer a vampire
        isVampire = false
        if (KyzderpsDerps.savedOptions.fashion.equipSkinForVamp and KyzderpsDerps.savedOptions.fashion.restoreAfterVamp) then
            RestoreNonVampSkin()
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Entry
function KyzderpsDerps.InitializeFashion()
    KyzderpsDerps:dbg("    Initializing Fashion module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionArmoryRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, OnBuildLoaded)

    isVampire = (GetPlayerCurseType() == CURSE_TYPE_VAMPIRE)
end
