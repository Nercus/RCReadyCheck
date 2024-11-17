---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

local LOCALE = RCReadyCheck.locale

if LOCALE ~= "ptBR" then return end

---@class Locale
local L = RCReadyCheck.L
