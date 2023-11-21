KyzderpsDerps = KyzderpsDerps or {}
KyzderpsDerps.PreLogout = KyzderpsDerps.PreLogout or {}
local PreLogout = KyzderpsDerps.PreLogout

---------------------------------------------------------------------
 -- Set to offline before logging out
---------------------------------------------------------------------
local function HideOnLogout()
    if (KyzderpsDerps.savedOptions.misc.hideOnLogout) then
        SelectPlayerStatus(PLAYER_STATUS_OFFLINE)
    end
end


---------------------------------------------------------------------
-- Turn off most addons
---------------------------------------------------------------------
local addonsToEnable = {
    ["AddonSelector"] = true,
    ["AlphaGear"] = true,
    ["CarosSkillPointSaver"] = true,
    ["DolgubonsLazyWritCreator"] = true,
    ["IIfA"] = true,
    ["KyzderpsDerps"] = true,
    ["LibVotansAddonList"] = true,
    ["VotansKeybinder"] = true,

    ["libAddonKeybinds"] = true,
    ["LibAddonMenu-2.0"] = true,
    ["LibAsync"] = true,
    ["LibCustomMenu"] = true,
    ["LibDialog"] = true,
    ["LibLazyCrafting"] = true,
    ["LibScrollableMenu"] = true,
}

local ADDON_MANAGER
local function LoadFewAddons()
    if (not KyzderpsDerps.savedOptions.misc.loadFewAddons) then
        return
    end

    if (not ADDON_MANAGER) then
        ADDON_MANAGER = GetAddOnManager()
    end

    for index = 1, ADDON_MANAGER:GetNumAddOns() do
        local name, title, author, description, enabled, state, isOutOfDate, isLibrary = ADDON_MANAGER:GetAddOnInfo(index)
        if (enabled and not addonsToEnable[name]) then
            ADDON_MANAGER:SetAddOnEnabled(index, false)
        elseif (not enabled and addonsToEnable[name]) then
            ADDON_MANAGER:SetAddOnEnabled(index, true)
        end
    end
end
PreLogout.LoadFewAddons = LoadFewAddons
-- /script KyzderpsDerps.savedOptions.misc.loadFewAddons = true
-- /script KyzderpsDerps.PreLogout.LoadFewAddons()


---------------------------------------------------------------------
-- Init
---------------------------------------------------------------------
local function OnLogout()
    HideOnLogout()
    LoadFewAddons()
end

local prehooked = false
function PreLogout.Initialize()
    KyzderpsDerps:dbg("    Initializing PreLogout module...")

    if (not prehooked) then
        ZO_PreHook("Logout", OnLogout)
        ZO_PreHook("Quit", OnLogout)
        prehooked = true
    end
end


---------------------------------------------------------------------
-- Settings
---------------------------------------------------------------------
function PreLogout.GetSettings()
    return {
        type = "checkbox",
        name = "Hide before logout",
        tooltip = "Automatically set your status to OFFLINE before you log out or quit the game. For you lurkers out there",
        default = false,
        getFunc = function() return KyzderpsDerps.savedOptions.misc.hideOnLogout end,
        setFunc = function(value)
            KyzderpsDerps.savedOptions.misc.hideOnLogout = value
        end,
        width = "full",
    }
end
