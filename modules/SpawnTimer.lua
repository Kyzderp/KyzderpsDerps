SpawnTimer = {
    -- Number of seconds after which bosses will be removed from the list
    TIMER_EXPIRY = 15 * 60,

    -- Dungeon zoneIds
    DUNGEON_ZONEIDS = {
        ["144" ] = true,  -- Spindleclutch I
        ["936" ] = true,  -- Spindleclutch II
        ["380" ] = true,  -- The Banished Cells I
        ["935" ] = true,  -- The Banished Cells II
        ["283" ] = true,  -- Fungal Grotto I
        ["934" ] = true,  -- Fungal Grotto II
        ["146" ] = true,  -- Wayrest Sewers I
        ["933" ] = true,  -- Wayrest Sewers II
        ["126" ] = true,  -- Elden Hollow I
        ["931" ] = true,  -- Elden Hollow II
        ["63"  ] = true,  -- Darkshade Caverns I
        ["930" ] = true,  -- Darkshade Caverns II
        ["130" ] = true,  -- Crypt of Hearts I
        ["932" ] = true,  -- Crypt of Hearts II
        ["176" ] = true,  -- City of Ash I
        ["681" ] = true,  -- City of Ash II (Inner Grove)
        ["148" ] = true,  -- Arx Corinium
        ["22"  ] = true,  -- Volenfell
        ["131" ] = true,  -- Tempest Island
        ["449" ] = true,  -- Direfrost Keep
        ["38"  ] = true,  -- Blackheart Haven
        ["31"  ] = true,  -- Selene's Web
        ["64"  ] = true,  -- Blessed Crucible
        ["11"  ] = true,  -- Vaults of Madness
        ["678" ] = true,  -- Imperial City Prison (Bastion)
        ["688" ] = true,  -- White-Gold Tower (Green Emperor Way)
        ["843" ] = true,  -- Ruins of Mazzatun
        ["848" ] = true,  -- Cradle of Shadows
        ["973" ] = true,  -- Bloodroot Forge
        ["974" ] = true,  -- Falkreath Hold
        ["1009"] = true,  -- Fang Lair
        ["1010"] = true,  -- Scalecaller Peak
        ["1052"] = true,  -- Moon Hunter Keep
        ["1055"] = true,  -- March of Sacrifices (Bloodscent Pass)
        ["1080"] = true,  -- Frostvault
        ["1081"] = true,  -- Depths of Malatar
        ["1122"] = true,  -- Moongrave Fane
        ["1123"] = true,  -- Lair of Maarselok
        ["1152"] = true,  -- Icereach
        ["1153"] = true,  -- Unhallowed Grave
        ["1197"] = true,  -- Stone Garden
        ["1201"] = true,  -- Castle Thorn
    },

    -- Trial zoneIds
    TRIAL_ZONEIDS = {
        ["635" ] = true,  -- Dragonstar Arena
        ["636" ] = true,  -- Hel Ra Citadel
        ["638" ] = true,  -- Aetherian Archive
        ["639" ] = true,  -- Sanctum Ophidia
        ["677" ] = true,  -- Maelstrom Arena
        ["725" ] = true,  -- Maw of Lorkhaj
        ["975" ] = true,  -- Halls of Fabrication
        ["1000"] = true,  -- Asylum Sanctorium
        ["1051"] = true,  -- Cloudrest
        ["1082"] = true,  -- Blackrose Prison
        ["1121"] = true,  -- Sunspire
        ["1196"] = true,  -- Kyne's Aegis
        ["1227"] = true,  -- Vateshran Hollows
    },

    BOSS_NAMES = {
        ["Curnard the Generous"] = true, -- Viridian Watch
        -- Malabal Tor Delves
        ["Arrai"] = true, -- Shael Ruins

    -- Stonefalls
        -- Crow's Wood Public Dungeon
        ["The Moonlit Maiden"] = 305, -- wispmother boss

        -- Western Skyrim
        -- WBs
        ["Shademother"] = 606,
        ["Tulnir"] = 301
    },
}

local running = false

-- Hide panel while in menus
function fragmentChange(oldState, newState)
    if (newState == SCENE_FRAGMENT_HIDDEN) then
        SpawnTimerContainer:SetHidden(true)
    elseif (newState == SCENE_FRAGMENT_SHOWN) then
        local index = 0
        for bossName, bossVals in pairs(KyzderpsDerps.savedValues.spawnTimer.timers) do
            index = index + 1
        end
        if (index > 0) then
            SpawnTimerContainer:SetHidden(not KyzderpsDerps.savedOptions.spawnTimer.enable)
        end
    end
