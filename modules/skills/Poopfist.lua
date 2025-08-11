KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Poopfist = KyzderpsDerps.Poopfist or {}

-- Poopfist initial cast time stomp 31816, pooflinging 133027
local POOPSTOMP_ID = 31816
local POOPSTOMP_PATH = "KyzderpsDerps/modules/skills/poopstomp.dds"
function KyzderpsDerps.Poopfist.Initialize()
    -- Too lazy to make this dynamic, will just force a reload
    if (not KyzderpsDerps.savedOptions.skills.poopstomp) then return end

    -- Hook base game action bar
    local origGetSlotTexture = GetSlotTexture
    GetSlotTexture = function(actionSlotIndex, hotbarCategory)
        local abilityId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
        if abilityId == POOPSTOMP_ID then
            return POOPSTOMP_PATH
        end
        return origGetSlotTexture(actionSlotIndex, hotbarCategory)
    end

    -- Hook addons or whatever
    local origGetAbilityIcon = GetAbilityIcon
    GetAbilityIcon = function(abilityId)
        if (abilityId == POOPSTOMP_ID) then
            return POOPSTOMP_PATH
        end
        return origGetAbilityIcon(abilityId)
    end

    -- If the poops expire while on the other bar, FAB doesn't update
    if (FancyActionBar and FancyActionBar.GetActionButton) then
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "PoopfistHotbar", EVENT_HOTBAR_SLOT_UPDATED, function(_, actionSlotIndex, hotbarCategory)
            if (hotbarCategory == GetActiveHotbarCategory()) then
                return
            end

            local abilityId = GetSlotBoundId(actionSlotIndex, hotbarCategory)
            if (GetSlotBoundId(actionSlotIndex, hotbarCategory) ~= POOPSTOMP_ID) then
                return
            end

            -- This is a bit hacky, but FAB doesn't expose any functions for refreshing the icon
            -- 20 offset gets the inactive bar's slot
            local button = FancyActionBar.GetActionButton(actionSlotIndex + 20)
            if (button) then
                button.icon:SetTexture(POOPSTOMP_PATH)
            end
        end)
    end
end


function KyzderpsDerps.Poopfist.GetSettings()
    return {
        {
            type = "checkbox",
            name = "Show Poopstomp",
            tooltip = "Shows a different icon for Stone Giant when it's the initial rock-summoning cast time ability",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.skills.poopstomp end,
            setFunc = function(value)
                    KyzderpsDerps.savedOptions.skills.poopstomp = value
                end,
            width = "full",
            requiresReload = true,
        },
    }
end


