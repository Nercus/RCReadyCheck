---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

--@do-not-package@
---@type function
local ReloadUI = C_UI.Reload

local playerLoginFired = false
local preFiredQueue = {}
--@end-do-not-package@



---add debug message to DevTool
---@param ... table | string | number | boolean | nil
function RCReadyCheck:Debug(...)
    --@do-not-package@
    local args = ...
    if (playerLoginFired == false) then
        table.insert(preFiredQueue, { args })
        return
    end
    if (C_AddOns.IsAddOnLoaded("DevTool") == false) then
        C_Timer.After(1, function()
            RCReadyCheck:Debug(args)
        end)
        return
    end
    local DevToolFrame = _G["DevToolFrame"] ---@type Frame
    local DevTool = _G["DevTool"] ---@type any // dont want to type all of DevTool
    DevTool:AddData(args)
    if not DevToolFrame then
        return
    end
    if not DevToolFrame:IsShown() then
        DevTool:ToggleUI()
        C_Timer.After(1, function()
            RCReadyCheck:Debug(args)
        end)
        return
    end
    --@end-do-not-package@
end

--@do-not-package@
RCReadyCheck:RegisterEvent("PLAYER_LOGIN", function()
    playerLoginFired = true
    C_Timer.After(1, function()
        for i = 1, #preFiredQueue do
            RCReadyCheck:Debug(unpack(preFiredQueue[i]))
        end
    end)
end)



local devAddonList = {
    "RCLootCouncil",
    "!BugGrabber",
    "BugSack",
    "TextureAtlasViewer",
    "DevTool",
    "RCReadyCheck",
    "Wowlua"
}



local function loadDevAddons(isDev)
    if not isDev then
        C_AddOns.DisableAddOn(RCReadyCheck.addonName)
        local loadedAddons = RCReadyCheck:GetVar("loadedAddons") or {}
        if #loadedAddons == 0 then
            C_AddOns.EnableAllAddOns()
            return
        end
        for i = 1, #loadedAddons do
            local name = loadedAddons[i] ---@type string
            C_AddOns.EnableAddOn(name)
        end
    else
        C_AddOns.DisableAllAddOns()
        for i = 1, #devAddonList do
            local name = devAddonList[i]
            C_AddOns.EnableAddOn(name)
        end
    end
end


local function setDevMode()
    local devModeEnabled = RCReadyCheck:GetVar("devMode")
    if (devModeEnabled) then
        RCReadyCheck:SaveVar("devMode", false)
    else
        RCReadyCheck:SaveVar("devMode", true)
    end
    loadDevAddons(not devModeEnabled)
    ReloadUI()
end
RCReadyCheck:AddSlashCommand("dev", setDevMode, "Toggle dev mode")



local keysToKeep = {
    ["devMode"] = true,
    ["loadedAddons"] = true,
    ["version"] = true,
}

StaticPopupDialogs["RCReadyCheck_RESET_SAVED_VARS"] = {
    text = "Are you sure you want to reset all saved variables?",
    button1 = "Yes",
    button2 = "No",
    OnAccept = function()
        for key, _ in pairs(RCReadyCheckDB) do
            if not keysToKeep[key] then
                RCReadyCheckDB[key] = nil
            end
        end
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local function ResetSavedVars()
    -- use a static popup to confirm
    StaticPopup_Show("RCReadyCheck_RESET_SAVED_VARS")
end


local function AddDevReload()
    local f = CreateFrame("frame", nil, UIParent, "DefaultPanelTemplate")
    f:SetPoint("BOTTOM", 0, 10)
    f:SetFrameStrata("HIGH")
    f:SetFrameLevel(100)

    local totalWidth = 60
    local text = f:CreateFontString(nil, "OVERLAY")
    text:SetFontObject(GameFontNormalLarge)
    text:SetPoint("TOP", 0, -30)
    text:SetText("Press 1 to reload UI")
    f:SetScript("OnKeyDown", function(_, key)
        if key == "1" then
            ReloadUI()
        end
    end)


    local button1 = CreateFrame("Button", nil, f, "SharedButtonLargeTemplate")
    button1:SetPoint("LEFT", 30, -20)
    button1:SetSize(130, 40)
    button1:SetFrameStrata("HIGH")
    button1:SetText("Reset Saved Vars")
    button1:SetScript("OnClick", ResetSavedVars)

    totalWidth = totalWidth + button1:GetWidth() + 10

    local button2 = CreateFrame("Button", nil, f, "SharedButtonLargeTemplate")
    button2:SetPoint("LEFT", button1, "RIGHT", 10, 0)
    button2:SetSize(130, 40)
    button2:SetFrameStrata("HIGH")
    button2:SetText("Debug Addon")
    button2:SetScript("OnClick", function()
        RCReadyCheck:Debug(RCReadyCheck)
    end)

    totalWidth = totalWidth + button2:GetWidth() + 10

    local button3 = CreateFrame("Button", nil, f, "SharedButtonLargeTemplate")
    button3:SetPoint("LEFT", button2, "RIGHT", 10, 0)
    button3:SetSize(130, 40)
    button3:SetFrameStrata("HIGH")
    button3:SetText("Exit Dev Mode")
    button3:SetScript("OnClick", setDevMode)

    totalWidth = totalWidth + button3:GetWidth() + 10

    f:SetPropagateKeyboardInput(true)
    f:SetSize(totalWidth, 100)
    f:Show()
end

local function loadDevMode(_, loadedAddon)
    if loadedAddon ~= RCReadyCheck.addonName then
        return
    end
    local devModeEnabled = RCReadyCheck:GetVar("devMode")
    if (devModeEnabled) then
        RCReadyCheck:Print("Dev mode enabled")
        AddDevReload()
    else
        -- check what addons are loaded right now and save them
        local loadedAddons = {}
        for i = 1, C_AddOns.GetNumAddOns() do
            local name, _, _, _, reason = C_AddOns.GetAddOnInfo(i)
            if reason ~= "DISABLED" then
                table.insert(loadedAddons, name)
            end
        end
        RCReadyCheck:SaveVar("loadedAddons", loadedAddons)
    end
end

RCReadyCheck:RegisterEvent("ADDON_LOADED", loadDevMode)

--@end-do-not-package@