end

-- Save boss list position
function SpawnTimer.SavePosition()
    KyzderpsDerps.savedValues.spawnTimer.x = SpawnTimerContainer:GetLeft()
    KyzderpsDerps.savedValues.spawnTimer.y = SpawnTimerContainer:GetTop()
end


---------------------------------------------------------------------------------------------------
local function IsBossByUnitTag(unitTag)
    if (string.find(unitTag, "^boss")) then
        local bossName = GetUnitName(unitTag)

        -- Skip trial or dungeon bosses
        if (GetCurrentParticipatingRaidId() ~= 0
            or SpawnTimer.DUNGEON_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))]
            or SpawnTimer.TRIAL_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))]) then
            KyzderpsDerps:dbg("Skipping " .. bossName .. " because it is a trial/dungeon boss.")
            return false
        end

        -- Skip bosses in the ignore list
        if (KyzderpsDerps.savedOptions.spawnTimer.ignoreList[bossName]) then
            KyzderpsDerps:dbg("Skipping " .. bossName .. " because it is in the ignore filter.")
            return false
        end

        return true
    elseif (unitTag == "reticleover") then
        local bossName = GetUnitName(unitTag)

        -- Try all deadly and hard mobs?
        local diff = GetUnitDifficulty(unitTag)
        if (diff ~= MONSTER_DIFFICULTY_DEADLY and diff ~= MONSTER_DIFFICULTY_HARD) then
            if (bossName == "Trove Scamp" or bossName == "Cunning Scamp") then
                SpawnTimer.BossKilled("Sewers Scamp")
                return false
            elseif (not SpawnTimer.BOSS_NAMES[bossName]) then
                return false
            end
        end

        -- Skip trial or dungeon bosses
        if (GetCurrentParticipatingRaidId() ~= 0
            or SpawnTimer.DUNGEON_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))]
            or SpawnTimer.TRIAL_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))]) then
            return false
        end

        -- Only care about "dungeons", this will be public dungeons and delves because group dungeons are skipped already
        if (not IsUnitInDungeon("player")) then
            return false
        end

        return true
    end

    return false
end


---------------------------------------------------------------------------------------------------
--  EVENT_UNIT_DEATH_STATE_CHANGED (number eventCode, string unitTag, boolean isDead)
local function OnDeathStateChanged(_, unitTag, isDead)
    if (not isDead) then
        return
    end

    if (IsBossByUnitTag(unitTag)) then
        SpawnTimer.BossKilled(GetUnitName(unitTag))
    end
end

-- This seems to filter to killing blows, but only shows the string information for your own killing blows
-- EVENT_COMBAT_EVENT (number eventCode, number ActionResult result, boolean isError, string abilityName, number abilityGraphic, number ActionSlotType abilityActionSlotType, string sourceName, number CombatUnitType sourceType, string targetName, number CombatUnitType targetType, number hitValue, number CombatMechanicType powerType, number DamageType damageType, boolean log, number sourceUnitId, number targetUnitId, number abilityId, number overflow)
local function OnCombatXP(_, _, _, abilityName, _, _, sourceName, _, targetName, _, _, _, _, _, sourceUnitId, targetUnitId, abilityId, _)
    -- KyzderpsDerps:dbg(string.format("%s(%d) killed %s(%d) with %s", sourceName, sourceUnitId, targetName, targetUnitId, abilityName))
    if (targetName == "Trove Scamp" or targetName == "Cunning Scamp") then
        SpawnTimer.BossKilled("Sewers Scamp")
    end
end

function SpawnTimer.BossKilled(bossName)
    KyzderpsDerps.savedValues.spawnTimer.timers[bossName] = { startTime = GetTimeStamp(), alerted = false, }
    if (not running) then
        KyzderpsDerps:dbg("Starting SpawnTimer polling")
        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "SpawnTimerTimer", 900, SpawnTimer.pollTimer)
        running = true
    end

    -- Display chat message if enabled
    if (KyzderpsDerps.savedOptions.spawnTimer.chat.enable) then
        local msg = "|cFFFFFF" .. bossName .. "|r died"
        if (KyzderpsDerps.savedOptions.spawnTimer.chat.timestamp) then
            msg = "[" .. GetTimeString() .. "] " .. msg
        end
        CHAT_SYSTEM:AddMessage(msg)
    end
