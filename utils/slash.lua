---@diagnostic disable: global-element The slash command definition has to be global
---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
local L = RCReadyCheck.L

local commandList = {} ---@type table<string, function>
local commandHelpStrings = {} ---@type table<string, string>

SLASH_RCReadyCheck1 = "/rcrc"


local normalColor = CreateColor(1, 0.82, 0)
local SlashCmdList = getglobal("SlashCmdList") ---@as table<string, function>
local helpPattern = "|A:gearupdate-arrow-bullet-point:12:12:2:-2|a %s - %s"
function RCReadyCheck:PrintHelp()
    print(self:WrapTextInColor(self.nameVersionString, normalColor))
    for command, help in pairs(commandHelpStrings) do
        help = self:WrapTextInColor(help, normalColor)
        local helpString = helpPattern:format(command, help)
        print(helpString)
    end
end

---parse the full msg and split into the different arguments
---@param msg string
local function SlashCommandHandler(msg)
    local args = {} ---@type table<number, string>
    for word in string.gmatch(msg, "[^%s]+") do
        table.insert(args, word)
    end
    local command = args[1]
    if commandList[command] then
        pcall(commandList[command], unpack(args))
    else
        if msg == "" then
            RCReadyCheck:PrintHelp()
            return
        end
    end
end

SlashCmdList["RCReadyCheck"] = SlashCommandHandler

---Add a slash command to the list
---@param command string
---@param func function
---@param help string
function RCReadyCheck:AddSlashCommand(command, func, help)
    commandList[command] = func
    commandHelpStrings[command] = help
end

RCReadyCheck:AddSlashCommand(L["Help"]:lower(), function()
    RCReadyCheck:PrintHelp()
end, L["Show This Help Message"])
