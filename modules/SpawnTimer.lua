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
        ["1228"] = true,  -- Black Drake Villa
        ["1229"] = true,  -- The Cauldron
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
        ["1263"] = true,  -- Rockgrove
    },


-- "Name" of boss (including location/groups) to the number of seconds it takes to respawn. true = default 306s
    BOSS_NAMES = {
    -- Dolmens - TODO: 5:18? stonefalls 6:14?

    -- Bangkorai
        ["Curnard the Generous"] = true, -- Delve: Viridian Watch
        ["Razak's Behemoth"] = 300, -- PD: Razak's Wheel

    -- Coldharbor
        ["Aez the Collector"] = 305, -- PD: Village of the Lost

    -- Glenumbra
        ["Rutmange"] = 305, -- PD: Bad Man's Hallows - Skeever

    -- Grahtwood
        ["Great Thorn"] = 300, -- PD: Rood Sunder Ruins
        ["The Devil Wrathmaw"] = 300, -- PD: Rood Sunder Ruins
        ["Rustjaw"] = 300, -- PD: Rood Sunder Ruins
        ["Thick-Bark"] = 300, -- PD: Rood Sunder Ruins
        ["Silent Claw"] = 300, -- PD: Rood Sunder Ruins

    -- Malabal Tor
        ["Arrai"] = true, -- Delve: Shael Ruins

    -- Reaper's March
        ["Sergeant Atilus"] = 300, -- PD: Vile Manse

    -- Shadowfen
        ["Drel"] = 305, -- PD: Sanguine's Demense
        ["The Bloody Judge"] = 305, -- PD: Sanguine's Demense

    -- Stonefalls
        ["The Moonlit Maiden"] = 305, -- PD: Crow's Wood - Wispmother next to skyshard
        ["Buron"] = 305, -- PD: Crow's Wood - Ghost in cave

    -- Summerset
        ["Direnni Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Sil-Var-Woad Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Rellenthil Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Corgrad Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Welenkin Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Sunhold Abyssal Geyser"] = 645, -- Abyssal Geyser
        ["Welkadra"] = 305, -- PD: Sunhold - Echatere closest to entrance

    -- Northern Elsweyr
        ["Dragon"] = 620, -- It spawns on the map at around 10:20 (or at least, once), but landed at 11:00
        ["Lieutenant Kurzatha"] = 300, -- PD: Rimmen Necropolis
        ["Lieutenant Fazumir"] = 300, -- PD: Rimmen Necropolis

    -- Southern Elsweyr
        ["Ri'Atahrashi"] = 600, -- WB
        ["Iratan the Lightbringer"] = 600, -- WB

    -- Western Skyrim
        ["Shademother"] = 606, -- WB
        ["Tulnir"] = 301, -- PD: Labyrinthian - Exterior altar

    -- Blackwood
        ["Bhrum / Koska"] = 331, -- WB
        ["War Chief Zathmoz"] = 313, -- WB - I sat at one once that took over 20 minutes to spawn... weird. But after that was 5:03. He takes a while to become damageable though, so this is the damageable timer
        ["Xeemhok the Trophy-Taker"] = 313, -- WB
        ["Old Deathwart"] = 330, -- WB
        ["Ghemvas the Harbinger"] = 302, -- WB
        ["Sul-Xan Ritual Site"] = 302, -- WB

    -- Cyrodiil
        ["Bear Matriarch"] = 302, -- Delve: Temple to the Divines

    -- Imperial City Sewers (non-event 10 mins, event same I think?)
        ["Hzu-Hakan"] = 600, -- Irrigation Tunnels (AD)
        ["Emperor Leovic"] = 600, -- Abyssal Depths (AD)
        ["General Kryozote"] = 600, -- Abyssal Depths (AD)
        ["Lady of the Depths"] = 600, -- Weaver's Nest (AD)
        ["Gati the Storm Sister"] = 600, -- Lambent Passage (DC)
        ["General Zamachar"] = 600, -- Lambent Passage (DC)
        ["Otholug gro-Goldfolly"] = 600, -- Vile Drainage (DC)
        ["Taebod the Gatekeeper"] = 600, -- Wavering Veil (DC)
        ["Wadracki"] = 600, -- Harena Hypogeum (EP)
        ["Ebral the Betrayer"] = 600, -- Antediluvian Vaults (EP)
        ["General Nazenaechar"] = 600, -- Antediluvian Vaults (EP)
        ["Secundinus the Despoiler"] = 600, -- Alessian Tombs (EP)

    -- Imperial City (non-event 15 mins)
        ["Lady Malygda"] = 900, -- Arboretum
        ["Ysenda Resplendent"] = 900, -- Arboretum
        ["Glorgoloch the Destroyer"] = 900, -- Arena
        ["King Khrogo"] = 900, -- Arena
        ["The Screeching Matron"] = 900, -- Elven Gardens
        ["Zoal the Ever-Wakeful"] = 900, -- Elven Gardens
        ["Nunatak"] = 900, -- Memorial
        ["Volghass"] = 900, -- Memorial
        ["Amoncrul"] = 900, -- Nobles
        ["Baron Thirsk"] = 900, -- Nobles
        ["Immolator Charr"] = 900, -- Temple
        ["Mazaluhad"] = 900, -- Temple

    },


