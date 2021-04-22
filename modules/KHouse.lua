KyzderpsDerps = KyzderpsDerps or {}

local function PortToKyzersHouse()
    KyzderpsDerps:msg("Porting to @Kyzeragon's primary residence...")
    if (GetUnitDisplayName("player") == "@Kyzeragon") then
        RequestJumpToHouse(GetHousingPrimaryHouse())
    else
        JumpToHouse("@Kyzeragon")
    end
end

local function FindHouseByName(word)
    word = string.lower(word)
    for houseId = 1, 200 do
        local houseName = GetCollectibleName(GetCollectibleIdForHouse(houseId))
        if (houseName and houseName ~= "") then
            -- Match
            if (string.find(string.lower(houseName), word, 1, true)) then
                return houseId
            end
        end
    end
    return nil
end

local function PortToHouse(argString)
    local args = {}
    local length = 0
    for word in argString:gmatch("%S+") do
        table.insert(args, word)
        length = length + 1
    end

    -- I could let this flow through the logic below but lazy
    if (length == 0) then
        if (KyzderpsDerps.savedOptions.general.experimental) then
            PortToKyzersHouse()
        else
            KyzderpsDerps:msg("Porting to your primary residence...")
            RequestJumpToHouse(GetHousingPrimaryHouse())
        end
        return
    end

    -- First determine if the first arg is a name
    local name = nil
    local houseId = -1
    local toFindString = ""
    local outside = false
    if (string.sub(args[1], 1, 1) == "@") then
        name = args[1]
        if (length > 1) then
            houseId = FindHouseByName(args[2])
            if (houseId == nil) then
                KyzderpsDerps:msg("Couldn't find a house matching " .. args[2])
                return
            end
        end -- else it's the primary
    else
        -- Your own house, so search
        houseId = FindHouseByName(args[1])
        if (houseId == nil) then
            KyzderpsDerps:msg("Couldn't find a house matching " .. args[1])
            return
        end

        if (length > 1 and (args[2] == "out" or args[2] == "outside")) then
            outside = true
        end
    end

    KyzderpsDerps:msg(string.format("Attempting to port %s %s %s...",
        (outside) and "outside" or "to",
        (name == nil) and "your" or (name .. "'s"),
        (houseId == -1) and "primary residence" or GetCollectibleName(GetCollectibleIdForHouse(houseId))
    ))

    if (name == nil) then
        RequestJumpToHouse(houseId, outside) 
    elseif (houseId == -1) then
        JumpToHouse(name)
    else
        JumpToSpecificHouse(name, houseId)
    end
end

--[[
/khouse
/khouse stillwaters
/khouse @CrimsonFate
/khouse @oceanbluee coven
/khouse nonexistent
/khouse @ooki42 nonexistent
/khouse noat hall
]]


-------------------------------------------------------------------------------
function KyzderpsDerps.InitializeKHouse()
    SLASH_COMMANDS["/khouse"] = PortToHouse
end