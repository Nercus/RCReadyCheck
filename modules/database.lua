---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
---@class Database
---@field db table<string, table<DIFFICULTY, table<number, ImportDataEntry>>>
local Database = RCReadyCheck:CreateModule("Database")

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
    RCReadyCheck:SaveVar("importedData", self.db)
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
    local db = RCReadyCheck:GetVar("importedData")
    if db then
        self.db = db --[[@as table]]
    end
end

RCReadyCheck:RegisterEvent("PLAYER_LOGIN", function()
    Database:RestoreDB()
end)
