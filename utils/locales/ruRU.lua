---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

local LOCALE = RCReadyCheck.locale

if LOCALE ~= "ruRU" then return end

---@class Locale
local L = RCReadyCheck.L
