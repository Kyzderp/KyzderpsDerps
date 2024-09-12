KyzderpsDerps = KyzderpsDerps or {}

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
---------------------------------------------------------------------
local chestPoops = {}
local retries = 0
local function AddChestPoops()
    local cache = Harvest.Data:GetCurrentZoneCache().mapCaches[Harvest.mapTools:GetPlayerMapMetaData().map]

    -- Retry because data might not be loaded yet. Maybe there's some event that's fired when loading is done, but I'm too lazy to look
    if (retries > 5) then return end
    if (not cache or not cache.pinTypeId) then
        KyzderpsDerps:dbg("Trying chest poops again in 3 seconds")
        retries = retries + 1
        zo_callLater(AddChestPoops, 3000)
        return
    end
    KyzderpsDerps:dbg("Refreshing chest poops")
    retries = 0

    for i, pinTypeId in pairs(cache.pinTypeId) do
        if (pinTypeId == 6) then
            local icon = OSI.CreatePositionIcon(cache.worldX[i]*100, cache.worldZ[i]*100-50, cache.worldY[i]*100, "HarvestMap/Textures/Map/chest.dds", 100, {1.000, 0.937, 0.380})
            table.insert(chestPoops, icon)
        elseif (pinTypeId == 9) then
            local icon = OSI.CreatePositionIcon(cache.worldX[i]*100, cache.worldZ[i]*100-50, cache.worldY[i]*100, "HarvestMap/Textures/Map/heavysack.dds", 100, {0.424, 0.690, 0.360})
            table.insert(chestPoops, icon)
        end
    end
end

local function RemoveChestPoops()
    for _, icon in pairs(chestPoops) do
        OSI.DiscardPositionIcon(icon)
    end
    chestPoops = {}
end

local prevMap = ""
local function OnChestNeedsRefreshing()
    local map = Harvest.mapTools:GetPlayerMapMetaData().map
    if (map == prevMap) then return end

    RemoveChestPoops()
    if (IsUnitInDungeon("player")) then
        zo_callLater(AddChestPoops, 3000)
    end
    prevMap = map
end

---------------------------------------------------------------------
-- Called on initial player activated
function KyzderpsDerps.InitializeWaypoint()
    if (OSI and OSI.CreatePositionIcon and Lib3D) then
        KyzderpsDerps:dbg("    Initializing Waypoint module...")

        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "Waypoint", 1000, UpdateWaypoint)
    end

    if (OSI and Harvest) then
        KyzderpsDerps:dbg("    Pooping on chests...")

        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ChestPoops", EVENT_PLAYER_ACTIVATED, OnChestNeedsRefreshing)
        EVENT_MANAGER:RegisterForEvent(KyzderpsDerps.name .. "ChestPoops", EVENT_ZONE_CHANGED, OnChestNeedsRefreshing)

        OnChestNeedsRefreshing()
    end
end
