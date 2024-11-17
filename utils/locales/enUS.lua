---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

local LOCALE = RCReadyCheck.locale

if LOCALE ~= "enUS" then return end

---@class Locale
local L = RCReadyCheck.L
L["Accept"] = "Accept"
L["Cancel"] = "Cancel"
L["Import"] = "Import"
L["Import Frame"] = "Import Frame"
L["Open the import frame"] = "Open the import frame"
L["Failed to import"] = "Failed to import"
L["Data imported"] = "Data imported"
