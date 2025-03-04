---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):GetAddon(AddOnName)

---@class Database
---@field db table<string, table<DIFFICULTY, table<number, ImportDataEntry>>>
local Database = RCReadyCheck:GetModule("Database")
local SavedVars = RCReadyCheck:GetModule("SavedVars")
local Events = RCReadyCheck:GetModule("Events")
local Text = RCReadyCheck:GetModule("Text")

Database.db = {}

---@alias DIFFICULTY "NORMAL" | "HEROIC" | "MYTHIC"

---@class ImportDataEntry
---@field wowItemId? string
---@field characterName? string
---@field characterRealm? string
---@field difficulty? DIFFICULTY
---@field selection? string
---@field absoluteGain? number
---@field relativeGain? number
---@field note? string


local REQUIRED_FIELDS = {
    "wowItemId",
    "characterName",
    "difficulty",
    "selection",
}

---@param entry ImportDataEntry
function Database:SetDataEntry(entry)
    for _, field in ipairs(REQUIRED_FIELDS) do
        if not entry[field] then
            error("Missing required field: " .. field)
        end
    end
    local key = entry.characterName .. "-" .. entry.characterRealm
    self.db[key] = self.db[key] or {}

    local itemKey = tonumber(entry.wowItemId)
    if not itemKey then
        error("Invalid wowItemId: " .. entry.wowItemId)
    end

    local difficultyKey = entry.difficulty
    if difficultyKey then
        self.db[key][difficultyKey] = self.db[key][difficultyKey] or {}
        self.db[key][difficultyKey][itemKey] = entry
    end
end

---@param data ImportDataEntry[]
function Database:SetBulkData(data)
    self.db = {}
    for _, entry in ipairs(data) do
        self:SetDataEntry(entry)
    end
    SavedVars:SetVar("importedData", self.db)
    SavedVars:SetVar("lastImport", time())
end

function Database:GetEntry(characterName, difficulty, wowItemId)
    assert(characterName, "characterName is required")
    assert(difficulty, "difficulty is required")
    assert(wowItemId, "wowItemId is required")
    ---@type string
    local key = characterName
    if not self.db[key] then
        return nil
    end
    if not self.db[key][difficulty] then
        return nil
    end
    return self.db[key][difficulty][wowItemId]
end

function Database:RestoreDB()
    local db = SavedVars:GetVar("importedData")
    if db then
        self.db = db --[[@as table]]
    end
end

function Database:ShowOutdatedDBWarning()
    local lastImport = SavedVars:GetVar("lastImport")
    if not lastImport then
        return
    end
    local diff = time() - lastImport
    if diff > 1 then
        Text:Print(Text:WrapTextInColor("The imported data is outdated. Please import new data.", ERROR_COLOR))
        UIErrorsFrame:AddMessage("The imported data is outdated. Please import new data.", ERROR_COLOR.r, ERROR_COLOR.g,
            ERROR_COLOR.b)
    end
end

Events:RegisterEvent("PLAYER_LOGIN", function()
    Database:RestoreDB()
end)

Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    Database:ShowOutdatedDBWarning()
end)
