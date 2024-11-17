---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

local LOCALE = RCReadyCheck.locale

if LOCALE ~= "esES" and LOCALE ~= "esMX" then return end


---@class Locale
local L = RCReadyCheck.L