-- Boss actual names to name of the group. GetPlayerLocationName = should use output of that method
    BOSS_GROUPS = {
    -- Dolmens
        ["Dread Daedroth"] = "GetPlayerLocationName", -- Dolmen unnamed
        ["Dread Frost Atronach"] = "GetPlayerLocationName", -- Dolmen unnamed
        ["Dread Xivkyn Banelord"] = "GetPlayerLocationName", -- Dolmen unnamed
        ["Dread Lich"] = "GetPlayerLocationName", -- Dolmen unnamed

        ["Lord Dregas Volar"] = "GetPlayerLocationName", -- Dolmen - holder of the Daedric Crescent
        ["Gedna Relvel"] = "GetPlayerLocationName", -- Dolmen - Lich of Mournhold
        ["Vika"] = "GetPlayerLocationName", -- Dolmen - Dark Seducer sister
        ["Dylora"] = "GetPlayerLocationName", -- Dolmen - Dark Seducer sister
        ["Jansa"] = "GetPlayerLocationName", -- Dolmen - Dark Seducer sister
        ["Nomeg Haga"] = "GetPlayerLocationName", -- Dolmen - Frost Atronach
        ["Hrelvesuu"] = "GetPlayerLocationName", -- Dolmen - Daedroth
        ["Zymel Hriz"] = "GetPlayerLocationName", -- Dolmen - Storm Atronach
        ["Menta Na"] = "GetPlayerLocationName", -- Dolmen - Daedroth
        ["Kathutet"] = "GetPlayerLocationName", -- Dolmen - Torturer
        ["Amkaos"] = "GetPlayerLocationName", -- Dolmen - Torturer
        ["Ranyu"] = "GetPlayerLocationName", -- Dolmen - Torturer
        ["Yggmanei the Ever-Open Eye"] = "GetPlayerLocationName", -- Dolmen - Molag Bal's greatest spy
        ["Velehk Sain"] = "GetPlayerLocationName", -- Dolmen - Dremora pirate
        ["Anaxes"] = "GetPlayerLocationName", -- Dolmen - Xivilai torturer
        ["Medrike"] = "GetPlayerLocationName", -- Dolmen - Xivilai torturer
        ["King Styriche of Verkarth"] = "GetPlayerLocationName", -- Dolmen
        ["Fangaril"] = "GetPlayerLocationName", -- Dolmen - companion of the King
        ["Zayzahad"] = "GetPlayerLocationName", -- Dolmen - companion of the King
        ["Rhagothan"] = "GetPlayerLocationName", -- Dolmen - Devourer of Souls
        ["Glut"] = "GetPlayerLocationName", -- Dolmen - Ogrim brother
        ["Hogshead"] = "GetPlayerLocationName", -- Dolmen - Ogrim brother
        ["Stumble"] = "GetPlayerLocationName", -- Dolmen - Ogrim brother
        ["Ozozzachar"] = "GetPlayerLocationName", -- Dolmen - Titan
        ["Methats"] = "GetPlayerLocationName", -- Dolmen - Dremora traveler
        ["Vonshala"] = "GetPlayerLocationName", -- Dolmen - Dremora traveler
        ["Sumeer"] = "GetPlayerLocationName", -- Dolmen - Dremora traveler

    -- Summerset
        ["Ruella Many-Claws"] = "GetPlayerLocationName", -- Abyssal Geyser
        ["Churug of the Abyss"] = "GetPlayerLocationName", -- Abyssal Geyser
        ["Sheefar of the Depths"] = "GetPlayerLocationName", -- Abyssal Geyser
        ["Girawell the Erratic"] = "GetPlayerLocationName", -- Abyssal Geyser - Salamander
        ["Muustikar Wave-Eater"] = "GetPlayerLocationName", -- Abyssal Geyser
        ["Reefhammer"] = "GetPlayerLocationName", -- Abyssal Geyser - Haj Mota
        ["Darkstorm the Alluring"] = "GetPlayerLocationName", -- Abyssal Geyser - Nereid thing
        ["Eejoba the Radiant"] = "GetPlayerLocationName", -- Abyssal Geyser - Wispmother
        ["Tidewrack"] = "GetPlayerLocationName", -- Abyssal Geyser - Sea Lurcher
        ["Vsskalvor"] = "GetPlayerLocationName", -- Abyssal Geyser - Sea Viper

    -- Blackwood
        ["Bhrum"] = "Bhrum / Koska", -- WB: Minotaurs at Shardius's Excavation
        ["Koska"] = "Bhrum / Koska", -- WB: Minotaurs at Shardius's Excavation
        ["Yaxhat Deathmaker"] = "Sul-Xan Ritual Site", -- WB: Sul-Xan Ritual Site
        ["Veesha the Swamp Mystic"] = "Sul-Xan Ritual Site", -- WB: Sul-Xan Ritual Site
        ["Shuvh-Mok"] = "Sul-Xan Ritual Site", -- WB: Sul-Xan Ritual Site
        ["Nukhujeema"] = "Sul-Xan Ritual Site", -- WB: Sul-Xan Ritual Site
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
-- Display a center-screen announcement with sound effect
local function ShowAnnouncement(msgText, secondText, sound)
    local msgSound = sound or SOUNDS.CHAMPION_POINT_GAINED
    local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, msgSound)
    msg:SetText(msgText, secondText)
    msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
    msg:MarkSuppressIconFrame()
    CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
