---@class RCReadyCheck
local RCReadyCheck = select(2, ...)

-- DEFAULTS is a table that stores the default values for various settings.
local DEFAULTS = {
}

---Retrieves the default value for a given set of keys.
---@param ... string A variable number of arguments representing the keys to traverse the DEFAULTS table.
---@return table|number|boolean|string|nil The default value corresponding to the provided keys, or nil if the keys do not exist.
function RCReadyCheck:GetDefault(...)
    local arg = { ... }
    local currentTable = DEFAULTS
    for index, key in ipairs(arg) do
        if index == #arg then -- last key
            if currentTable[key] == nil then
                assert(false, "Key does not exist in DEFAULTS table: " .. table.concat(arg, ".", 1, #arg - 1))
            end
            return currentTable[key]
        end
        if currentTable[key] == nil then
            assert(false, "Key does not exist in DEFAULTS table: " .. table.concat(arg, ".", 1, #arg - 1))
        end
        currentTable = currentTable[key] --[[@as table]]
    end
end
