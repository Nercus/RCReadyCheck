---@class RCReadyCheck
local RCReadyCheck = select(2, ...)


RCReadyCheck:SetSlashTrigger("/rcrc", 1)
RCReadyCheck:EnableHelpCommand()

if RCReadyCheck.AddAddonToWhitelist then
    RCReadyCheck:AddAddonToWhitelist("RCLootCouncil")
end
