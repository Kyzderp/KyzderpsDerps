KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.Fashion = KyzderpsDerps.Fashion or {}
local Fashion = KyzderpsDerps.Fashion
local Spud = KyzderpsDerps.AntiSpud

---------------------------------------------------------------------
-- Helper for whether mounting is allowed
-- This is to be used to avoid stick horses in mountable content
---------------------------------------------------------------------
local function IsMountingAllowed()
    -- TODO: HRC

    if (IsUnitInDungeon("player")) then
        return false
    end

    if (IsActiveWorldBattleground()) then
        return false
    end

    if (GetUnitBattlegroundAlliance("player") ~= nil and GetUnitBattlegroundAlliance("player") ~= 0) then
        return false
    end

    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (zoneId == 912) then -- Imperial City proper. Could prob just reverse this...
        return true 
    end

    if (IsInImperialCity()) then
        return false
    end

    return true
end


---------------------------------------------------------------------
-- Saving and activating mount
---------------------------------------------------------------------
local mountTries = 0
local function TryEquipMount(collectibleToUse)
    KyzderpsDerps:dbg(string.format("Trying to equip |H1:collectible:%d|h|h", collectibleToUse))
    if (IsUnitInCombat("player")) then
        KyzderpsDerps:dbg("Not changing mount because in combat")
        return
    end

    UseCollectible(collectibleToUse)

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "AwaitMountCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT, function(_, result)
        EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "AwaitMountCollectibleResult" .. tostring(collectibleToUse), EVENT_COLLECTIBLE_USE_RESULT)
        if (result == COLLECTIBLE_USAGE_BLOCK_REASON_ON_COOLDOWN) then
            if (mountTries > 5) then
                KyzderpsDerps:msg("Couldn't equip trample mount after several retries; collectibles on cooldown?")
                return
            end
            mountTries = mountTries + 1
            zo_callLater(function() TryEquipMount(collectibleToUse) end, 2000)
        elseif (result == COLLECTIBLE_USAGE_BLOCK_REASON_NOT_BLOCKED) then
            KyzderpsDerps:msg(string.format("Equipped |H1:collectible:%d|h|h. Happy trampling!", collectibleToUse))
        end
    end)
end

local function ActivateMount(collectibleId)
    if (IsCollectibleActive(collectibleId)) then
        KyzderpsDerps:dbg("Not changing mount; it's already correct")
        return
    end

    mountTries = 0
    TryEquipMount(collectibleId)
end

-- Save the current mount to restore later. This is NOT always called
-- before changing mount, because it's possible to go, e.g., from PvE
-- to PvP, so the PvE mount should not be saved, but only if the PvE
-- setting is on
local function SaveMount()
    KyzderpsDerps:dbg("Saving mount...")
    KyzderpsDerps.savedOptions.fashion.oldMount = GetActiveCollectibleByType(COLLECTIBLE_CATEGORY_TYPE_MOUNT)
end

-- 1 ~ num
local function GetRandomNumber(num)
    return math.floor(math.random() * num + 1)
end

local function RandomizeMount()
    KyzderpsDerps:dbg("Randomizing mount...")

    local trampleMounts = KyzderpsDerps.savedOptions.fashion.trampleMounts

    -- Filter out stick mounts if applicable
    if (KyzderpsDerps.savedOptions.fashion.excludeStickMountsInMountable and IsMountingAllowed()) then
        local stickMounts = {
            5870, -- Novelty Stick Horse
            5879, -- Novelty Stick Guar
            5880, -- Novelty Stick Dragon
            7291, -- Nightmare Stick Horse
            9829, -- Stitchedwell Stick Guar
        }
        local newMounts = {}
        for _, id in ipairs(trampleMounts) do
            if (not stickMounts[id]) then
                table.insert(newMounts, id)
            end
        end
        trampleMounts = newMounts
    end

    -- Could be left with none
    if (#trampleMounts == 0) then
        KyzderpsDerps:msg("No valid mounts set for trampling purposes! Add some in the settings.")
        return
    end

    -- Too lazy to make it random but different... for now
    local newIndex = GetRandomNumber(#trampleMounts)
    ActivateMount(trampleMounts[newIndex])
end

local function RestoreMount()
    local oldMount = KyzderpsDerps.savedOptions.fashion.oldMount
    KyzderpsDerps:msg("Restoring mount to " .. GetCollectibleName(oldMount))
    ActivateMount(oldMount)
end


---------------------------------------------------------------------
-- State change checks
---------------------------------------------------------------------
local function IsStateTrample(state)
    local usePve = KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount
    local usePvp = KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount

    if (usePve and state == Spud.PVE) then
        return true
    elseif (usePvp and state == Spud.PVP) then
        return true
    end
    return false
end

local prevZoneId = 0
local prevState
local function OnPlayerActivated()
    -- Only continue if zone is different. That means not re-randomizing if queueing
    -- into the same dungeon, but whatevs
    local zoneId = GetZoneId(GetUnitZoneIndex("player"))
    if (prevZoneId == zoneId) then
        return
    end
    prevZoneId = zoneId

    -- Get current state
    local checkedState
    if (Spud.IsDoingGroupPVE(zoneId)) then
        checkedState = Spud.PVE
    elseif (Spud.IsDoingPVP()) then
        checkedState = Spud.PVP
    else
        checkedState = Spud.NONE
    end

    -- Don't do anything on first load
    if (not prevState) then
        prevState = checkedState
        return
    end
    
    local isPrevStateTrample = IsStateTrample(prevState)
    local isNewStateTrample = IsStateTrample(checkedState)

    -- If restoring, don't do anything else
    if (isPrevStateTrample and not isNewStateTrample) then
        RestoreMount()
        return
    end

    -- Basically whether to save (see comment for SaveMount())
    -- It's fine to save a bit excessively, even if we aren't changing mounts
    if (not isPrevStateTrample) then
        SaveMount()
    end

    -- Even if the state is the same, it could be different content, so still randomize
    if (isNewStateTrample) then
        RandomizeMount()
    end
end


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
function Fashion.InitializeTrampleMount()
    if (KyzderpsDerps.savedOptions.fashion.pveUseTrampleMount
        or KyzderpsDerps.savedOptions.fashion.pvpUseTrampleMount) then
        -- We should only change the mount if going from non-trample content to trample content
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "TrampleActivated", EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
    end
end

local function UninitializeTrampleMount()
    EVENT_MANAGER:UnregisterForEvent(KyzderpsDerps.name .. "TrampleActivated", EVENT_PLAYER_ACTIVATED)
end
