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
-- Auto equip/unequip tabard
---------------------------------------------------------------------------------------------------
local prevCostumeId = 0

local function OnCollectibleUpdated(_, collectibleId)
    if (GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_COSTUME) then
        return
    end
    local currCostumeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)

    if (prevCostumeId ~= currCostumeId) then
        prevCostumeId = currCostumeId

        if (not KyzderpsDerps.savedOptions.fashion.autoTabard) then return end

        if (currCostumeId == 0) then
            -- Unequip tabard
            if (not GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME)) then return end
            local link = GetItemLink(BAG_WORN, EQUIP_SLOT_COSTUME, LINK_STYLE_BRACKETS)
            if (GetNumBagFreeSlots(BAG_BACKPACK) == 0) then
                KyzderpsDerps:msg(string.format("Could not unequip %s because you have no space in your backpack.", link))
            else
                KyzderpsDerps:msg(string.format("Unequipping %s. WTB invisible tabards ZOS pls.", link))
                RequestUnequipItem(BAG_WORN, EQUIP_SLOT_COSTUME)
            end
        else
            -- Find and equip tabard
            if (GetItemInstanceId(BAG_WORN, EQUIP_SLOT_COSTUME)) then return end
            local bagCache = SHARED_INVENTORY:GetOrCreateBagCache(BAG_BACKPACK)
            for _, item in pairs(bagCache) do
                if (GetItemEquipType(item.bagId, item.slotIndex) == EQUIP_TYPE_COSTUME) then
                    local itemLink = GetItemLink(item.bagId, item.slotIndex, LINK_STYLE_BRACKETS)
                    local itemType, specializedType = GetItemLinkItemType(itemLink)
                    if (itemType == ITEMTYPE_TABARD and specializedType == SPECIALIZED_ITEMTYPE_TABARD) then
                        KyzderpsDerps:msg(string.format("Equipping %s for the nameplate!", itemLink))
                        RequestEquipItem(BAG_BACKPACK, item.slotIndex, BAG_WORN, EQUIP_SLOT_COSTUME)
                        return
                    end
                end
            end
            KyzderpsDerps:msg("No tabard to equip.")
        end
    end
end

---------------------------------------------------------------------------------------------------
-- Entry
function KyzderpsDerps.InitializeFashion()
    KyzderpsDerps:dbg("    Initializing Fashion module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionArmoryRestore", EVENT_ARMORY_BUILD_RESTORE_RESPONSE, OnBuildLoaded)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "FashionCostumeUpdate", EVENT_COLLECTIBLE_UPDATED, OnCollectibleUpdated)

    isVampire = (GetPlayerCurseType() == CURSE_TYPE_VAMPIRE)

    prevCostumeId = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_COSTUME)
end