end


---------------------------------------------------------------------------------------------------
-- Check if a unit is a boss
-- Returns: group name
local function IsBossByUnitTag(unitTag)
    local bossName = GetUnitName(unitTag)
    if (SpawnTimer.BOSS_NAMES[bossName] or SpawnTimer.BOSS_GROUPS[bossName]) then
        -- All hand hard-coded bosses
    elseif (string.find(unitTag, "^boss")) then
        -- Should handle all world bosses, newer public dungeons, and world events
        KyzderpsDerps:dbg("|cFF8888Unhandled: " .. bossName .. "|r")
    elseif (unitTag == "reticleover") then
        -- Try all deadly and hard mobs?
        local diff = GetUnitDifficulty(unitTag)
        if (diff ~= MONSTER_DIFFICULTY_DEADLY and diff ~= MONSTER_DIFFICULTY_HARD) then
            if (bossName == "Trove Scamp" or bossName == "Cunning Scamp") then
                SpawnTimer.BossKilled("Sewers Scamp")
                return false
            elseif (not SpawnTimer.BOSS_NAMES[bossName] and not SpawnTimer.BOSS_GROUPS[bossName]) then
                return false
            end
        end

        -- Only care about "dungeons", this will be public dungeons and delves because group dungeons are skipped below
        if (not IsUnitInDungeon("player") and bossName ~= "Dragon") then
            -- This can be overland, so unnamed bosses at dolmens, or dragons
            local groupName = GetPlayerLocationName()
            if (string.find(groupName, "Dolmen$")) then
                return groupName
            end
            return false
        end
        KyzderpsDerps:dbg("|cFF8888Unhandled: " .. bossName .. "|r")
    else
        return false
    end

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

    -- Check the data
    local groupName = SpawnTimer.BOSS_GROUPS[bossName] or bossName
    if (groupName == "GetPlayerLocationName") then
        groupName = GetPlayerLocationName()
    end
    return groupName
