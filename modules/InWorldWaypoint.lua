KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.WorldIcons = KyzderpsDerps.WorldIcons or {}
local WorldIcons = KyzderpsDerps.WorldIcons
WorldIcons.name = KyzderpsDerps.name .. "WorldIcons"

---------------------------------------------------------------------
-- Map Waypoint
---------------------------------------------------------------------
local worldIcon
local function UpdateWaypoint()
    if (not Lib3D:GetCurrentZoneMeasurement()) then
        return
    end

    local _, _, worldY = GetUnitRawWorldPosition("player")

    if (worldIcon) then
        OSI.DiscardPositionIcon(worldIcon)
        worldIcon = nil
    end

    local localX, localZ = GetMapPlayerWaypoint()
    if (localX == 0 and localZ == 0) then
        return
    end

    local worldX, worldZ = Lib3D:LocalToWorld(localX, localZ)
    worldIcon = OSI.CreatePositionIcon(worldX * 100, worldY, worldZ * 100, "esoui/art/mappins/ui_worldmap_pin_customdestination.dds", 200)
end

---------------------------------------------------------------------
-- Called by keybind
---------------------------------------------------------------------
function KyzderpsDerps.PrintCurrentPosition()
    local zoneId, worldX, worldY, worldZ = GetUnitRawWorldPosition( "player" )
    KyzderpsDerps:msg(zo_strformat("zoneId=<<1>> {x = <<2>>, y = <<3>>, z = <<4>>}", zoneId, worldX, worldY, worldZ))

    if (OSI and OSI.CreatePositionIcon) then
        -- KyzderpsDerps:msg("Creating an icon at that position for 10 seconds...")
        local tempIcon = OSI.CreatePositionIcon(worldX, worldY, worldZ, "odysupporticons/icons/emoji-poop.dds", 100)
        zo_callLater(function() OSI.DiscardPositionIcon(tempIcon) end, 10000)
    else
        KyzderpsDerps:msg("You don't have OdySupportIcons enabled or don't have the latest version, so no icon will be drawn at that position")
    end
end

---------------------------------------------------------------------
-- Use OSI and HarvestMap to show icons for chests in dungeons
-- Permission granted by Shinni :D
---------------------------------------------------------------------
local inCombat = false
local chestPoops = {}

-- Whether icons of a particular type should be shown right now
local function ShouldShowHarvest(settingName)
    -- Check if in the correct zone first
    local zoneId = tostring(GetZoneId(GetUnitZoneIndex("player")))
    if ((settingName == "dungeonChest" or settingName == "dungeonSack")
        and not KyzderpsDerps.DUNGEON_ZONEIDS[zoneId]) then
        return false
    end
    if ((settingName == "trialChest" or settingName == "trialSack")
        and not KyzderpsDerps.TRIAL_ZONEIDS[zoneId]) then
        return false
    end

    -- Check the setting itself, and combat state if needed
    local setting = KyzderpsDerps.savedOptions.worldIcons[settingName]
    if (setting == 1) then
        return false
    elseif (setting == 2) then
        return not inCombat
    elseif (setting == 3) then
        return true
    end
end

-- Remove all icons
local function RemoveChestPoops()
    for _, icon in pairs(chestPoops) do
        OSI.DiscardPositionIcon(icon)
    end
    chestPoops = {}
end

