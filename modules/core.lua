---@class RCReadyCheck : NercUtilsAddon
local RCReadyCheck = LibStub("NercUtils"):GetAddon(...)


RCReadyCheck:SetSlashTrigger("/rcrc", 1)
RCReadyCheck:EnableHelpCommand()

if RCReadyCheck.AddAddonToWhitelist then
    RCReadyCheck:AddAddonToWhitelist("RCLootCouncil")
end
