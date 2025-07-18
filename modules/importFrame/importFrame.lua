---@class RCReadyCheck : NercUtilsAddon
local RCReadyCheck = LibStub("NercUtils"):GetAddon(...)

---@class ImportFrame
local ImportFrame = RCReadyCheck:GetModule("ImportFrame")
local Database = RCReadyCheck:GetModule("Database")
local Text = RCReadyCheck:GetModule("Text")
local JSON = RCReadyCheck:GetModule("JSON")


function ImportFrame:ParseImport(importString)
    local success = false

    if importString then
        ---@type table<string, any>
        local data = JSON:Deserialize(importString)
        if data then
            Text:Print("Data imported")
            Database:SetBulkData(data.selections)
            success = true
        end
    end
    if (success) then
        self:CloseImportFrame()
    else
        Text:Print("Failed to import")
    end
end

function ImportFrame:CreateImportFrame()
    if self.frame then return end
    self.frame = CreateFrame("Frame", "RCLootCouncil_ImportFrame", UIParent, "RCReadyCheckImportFrameTemplate")
    self.frame:SetTitle("Import Frame")

    ---@type EditBox
    local editBox = self.frame.editBox
    local textBuffer, i, lastPaste = {}, 0, 0
    local function clearBuffer(self)
        self:SetScript('OnUpdate', nil)
        local pasted = string.trim(table.concat(textBuffer))
        editBox:ClearFocus();
        pasted = pasted:match("^%s*(.-)%s*$");
        if (#pasted > 20) then
            ImportFrame:ParseImport(pasted);
            editBox:SetMaxBytes(2500);
            editBox:SetText(string.sub(pasted, 1, 2500));
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
end, "Open the import frame")
