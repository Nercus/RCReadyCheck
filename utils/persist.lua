---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

---@alias RCReadyCheckDB table<string, table | number | string | boolean>



---save a variable to the saved variables
---@param ... string | number | boolean | table
function RCReadyCheck:SaveVar(...)
    if not RCReadyCheckDB then
        ---@type RCReadyCheckDB
        RCReadyCheckDB = {}
    end

    -- move all arguments into a table
    local arg = { ... }
    local value = arg[#arg] -- last argument is the value

    -- remove the last argument from the tables
    arg[#arg] = nil
    -- iterate table and create subtables if needed and on last iteration set the value
    ---@type table
    local currentTable = RCReadyCheckDB -- start at the root
    for index, key in ipairs(arg) do
        if index == #arg then
            break
        end
        if not currentTable[key] then
            currentTable[key] = {} ---@type table
        end
        currentTable = currentTable[key] ---@type table
    end
    if type(currentTable) ~= "table" then
        return
    end
    -- arg[#arg] is the last key
    currentTable[arg[#arg]] = value ---@type boolean | number | string | table
end

---get a variable from the saved variables
---@param ... string | number | boolean | table
---@return string | number | boolean | table | nil
function RCReadyCheck:GetVar(...)
    if not RCReadyCheckDB then
        ---@type RCReadyCheckDB
        RCReadyCheckDB = {}
    end

    -- move all arguments into a table
    local arg = { ... }

    ---@type table
    local dbTable = RCReadyCheckDB
    for index, key in ipairs(arg) do
        if index == #arg then
            return dbTable[key]
        end
        if not dbTable[key] then
            return nil
        end
        dbTable = dbTable[key] ---@type table
    end
end

---delete a variable from the saved variables
---@param ... string | number | boolean | table | nil
function RCReadyCheck:DeleteVar(...)
    if not RCReadyCheckDB then
        ---@type RCReadyCheckDB
        RCReadyCheckDB = {}
    end

    -- move all arguments into a table
    local arg = { ... }
    local dbTable = RCReadyCheckDB
    for index, key in ipairs(arg) do
        if index == #arg then
            dbTable[key] = nil ---@type nil
        end
        if not dbTable[key] then
            return
        end
        dbTable = dbTable[key] ---@type table
    end
end

function RCReadyCheck:MigrateVar(prevKeys, newKeys)
    if not RCReadyCheckDB then
        ---@type RCReadyCheckDB
        RCReadyCheckDB = {}
    end
    local prevValue = self:GetVar(type(prevKeys) == "table" and unpack(prevKeys) or prevKeys)
    if prevValue ~= nil then
        self:SaveVar(type(newKeys) == "table" and unpack(newKeys) or newKeys, prevValue)
        self:DeleteVar(type(prevKeys) == "table" and unpack(prevKeys) or prevKeys)
    end
end