local retries = 0
local prevShowChest = false
local prevShowSack = false
local function AddChestPoops(isCombatOnlyChange)
    local cache = Harvest.Data:GetCurrentZoneCache().mapCaches[Harvest.mapTools:GetPlayerMapMetaData().map]
    KyzderpsDerps:dbg(Harvest.mapTools:GetPlayerMapMetaData().map)

    -- Retry because data might not be loaded yet. Maybe there's some event that's fired when loading is done, but I'm too lazy to look
    if (retries > 5) then return end
    if (not cache or not cache.pinTypeId) then
        KyzderpsDerps:dbg("Trying chest poops again in 3 seconds")
        retries = retries + 1
        zo_callLater(function() AddChestPoops(isCombatOnlyChange) end, 3000)
        return
    end
    retries = 0

    -- Get the current state of settings. ShouldShowHarvest handles the zone, so we need
    -- only take either of them
    local showChest = ShouldShowHarvest("dungeonChest") or ShouldShowHarvest("trialChest")
    local showSack = ShouldShowHarvest("dungeonSack") or ShouldShowHarvest("trialSack")
    KyzderpsDerps:dbg(string.format("combat %s chest %s sack %s",
        isCombatOnlyChange and "true" or "false",
        showChest and "true" or "false",
        showSack and "true" or "false"))

    -- Do not redraw all the icons if this redraw was triggered by a combat state change, but nothing has changed
    if (isCombatOnlyChange and prevShowChest == showChest and prevShowSack == showSack) then return end
    RemoveChestPoops()
    prevShowChest = showChest
    prevShowSack = showSack
    if (not showChest and not showSack) then return end

    KyzderpsDerps:dbg("drawing icons")
    for i, pinTypeId in pairs(cache.pinTypeId) do
        if (pinTypeId == 6 and showChest) then
            local icon = OSI.CreatePositionIcon(cache.worldX[i]*100, cache.worldZ[i]*100-50, cache.worldY[i]*100, "HarvestMap/Textures/Map/chest.dds", 100, {1.000, 0.937, 0.380})
            table.insert(chestPoops, icon)
        elseif (pinTypeId == 9 and showSack) then
            local icon = OSI.CreatePositionIcon(cache.worldX[i]*100, cache.worldZ[i]*100-50, cache.worldY[i]*100, "HarvestMap/Textures/Map/heavysack.dds", 100, {0.424, 0.690, 0.360})
            table.insert(chestPoops, icon)
        end
    end
end

local prevMap = ""
local function OnChestNeedsRefreshing(isCombatOnlyChange)
    local map = Harvest.mapTools:GetPlayerMapMetaData().map
    if (map == prevMap) then return end

    RemoveChestPoops()
    AddChestPoops(isCombatOnlyChange)
    prevMap = map
end

local function OnCombatStateChanged(_, combat)
    if (inCombat ~= combat) then
        inCombat = combat
        AddChestPoops(true)
    end
end

---------------------------------------------------------------------
-- Called on initial player activated
function WorldIcons.Initialize()
    if (OSI and OSI.CreatePositionIcon and Lib3D
        and KyzderpsDerps.savedOptions.worldIcons.destination) then
        KyzderpsDerps:dbg("    Initializing Waypoint module...")

        EVENT_MANAGER:RegisterForUpdate(WorldIcons.name .. "Waypoint", 1000, UpdateWaypoint)
    end

    local settings = KyzderpsDerps.savedOptions.worldIcons
    if (OSI and Harvest
        and (settings.dungeonChest > 1
            or settings.dungeonSack > 1
            or settings.trialChest > 1
            or settings.trialSack > 1)) then
        KyzderpsDerps:dbg("    Pooping on chests...")

        EVENT_MANAGER:RegisterForEvent(WorldIcons.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OnCombatStateChanged)
        EVENT_MANAGER:RegisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_PLAYER_ACTIVATED, function() OnChestNeedsRefreshing(false) end)
        EVENT_MANAGER:RegisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_ZONE_CHANGED, function() OnChestNeedsRefreshing(false) end)
        EVENT_MANAGER:RegisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_CURRENT_SUBZONE_LIST_CHANGED, function() OnChestNeedsRefreshing(false) end)

        prevMap = ""
        inCombat = IsUnitInCombat("player")
        OnChestNeedsRefreshing(false)
    end
end