end


---------------------------------------------------------------------------------------------------
--  EVENT_UNIT_DEATH_STATE_CHANGED (number eventCode, string unitTag, boolean isDead)
local function OnDeathStateChanged(_, unitTag, isDead)
    if (not isDead) then
        return
    end

    local groupName = IsBossByUnitTag(unitTag)
    if (groupName) then
        SpawnTimer.BossKilled(groupName, GetUnitName(unitTag))
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

function SpawnTimer.BossKilled(groupName, bossName)
    KyzderpsDerps.savedValues.spawnTimer.timers[groupName] = { startTime = GetTimeStamp(), alerted = false, }
    if (not running) then
        KyzderpsDerps:dbg("Starting SpawnTimer polling")
        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "SpawnTimerTimer", 900, SpawnTimer.pollTimer)
        running = true
    end

    -- Display chat message if enabled
    if (KyzderpsDerps.savedOptions.spawnTimer.chat.enable) then
        local msg = "|cFFFFFF" .. groupName .. "|r died"
        if (bossName ~= nil and groupName ~= bossName) then
            msg = "|cFFFFFF" .. bossName .. "|r died at |cFFFFFF" .. groupName .. "|r"
        end
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
                local groupName = IsBossByUnitTag("reticleover")
                if (groupName) then
                    local startTime
                    if (KyzderpsDerps.savedValues.spawnTimer.timers[groupName]) then
                        startTime = KyzderpsDerps.savedValues.spawnTimer.timers[groupName].startTime
                    end
                    if (not startTime or (GetTimeStamp() - startTime > 30)) then -- Only consider the loot reticle if it's not "new"
                        SpawnTimer.BossKilled(groupName)
                    end
                end
            end
        end
    end
end


---------------------------------------------------------------------------------------------------
-- Poll every 900ms to update the timer
function SpawnTimer.pollTimer()
    local index = 0
    -- Iterate through all bosses stored in the table
    for bossName, bossVals in pairs(KyzderpsDerps.savedValues.spawnTimer.timers) do
        index = index + 1
        local elapsed = (bossVals.startTime > 0) and GetTimeStamp() - bossVals.startTime or 0

        local respawnTime = 306 -- default of 5:06
        if (type(SpawnTimer.BOSS_NAMES[bossName]) == "number") then
            respawnTime = SpawnTimer.BOSS_NAMES[bossName]
        end

        -- Remove timers that are >= 2.5x length of respawn
        if (elapsed >= respawnTime * 2.5) then
            KyzderpsDerps.savedValues.spawnTimer.timers[bossName] = nil
            KyzderpsDerps:dbg("Removed " .. bossName .. " from respawn timers at " .. elapsed / 60 .. " mins")
        else

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
                        ShowAnnouncement(bossName,
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
                    ShowAnnouncement(bossName,
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


---------------------------------------------------------------------------------------------------
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

---------------------------------------------------------------------------------------------------
local function ManualBossKilled(bossName)
    if (not bossName or bossName == "") then return end
    KyzderpsDerps:msg("Manually adding timer for \"" .. bossName .. "\"")
    -- Check the data
    local groupName = SpawnTimer.BOSS_GROUPS[bossName] or bossName
    if (groupName == "GetPlayerLocationName") then
        groupName = GetPlayerLocationName()
    end
    SpawnTimer.BossKilled(groupName, bossName)
end

---------------------------------------------------------------------------------------------------
-- Entry
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

    SLASH_COMMANDS["/addtimer"] = ManualBossKilled
end
