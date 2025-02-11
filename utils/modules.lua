---@class RCReadyCheck
---@field modules table<string, table>
local RCReadyCheck = select(2, ...)



---@alias ModuleName "ImportFrame" |  "VotingFrame" | "Database"

---@param name ModuleName
---@return table
function RCReadyCheck:CreateModule(name)
    local module = {
        name = name,
    } ---@type table
    if (not self.modules) then
        self.modules = {}
    end
    self.modules[name] = module
    return module
end

---@generic T
---@param name `T`
---@return T
function RCReadyCheck:GetModule(name)
    return self.modules[name]
end