function WorldIcons.Uninitialize()
    EVENT_MANAGER:UnregisterForUpdate(WorldIcons.name .. "Waypoint")
    EVENT_MANAGER:UnregisterForEvent(WorldIcons.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)
    EVENT_MANAGER:UnregisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_ZONE_CHANGED)
    EVENT_MANAGER:UnregisterForEvent(WorldIcons.name .. "ChestPoops", EVENT_CURRENT_SUBZONE_LIST_CHANGED)
end


---------------------------------------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------------------------------------
function WorldIcons.GetSettings()
    return {
        {
            type = "description",
            title = nil,
            text = "This module uses OdySupportIcons to draw icons in the world. These icons will be shown through objects and terrain.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Show destination in world",
            tooltip = "When you use the base-game keybind to \"Set Destination\" on the world map, also show it as an icon in the world. This will display at the same height your character is at. Requires OdySupportIcons and Lib3D",
            default = false,
            getFunc = function() return KyzderpsDerps.savedOptions.worldIcons.destination end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.worldIcons.destination = value
                WorldIcons.Uninitialize()
                WorldIcons.Initialize()
            end,
            width = "full",
            disabled = function() return OSI == nil or Lib3D == nil end,
        },
        {
            type = "dropdown",
            name = "Show HarvestMap chests in dungeons",
            tooltip = "Uses your HarvestMap data to display chest spawn locations while inside a dungeon. Recommend downloading the data via HarvestMapData. Requires OdySupportIcons and HarvestMap",
            choices = {"Never", "Outside combat", "Always"},
            choicesValues = {1, 2, 3},
            getFunc = function() return KyzderpsDerps.savedOptions.worldIcons.dungeonChest end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.worldIcons.dungeonChest = value
                WorldIcons.Uninitialize()
                WorldIcons.Initialize()
            end,
            width = "full",
            disabled = function() return OSI == nil or Harvest == nil end,
        },
        {
            type = "dropdown",
            name = "Show HarvestMap heavy sacks in dungeons",
            tooltip = "Uses your HarvestMap data to display heavy sack spawn locations while inside a dungeon. Recommend downloading the data via HarvestMapData. Requires OdySupportIcons and HarvestMap",
            choices = {"Never", "Outside combat", "Always"},
            choicesValues = {1, 2, 3},
            getFunc = function() return KyzderpsDerps.savedOptions.worldIcons.dungeonSack end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.worldIcons.dungeonSack = value
                WorldIcons.Uninitialize()
                WorldIcons.Initialize()
            end,
            width = "full",
            disabled = function() return OSI == nil or Harvest == nil end,
        },
        {
            type = "dropdown",
            name = "Show HarvestMap chests in trials",
            tooltip = "Uses your HarvestMap data to display chest spawn locations while inside a trial. Recommend downloading the data via HarvestMapData. Requires OdySupportIcons and HarvestMap",
            choices = {"Never", "Outside combat", "Always"},
            choicesValues = {1, 2, 3},
            getFunc = function() return KyzderpsDerps.savedOptions.worldIcons.trialChest end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.worldIcons.trialChest = value
                WorldIcons.Uninitialize()
                WorldIcons.Initialize()
            end,
            width = "full",
            disabled = function() return OSI == nil or Harvest == nil end,
        },
        {
            type = "dropdown",
            name = "Show HarvestMap heavy sacks in trials",
            tooltip = "Uses your HarvestMap data to display heavy sack spawn locations while inside a trial. Recommend downloading the data via HarvestMapData. Requires OdySupportIcons and HarvestMap",
            choices = {"Never", "Outside combat", "Always"},
            choicesValues = {1, 2, 3},
            getFunc = function() return KyzderpsDerps.savedOptions.worldIcons.trialSack end,
            setFunc = function(value)
                KyzderpsDerps.savedOptions.worldIcons.trialSack = value
                WorldIcons.Uninitialize()
                WorldIcons.Initialize()
            end,
            width = "full",
            disabled = function() return OSI == nil or Harvest == nil end,
        },
    }
end