end

-- EVENT_LOOT_RECEIVED (number eventCode, string receivedBy, string itemName, number quantity, ItemUISoundCategory soundCategory, LootItemType lootType, boolean self, boolean isPickpocketLoot, string questItemIcon, number itemId, boolean isStolen)
local function OnLootReceived(_, _, itemLink, _, _, lootType, isSelf)
    if (not isSelf) then return end
    if (lootType == LOOT_TYPE_ITEM) then
        local itemType = GetItemLinkItemType(itemLink)

        if (itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR) then
            if (GetItemLinkSetInfo(itemLink, false)) then
                -- This is a set item
                if (IsBossByUnitTag("reticleover")) then
                    local bossName = GetUnitName("reticleover")
                    local startTime
                    if (KyzderpsDerps.savedValues.spawnTimer.timers[bossName]) then
                        startTime = KyzderpsDerps.savedValues.spawnTimer.timers[bossName].startTime
                    end
                    if (not startTime or (GetTimeStamp() - startTime > 30)) then -- Only consider the loot reticle if it's not "new"
                        SpawnTimer.BossKilled(bossName)
                    end
                end
            end
        end
    end
end

-- Poll every 900ms to update the timer
function SpawnTimer.pollTimer()
    local index = 0
    -- Iterate through all bosses stored in the table
    for bossName, bossVals in pairs(KyzderpsDerps.savedValues.spawnTimer.timers) do
        index = index + 1
        local elapsed = (bossVals.startTime > 0) and GetTimeStamp() - bossVals.startTime or 0

        -- Remove timers that are > 15 mins
        if (elapsed >= SpawnTimer.TIMER_EXPIRY) then
            KyzderpsDerps.savedValues.spawnTimer.timers[bossName] = nil
            KyzderpsDerps:dbg("Removed " .. bossName .. " from respawn timers")
        else
            local respawnTime = 306 -- default of 5:06
            if (type(SpawnTimer.BOSS_NAMES[bossName]) == "number") then
                respawnTime = SpawnTimer.BOSS_NAMES[bossName]
            end

            local timerFormatted = string.format("%02d:%02d", zo_floor(elapsed / 60), elapsed % 60)
            local color = "00FF00" -- green
            if (elapsed >= respawnTime) then color = "FF0000" -- red
            elseif (elapsed >= respawnTime - 10) then color = "FF9100" -- orange
            elseif (elapsed >= respawnTime - 30) then color = "FFFF00" -- yellow
            end
            

            -- Get or create the control
            local bossControl = SpawnTimerContainer:GetNamedChild("Boss" .. index)
            if (bossControl == nil) then
                bossControl = SpawnTimer.addBoss(bossName)
            end
            bossControl:GetNamedChild("TimerText"):SetText("|c" .. color .. timerFormatted .. "|r")
            bossControl:GetNamedChild("BossText"):SetText(bossName)
            bossControl:SetHidden(false)

            -- Special scamp handling during event?
            if (bossName == "Sewers Scamp") then
                -- Display an alert X seconds prior to respawn
                if (elapsed >= (KyzderpsDerps.savedOptions.spawnTimer.scamp - KyzderpsDerps.savedOptions.spawnTimer.alert.seconds)
                    and not KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted) then
                    KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted = true
                    if (KyzderpsDerps.savedOptions.spawnTimer.alert.enable) then
                        SpawnTimer.showAnnouncement(bossName,
                                         "Respawning in " .. KyzderpsDerps.savedOptions.spawnTimer.alert.seconds .. " seconds!",
                                         SOUNDS.BATTLEGROUND_NEARING_VICTORY)
                    end
                end
            end

            -- Display an alert X seconds prior to respawn
            if (elapsed >= (respawnTime - KyzderpsDerps.savedOptions.spawnTimer.alert.seconds)
                and not KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted) then
                KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted = true
                if (KyzderpsDerps.savedOptions.spawnTimer.alert.enable) then
                    SpawnTimer.showAnnouncement(bossName,
                                     "Respawning in " .. KyzderpsDerps.savedOptions.spawnTimer.alert.seconds .. " seconds!",
                                     SOUNDS.BATTLEGROUND_NEARING_VICTORY)
                end
            end
        end
    end

    -- Hide boss controls that are no longer being used
    if (SpawnTimerContainer:GetNumChildren() - 2 > index) then
        for i = index + 1, SpawnTimerContainer:GetNumChildren() - 2 do
            SpawnTimerContainer:GetNamedChild("Boss" .. i):SetHidden(true)
        end
    end

    -- Adjust the panel height
    SpawnTimerContainer:SetHeight((index + 1) * 24 + 6)

    -- Hide the panel if there are no timers
    if (index == 0) then
        SpawnTimerContainer:SetHidden(true)
        EVENT_MANAGER:UnregisterForUpdate(KyzderpsDerps.name .. "SpawnTimerTimer")
        KyzderpsDerps:dbg("Stopping SpawnTimer polling")
        running = false
    elseif (HUD_SCENE:IsShowing() or HUD_UI_SCENE:IsShowing()) then
        SpawnTimerContainer:SetHidden(not KyzderpsDerps.savedOptions.spawnTimer.enable)
    end
