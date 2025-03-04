---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):GetAddon(AddOnName)


local SlashCommand = RCReadyCheck:GetModule("SlashCommand")
SlashCommand:SetSlashTrigger("/rcrc")
SlashCommand:EnableHelpCommand('help', 'Show This Help Message')

local Debug = RCReadyCheck:GetModule("Debug")
Debug:AddAddonToWhitelist("RCLootCouncil")
