---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
local ImportFrame = RCReadyCheck:CreateModule("ImportFrame")
--- Holds all the constants for the addon

local L = RCReadyCheck.L


function ImportFrame:ParseImport(importString)
    local success = false

    if importString then
        ---@type table<string, any>
        local data = RCReadyCheck:DeserializeJSON(importString)
        if data then
            RCReadyCheck:Print(L["Data imported"])
            RCReadyCheck:SaveVar("importedData", data)
            success = true
        end
    end
    if (success) then
        self:CloseImportFrame()
    else
        RCReadyCheck:Print(L["Failed to import"])
    end
end

function ImportFrame:CreateImportFrame()
    if self.frame then return end
    self.frame = CreateFrame("Frame", "RCLootCouncil_ImportFrame", UIParent, "RCReadyCheckImportFrameTemplate")
    self.frame:SetTitle(L["Import Frame"])
    self.frame.importButton:SetText(L["Import"])
    self.frame.importButton:SetEnabled(false)

    ---@type EditBox
    local editBox = self.frame.scrollFrame.editBox
    self.frame.importButton:SetScript("OnClick", function()
        local importString = editBox:GetText()
        self:ParseImport(importString)
    end)

    editBox:SetScript("OnTextChanged", function()
        local text = editBox:GetText()
        self.frame.importButton:SetEnabled(strlen(text) > 0)
    end)
end

function ImportFrame:OpenImportFrame()
    if not self.frame then
        self:CreateImportFrame()
    end
    self.frame:Show()
end

function ImportFrame:CloseImportFrame()
    if self.frame then
        self.frame:Hide()
    end
end

function ImportFrame:ToggleImportFrame()
    if not self.frame or not self.frame:IsVisible() then
        self:OpenImportFrame()
    else
        self:CloseImportFrame()
    end
end

RCReadyCheck:AddSlashCommand("import", function()
    ImportFrame:ToggleImportFrame()
end, L["Open the import frame"])