end

-- Initialize a timer line and add to the panel
function SpawnTimer.addBoss(bossName)
    local index = SpawnTimerContainer:GetNumChildren() - 1
    local bossControl = CreateControlFromVirtual(
        "$(parent)Boss" .. tostring(index),  -- name
        SpawnTimerContainer,           -- parent
        "SpawnTimer_Line_Template",    -- template
        "")                            -- suffix
    bossControl:SetAnchor(TOPLEFT, SpawnTimerContainerLabel, BOTTOMLEFT, 0, (index - 1) * 24)
    return bossControl
end

-- Remove a timer line and remove it from the data
function SpawnTimer.removeBoss(bossName)
    CHAT_SYSTEM:AddMessage("You removed " .. bossName .. " from the boss timers.")
    KyzderpsDerps.savedValues.spawnTimer.timers[bossName] = nil
    SpawnTimer.pollTimer() -- Update it immediately
end

-- Fill the chat text field with the spawn timer for the clicked boss
function SpawnTimer.printBoss(bossName)
    local respawnTime = 306 -- default of 5:06
    if (type(SpawnTimer.BOSS_NAMES[bossName]) == "number") then
        respawnTime = SpawnTimer.BOSS_NAMES[bossName]
    end

    local startTime = KyzderpsDerps.savedValues.spawnTimer.timers[bossName].startTime
    local seconds = respawnTime - GetTimeStamp() + startTime
    CHAT_SYSTEM:StartTextEntry(bossName .. string.format(" should respawn in %d mins %d secs", zo_floor(seconds / 60), seconds % 60))
end

-- Display a center-screen announcement with sound effect
function SpawnTimer.showAnnouncement(msgText, secondText, sound)
    local msgSound = sound or SOUNDS.CHAMPION_POINT_GAINED
    local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, msgSound)
    msg:SetText(msgText, secondText)
    msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
    msg:MarkSuppressIconFrame()
    CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
end

function SpawnTimer:Initialize()
    KyzderpsDerps:dbg("    Initializing SpawnTimer module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpawnTimerDeath", EVENT_UNIT_DEATH_STATE_CHANGED, OnDeathStateChanged)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpawnTimerDeathXP", EVENT_COMBAT_EVENT, OnCombatXP)
    EVENT_MANAGER:AddFilterForEvent(KyzderpsDerps.name .. "SpawnTimerDeathXP", EVENT_COMBAT_EVENT, REGISTER_FILTER_COMBAT_RESULT, ACTION_RESULT_DIED_XP)
    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpawnTimerLootReceived", EVENT_LOOT_RECEIVED, OnLootReceived)

    -- Register timer update
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "SpawnTimerTimer", 900, SpawnTimer.pollTimer)
    KyzderpsDerps:dbg("Starting SpawnTimer polling")
    running = true

    -- Initialize position
    SpawnTimerContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.spawnTimer.x, KyzderpsDerps.savedValues.spawnTimer.y)
    SpawnTimerContainer:SetHidden(not KyzderpsDerps.savedOptions.spawnTimer.enable)

    -- Hide panel while in menus
    HUD_SCENE:RegisterCallback("StateChange", fragmentChange)
    HUD_UI_SCENE:RegisterCallback("StateChange", fragmentChange)
end
