KyzderpsDerps = KyzderpsDerps or {}

local worldIcon

local function UpdateWaypoint()
    if (not Lib3D:GetCurrentZoneMeasurement()) then
        KyzderpsDerps:dbg("NO ZONE MEASUREMENT")
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
        -- local tempIcon = OSI.CreatePositionIcon(worldX, worldY, worldZ, "esoui/art/antiquities/bullet_active.dds", 100, {1, 1, 0})
        zo_callLater(function() OSI.DiscardPositionIcon(tempIcon) end, 10000)
    else
        KyzderpsDerps:msg("You don't have OdySupportIcons enabled or don't have the latest version, so no icon will be drawn at that position")
    end
end

---------------------------------------------------------------------
-- Called on initial player activated
function KyzderpsDerps.InitializeWaypoint()
    if (OSI and OSI.CreatePositionIcon and Lib3D) then
        KyzderpsDerps:dbg("    Initializing Waypoint module...")

        EVENT_MANAGER:RegisterForUpdate(KyzderpsDerps.name .. "Waypoint", 1000, UpdateWaypoint)
    end
end
