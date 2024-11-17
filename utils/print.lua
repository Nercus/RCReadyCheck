---@class RCReadyCheck
local RCReadyCheck = select(2, ...)


local defaultColor = CreateColor(0.517, 0.458, 0.662)
local prefix = RCReadyCheck:WrapTextInColor(RCReadyCheck.addonName .. ": ", defaultColor)


---Print a styled message to the chat
---@param ... string
function RCReadyCheck:Print(...)
    local str = select(1, ...)
    local args = select(2, ...)
    if args then
        str = string.format(str, args) ---@type string
    end
    print(prefix .. str)
end
