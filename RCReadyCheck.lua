---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
---@type string
local addonName = ...
RCReadyCheck.RC = LibStub("AceAddon-3.0"):GetAddon("RCLootCouncil")

local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
local numericVersion = tonumber((version:gsub("%.", ""))) or 0
---version number in the format of 100 for 1.0.0 or 302 for 3.0.2
RCReadyCheck.version = numericVersion
RCReadyCheck.name = addonName --[[@as string]]
RCReadyCheck.nameVersionString = RCReadyCheck.name .. " v" .. version
