---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):CreateAddon(AddOnName, AddOnName .. "DB")

RCReadyCheck.RC = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")

local version = C_AddOns.GetAddOnMetadata(AddOnName, "Version")
local numericVersion = tonumber((version:gsub("%.", ""))) or 0
---version number in the format of 100 for 1.0.0 or 302 for 3.0.2
RCReadyCheck.version = numericVersion
RCReadyCheck.addonName = AddOnName
RCReadyCheck.nameVersionString = RCReadyCheck.addonName .. " v" .. version
