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
    },
}

function SpawnTimer:Initialize()
    KyzderpsDerps:dbg("    Initializing SpawnTimer module...")

    EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "SpawnTimerDeath", EVENT_UNIT_DEATH_STATE_CHANGED, SpawnTimer.OnDeathStateChanged)

    -- Register timer update
    EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "SpawnTimerTimer", 900, SpawnTimer.pollTimer)

    -- Initialize position
    SpawnTimerContainer:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        KyzderpsDerps.savedValues.spawnTimer.x, KyzderpsDerps.savedValues.spawnTimer.y)
    SpawnTimerContainer:SetHidden(not KyzderpsDerps.savedOptions.spawnTimer.enable)
end

-- Save boss list position
function SpawnTimer.SavePosition()
    KyzderpsDerps.savedValues.spawnTimer.x = SpawnTimerContainer:GetLeft()
    KyzderpsDerps.savedValues.spawnTimer.y = SpawnTimerContainer:GetTop()
end

--  EVENT_UNIT_DEATH_STATE_CHANGED (number eventCode, string unitTag, boolean isDead)
function SpawnTimer.OnDeathStateChanged(eventCode, unitTag, isDead)
    if (isDead and string.find(unitTag, "^boss")) then
        local bossName = GetUnitName(unitTag)

        -- Skip trial or dungeon bosses
        if (GetCurrentParticipatingRaidId() ~= 0 or SpawnTimer.DUNGEON_ZONEIDS[tostring(GetZoneId(GetUnitZoneIndex("player")))]) then
            KyzderpsDerps:dbg("Skipping " .. bossName .. " because it is a trial/dungeon boss.")
            return
        end

        -- Skip bosses in the ignore list
        if (KyzderpsDerps.savedOptions.spawnTimer.ignoreList[bossName]) then
            KyzderpsDerps:dbg("Skipping " .. bossName .. " because it is in the ignore filter.")
            return
        end

        -- Add it to the list of bosses and create an entry in the panel
        KyzderpsDerps.savedValues.spawnTimer.timers[bossName] = { startTime = GetTimeStamp(), alerted = false, }

        -- Display chat message if enabled
        if (KyzderpsDerps.savedOptions.spawnTimer.chat.enable) then
            local msg = "|cFFFFFF" .. bossName .. "|r died"
            if (KyzderpsDerps.savedOptions.spawnTimer.chat.timestamp) then
                msg = "[" .. GetTimeString() .. "] " .. msg
            end
            CHAT_SYSTEM:AddMessage(msg)
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
            local timerFormatted = string.format("%02d:%02d", zo_floor(elapsed / 60), elapsed % 60)
            local color = "00FF00" -- green
            if (elapsed >= 306) then color = "FF0000" -- red
            elseif (elapsed >= 296) then color = "FF9100" -- orange
            elseif (elapsed >= 276) then color = "FFFF00" -- yellow
            end
            

            -- Get or create the control
            local bossControl = SpawnTimerContainer:GetNamedChild("Boss" .. index)
            if (bossControl == nil) then
                bossControl = SpawnTimer.addBoss(bossName)
            end
            bossControl:GetNamedChild("TimerText"):SetText("|c" .. color .. timerFormatted .. "|r")
            bossControl:GetNamedChild("BossText"):SetText(bossName)
            bossControl:SetHidden(false)

            -- Display an alert X seconds prior to respawn
            if (elapsed >= (306 - KyzderpsDerps.savedOptions.spawnTimer.alert.seconds)
                and not KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted) then
                KyzderpsDerps.savedValues.spawnTimer.timers[bossName].alerted = true
                if (KyzderpsDerps.savedOptions.spawnTimer.alert.enable) then
                    showAnnouncement(bossName,
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
    else
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
    local startTime = KyzderpsDerps.savedValues.spawnTimer.timers[bossName].startTime
    local seconds = 306 - GetTimeStamp() + startTime
    CHAT_SYSTEM:StartTextEntry(bossName .. string.format(" should respawn in %d mins %d secs", zo_floor(seconds / 60), seconds % 60))
end

-- Display a center-screen announcement with sound effect
function showAnnouncement(msgText, secondText, sound)
    sound = sound or SOUNDS.CHAMPION_POINT_GAINED
    local msg = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, sound)
    msg:SetText(msgText, secondText)
    msg:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_CHAMPION_POINT_GAINED)
    msg:MarkSuppressIconFrame()
    CENTER_SCREEN_ANNOUNCE:DisplayMessage(msg)
end
