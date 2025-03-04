---@diagnostic disable: no-unknown, undefined-field
---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):GetAddon(AddOnName)
---@class VotingFrame
local VotingFrame = RCReadyCheck:GetModule("VotingFrame")
local Database = RCReadyCheck:GetModule("Database")

---@class RCVotingFrame : AceModule
local RCVotingFrame = RCReadyCheck.RC:GetModule("RCVotingFrame")

local session = 1

---@type table<number, DIFFICULTY>
local difficultyTable = {
    [4] = "NORMAL",
    [5] = "HEROIC",
    [6] = "MYTHIC",
}


---@class HistoryEntry
---@field date string date in the form of "YYYY/MM/DD"
---@field difficultyID number difficulty of the raid
---@field note string? note for the item
---@field response string response of the player (e.g. "BiS - I want that item")
---@field lootWon string hyperlink of the item

function VotingFrame:GetTodayAwardedItemsForPlayer(playerName, realmName)
    local awardedItems = {}
    ---@type table<string, HistoryEntry>
    local historyDB = RCReadyCheck.RC:GetHistoryDB()
    if not historyDB then return awardedItems end
    ---@type string
    local key = playerName
    if (realmName) then
        key = playerName .. "-" .. realmName --[[@as string]]
    end
    local historyDBEntry = historyDB[key]
    if not historyDBEntry then return awardedItems end
    for _, entry in ipairs(historyDBEntry) do
        if entry.date == date("%Y/%m/%d") then
            table.insert(awardedItems, entry)
        end
    end
    return awardedItems
end

local iconNote = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/Note.png")
local iconUpgrade = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/ArrowUp.png")
local iconDowngrade = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/ArrowDown.png")

---@param frame Frame
---@param characterName? string
---@param lootEntry? ImportDataEntry
function VotingFrame:UpdateVotingFrameEntry(frame, characterName, lootEntry)
    if not lootEntry then
        frame.text:SetText("-")
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            local awardedItems = VotingFrame:GetTodayAwardedItemsForPlayer(characterName)
            if #awardedItems > 0 then
                -- add a separator line if there are awarded items
                GameTooltip:AddLine("--------------")
                GameTooltip:AddLine("Awarded Items:")
                for _, entry in ipairs(awardedItems) do
                    local difficultyName = GetDifficultyInfo(entry.difficultyID)
                    GameTooltip:AddLine(string.format("(%s) %s - %s - %s", difficultyName, entry.lootWon, entry.response,
                        entry.note or ""))
                end
            end
            GameTooltip:Show()
        end)
        return
    end


    local upgradeIcon = (lootEntry.absoluteGain and (lootEntry.absoluteGain > 0 and iconUpgrade or iconDowngrade)) or ""
    local relativeGain = (lootEntry.relativeGain and string.format("(%.2f%%)", lootEntry.relativeGain * 100)) or ""
    local noteIcon = (lootEntry.note and string.format("[%s]", iconNote)) or ""
    local frameText = string.format("%s %s %s %s", upgradeIcon, lootEntry.selection, relativeGain, noteIcon)
    frame.text:SetText(frameText)

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddLine(lootEntry.selection)
        if lootEntry.note then
            GameTooltip:AddLine(string.format("%s Note: %s", iconNote, lootEntry.note))
        end
        if lootEntry.absoluteGain then
            GameTooltip:AddLine(string.format("%s Absolute Gain: %s", upgradeIcon, lootEntry.absoluteGain))
        end
        if lootEntry.relativeGain then
            GameTooltip:AddLine(string.format("%s Relative Gain: %.2f%%", upgradeIcon, lootEntry.relativeGain * 100))
        end
        local awardedItems = VotingFrame:GetTodayAwardedItemsForPlayer(lootEntry.characterName, lootEntry.characterRealm)
        if #awardedItems > 0 then
            -- add a separator line if there are awarded items
            GameTooltip:AddLine("--------------")
            GameTooltip:AddLine("Awarded Items:")
            for _, entry in ipairs(awardedItems) do
                local difficultyName = GetDifficultyInfo(entry.difficultyID)
                GameTooltip:AddLine(string.format("(%s) %s - %s - %s", difficultyName, entry.lootWon, entry.response,
                    entry.note or ""))
            end
        end
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function VotingFrame:SetCellValue(frame, data, cols, row, realrow, column, fShow, table, ...)
    ---@type table <string, any>
    local lootTable = RCReadyCheck.RC:GetLootTable()
    if lootTable and lootTable[session] then
        local itemLink = lootTable[session].link
        -- generate a table from the itemlink by splitting on :
        local itemTable = { strsplit(":", itemLink) }
        local difficulty = difficultyTable[tonumber(itemTable[13])]
        if (not difficulty) then
            VotingFrame:UpdateVotingFrameEntry(frame)
            return
        end
        local dataEntry = Database:GetEntry(data[realrow].name, difficulty, lootTable[session].itemID)
        if not dataEntry then
            VotingFrame:UpdateVotingFrameEntry(frame)
            return
        end
        VotingFrame:UpdateVotingFrameEntry(frame, data[realrow].name, dataEntry)
    end
    data[realrow].cols[column].value = "BiS - I want that item"
end

function VotingFrame:UpdateSortNext()
    for index in ipairs(RCVotingFrame.scrollCols) do
        if RCVotingFrame.scrollCols[index].sortnext then
            local exists = RCVotingFrame:GetColumnIndexFromName(self.sortnext[RCVotingFrame.scrollCols[index].colName])
            RCVotingFrame.scrollCols[index].sortnext = exists
        end
    end

    local frame = RCVotingFrame:GetFrame()
    if frame then
        frame.st:SetDisplayCols(RCVotingFrame.scrollCols)
        frame:SetWidth(frame.st.frame:GetWidth() + 20)
    end
end

local retries = 0
local added = false
function VotingFrame:AddReadyCheckColumn()
    if added then return end
    if not RCVotingFrame.scrollCols and retries < 10 then
        C_Timer.After(0.1, function()
            RCVotingFrame:AddReadyCheckColumn()
        end)
        retries = retries + 1
        return
    end

    -- Translate sortnext into colNames (copied from RCLootCouncil_ExtraUtilities)
    self.sortnext = {}
    for _, v in ipairs(RCVotingFrame.scrollCols) do
        if v.sortnext then
            self.sortnext[v.colName] = RCVotingFrame.scrollCols[v.sortnext].colName
        end
    end

    tinsert(RCVotingFrame.scrollCols, {
        name = "Readycheck.io",
        DoCellUpdate = VotingFrame.SetCellValue,
        colName = "readycheckio",
        width = 200,
    })

    self:UpdateSortNext()
    added = true
end

local Utils = RCReadyCheck:GetModule("Utils")
local Database = RCReadyCheck:GetModule("Database")
local debouncedOutdateWarning = Utils:DebounceChange(function()
    Database:ShowOutdatedDBWarning()
end, 1)

function VotingFrame:OnMessageReceived(msg, ...)
    if msg == "RCSessionChangedPre" then
        local s = unpack({ ... })
        session = s
    end
    debouncedOutdateWarning()
end

local Events = RCReadyCheck:GetModule("Events")
Events:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    VotingFrame:AddReadyCheckColumn()
end)

RCReadyCheck.RC:RegisterMessage("RCSessionChangedPre", function(msg, ...)
    VotingFrame:OnMessageReceived(msg, ...)
end)
