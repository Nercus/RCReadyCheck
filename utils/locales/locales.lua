---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

-- might want to check out using the @localization@ in the future for curseforge translations
-- *** Using Phanx's method to localize strings ***
-- You can find the original code here: https://phanx.net/addons/tutorials/localize
local L = setmetatable({}, {
    __index = function(t, k)
        local v = tostring(k)
        --@do-not-package@
        if RCReadyCheck.Debug then
            RCReadyCheck:Debug("Missing localization for: " .. v)
        end
        --@end-do-not-package@
        rawset(t, k, v)
        return v
    end
})

RCReadyCheck.L = L
RCReadyCheck.locale = GetLocale()
