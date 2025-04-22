---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):GetAddon(AddOnName)

---@class Database
---@field db table<string, table<number, ImportDataEntry>>
local Database = RCReadyCheck:GetModule("Database")
local SavedVars = RCReadyCheck:GetModule("SavedVars")
local Events = RCReadyCheck:GetModule("Events")
local Text = RCReadyCheck:GetModule("Text")

Database.db = {}


---@class ImportDataEntry
---@field wowItemId? string
---@field characterName? string
---@field characterRealm? string
---@field selection? string
---@field absoluteGain? number
---@field relativeGain? number
---@field note? string


local REQUIRED_FIELDS = {
    "wowItemId",
    "characterName",
    "selection",
}

---@param entry ImportDataEntry
function Database:SetDataEntry(entry)
    for _, field in ipairs(REQUIRED_FIELDS) do
        if not entry[field] then
            error("Missing required field: " .. field)
        end
    end
    local realmName = (entry.characterRealm):gsub(" ", "")
    local key = entry.characterName .. "-" .. realmName
    self.db[key] = self.db[key] or {}

    local itemKey = tonumber(entry.wowItemId)
    if not itemKey then
        error("Invalid wowItemId: " .. entry.wowItemId)
    end


    self.db[key] = self.db[key] or {}
    self.db[key][itemKey] = entry
end

---@param data ImportDataEntry[]
function Database:SetBulkData(data)
    self.db = {}
    for _, entry in ipairs(data) do
        self:SetDataEntry(entry)
    end
    SavedVars:SetVar("importedData", self.db)
    SavedVars:SetVar("lastImport", time() - 60 * 60) -- subtract 1 hour to prevent warning on first import
end

function Database:GetEntry(characterName, wowItemId)
    assert(characterName, "characterName is required")
    assert(wowItemId, "wowItemId is required")
    ---@type string
    local key = characterName
    if not self.db[key] then
        return nil
    end
    if not self.db[key] then
        return nil
    end
    return self.db[key][wowItemId]
end

function Database:RestoreDB()
    local db = SavedVars:GetVar("importedData")
    if db then
        self.db = db --[[@as table]]
    end
end

local TIME_UNTIL_WARNING = (60 * 60 * 24 * 7)

function Database:ShowOutdatedDBWarning()
    local lastImport = SavedVars:GetVar("lastImport")
    if not lastImport then
        return
    end
    local diff = time() - lastImport
    if diff > TIME_UNTIL_WARNING then
        Text:Print(Text:WrapTextInColor("The imported data is outdated. Please import new data.", ERROR_COLOR))
        UIErrorsFrame:AddMessage("RCReadyCheck: The imported data is outdated. Please import new data.",
            ERROR_COLOR:GetRGBA() --[[@as number]])
    end
end

Events:RegisterEvent("PLAYER_LOGIN", function()
    Database:RestoreDB()
end)

Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    Database:ShowOutdatedDBWarning()
end)
