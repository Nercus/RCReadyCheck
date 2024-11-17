---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
local LootFrame = RCReadyCheck:CreateModule("LootFrame")
--- Holds all the constants for the addon

---@class RCLootFrame : AceModule
---@field EntryManager table
local RCLootFrame = RCReadyCheck.RC:GetModule("RCLootFrame")

---@type table<string, boolean>
local itemHooked = {}

local RCLootFramePool = CreateFramePool("FRAME", nil, "RDReadyCheckLootFrameTemplate")


---@param entryManager table
---@param lootData table
function LootFrame:OnRCGetEntry(entryManager, lootData)
    ---@type table
    local frame = RCLootFrame.EntryManager:GetEntry(lootData)
    local ReadyCheckLootFrame = RCLootFramePool:Acquire()
    ---@cast ReadyCheckLootFrame RDReadyCheckLootFrame
    ReadyCheckLootFrame:SetEntry(frame)
    hooksecurefunc(frame, "Update", function(_, entry)
        ReadyCheckLootFrame:SetEntry(entry)
    end)
    frame.frame:HookScript("OnHide", function()
        RCLootFramePool:Release(ReadyCheckLootFrame)
    end)
end

function LootFrame:HookRCEntry()
    if self.hooked then return end
    hooksecurefunc(RCLootFrame.EntryManager, "GetEntry", function(self, lootData)
        local dataKey = tostring(lootData)
        if itemHooked[dataKey] then return end
        itemHooked[dataKey] = true
        LootFrame:OnRCGetEntry(self, lootData)
    end)
    self.hooked = true
end

RCReadyCheck:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    LootFrame:HookRCEntry()
end)
