PlayedChart = {
    currentChar = GetUnitName("player")
}

function PlayedChart:Initialize()
    KyzderpsDerps:dbg("    Initializing PlayedChart module...")

    PlayedChart.updatePlayedTime()

    ZO_PreHook("ReloadUI", PlayedChart.updatePlayedTime)
    ZO_PreHook("Logout", PlayedChart.updatePlayedTime)
    ZO_PreHook("SetCVar", PlayedChart.updatePlayedTime)
    ZO_PreHook("Quit", PlayedChart.updatePlayedTime)
end

function PlayedChart.updatePlayedTime()
    KyzderpsDerps.savedValues.playedChart.characters[PlayedChart.currentChar] = GetSecondsPlayed()
end

-- Build the entire string for all played
function PlayedChart.buildPlayed()
    PlayedChart.updatePlayedTime()

    local result = "=== Time Played ==="
    local totalTime = 0

    -- sort by descending amount played
    for name, seconds in spairs(KyzderpsDerps.savedValues.playedChart.characters, function(t, a, b) return t[b] < t[a] end) do
        totalTime = totalTime + seconds
        result = result .. "\n|cFFFFFF" .. name .. " -|r "
        result = result .. ZO_FormatTime(seconds, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS)
        result = result .. "|cFFFFFF" .. string.format(" (%.2f hours)", seconds / 3600) .. "|r"
    end

    -- print the total as well
    result = result .. "\n\n|cFFFFFFTOTAL -|r "
    result = result .. ZO_FormatTime(totalTime, TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, TIME_FORMAT_PRECISION_SECONDS)
    result = result .. "|cFFFFFF" .. string.format(" (%.2f hours)", totalTime / 3600) .. "|r"

    return result
end

-- lazy, copied from https://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys 
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end
