local KD = KyzderpsDerps

local function ColorNumber(motorValue)
    motorValue = motorValue or 0
    return string.format("|cFF%02x00%f|r", math.floor((1 - motorValue) * 255), motorValue)
end

local function MySetGamepadVibration(duration, firstMotor, secondMotor, thirdMotor, fourthMotor, debugSourceInfo)
    if (duration > 0) then
        KD:dbg(string.format("%d - %s %s %s %s - " .. tostring(debugSourceInfo),
            duration,
            ColorNumber(firstMotor),
            ColorNumber(secondMotor),
            ColorNumber(thirdMotor),
            ColorNumber(fourthMotor)))
    end

    if (debugSourceInfo == "fishing") then return end -- because we call this too

    if (duration <= 500 and firstMotor <= 0.25 and secondMotor <= 0.25) then
        return true
    end
    if (duration == 2500 and firstMotor == 0.01 and secondMotor == 0.05) then
        SetGamepadVibration(1000, 1, 1, 0, 0, "fishing")
        return true
    end
end

function KD.InitializeVibrations()
    if (KD.savedOptions.general.experimental) then
        ZO_PreHook("SetGamepadVibration", MySetGamepadVibration)
    end
end
