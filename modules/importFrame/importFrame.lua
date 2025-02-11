---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
local ImportFrame = RCReadyCheck:CreateModule("ImportFrame")
local Database = RCReadyCheck:GetModule("Database")
--- Holds all the constants for the addon

local L = RCReadyCheck.L


function ImportFrame:ParseImport(importString)
    local success = false

    if importString then
        ---@type table<string, any>
        local data = RCReadyCheck:DeserializeJSON(importString)
        if data then
            RCReadyCheck:Print(L["Data imported"])
            Database:SetBulkData(data.selections)
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

    ---@type EditBox
    local editBox = self.frame.editBox
    local textBuffer, i, lastPaste = {}, 0, 0
    local function clearBuffer(self)
        self:SetScript('OnUpdate', nil)
        local pasted = strtrim(table.concat(textBuffer))
        editBox:ClearFocus();
        pasted = pasted:match("^%s*(.-)%s*$");
        if (#pasted > 20) then
            ImportFrame:ParseImport(pasted);
            -- self.frame:SetTitle(L["Processed %i chars"]:format(i));
            editBox:SetMaxBytes(2500);
            editBox:SetText(strsub(pasted, 1, 2500));
        end
    end

    editBox:SetScript('OnChar', function(self, c)
        if lastPaste ~= GetTime() then
            textBuffer, i, lastPaste = {}, 0, GetTime()
            self:SetScript('OnUpdate', clearBuffer)
        end
        i = i + 1
        ---@type table<string, string>
        textBuffer[i] = c
    end)

    editBox:SetText("");
    editBox:SetMaxBytes(2500);
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
