---@diagnostic disable: no-unknown, undefined-field
---@type string
local AddOnName = ...

---@class RCReadyCheck : NercLibAddon
local RCReadyCheck = LibStub("NercLib"):GetAddon(AddOnName)
---@class VotingFrame
local VotingFrame = RCReadyCheck:GetModule("VotingFrame")
local Database = RCReadyCheck:GetModule("Database")
local Item = RCReadyCheck:GetModule("Item")
local Text = RCReadyCheck:GetModule("Text")

---@class RCVotingFrame : AceModule
local RCVotingFrame = RCReadyCheck.RC:GetModule("RCVotingFrame")

local session = 1

local RESPONSE_COLOR = {
    ["Best in slot"] = CreateColorFromHexString("FF0AFF00"),
    ["Catalyst"] = CreateColorFromHexString("FF00C29E"),
    ["Upgrade"] = CreateColorFromHexString("FFFF00ED"),
    ["Off Spec (raid)"] = CreateColorFromHexString("FFFF0073"),
    ["Tertiary / Non-Raid"] = CreateColorFromHexString("FF0042FF"),
    ["Transmog"] = CreateColorFromHexString("FFFFFFFF"),
}

---@param dateString string dateNow in the form of "YYYY/MM/DD"
---@return boolean | string formattedDateString returns "x days ago" if the date is older than 10 days, otherwise false
local function getFormattedDateString(dateString)
    local dateParts = { string.split("/", dateString) }
    local year = tonumber(dateParts[1])
    local month = tonumber(dateParts[2])
    local day = tonumber(dateParts[3])
    local dateNow = date("*t")

    local daysInMonth = {
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    }

    -- Adjust for leap year
    if (dateNow.year % 4 == 0 and dateNow.year % 100 ~= 0) or (dateNow.year % 400 == 0) then
        daysInMonth[2] = 29
    end

    local daysAgo = 0

    -- Calculate days difference within the same year
    if year == dateNow.year then
        if month == dateNow.month then
            daysAgo = dateNow.day - day
        else
            daysAgo = daysInMonth[month] - day + dateNow.day
            for m = month + 1, dateNow.month - 1 do
                daysAgo = daysAgo + daysInMonth[m]
            end
        end
    elseif year < dateNow.year then
        -- Calculate days difference across years
        daysAgo = daysInMonth[month] - day + dateNow.day
        for m = month + 1, 12 do
            daysAgo = daysAgo + daysInMonth[m]
        end
        for m = 1, dateNow.month - 1 do
            daysAgo = daysAgo + daysInMonth[m]
        end
        daysAgo = daysAgo + (dateNow.year - year - 1) * 365
    end

    if daysAgo < 10 then
        return daysAgo > 1 and string.format("%d days ago", daysAgo) or "1 day ago"
    else
        return false
    end
end


---@class HistoryEntry
---@field date string date in the form of "YYYY/MM/DD"
---@field note string? note for the item
---@field response string response of the player (e.g. "BiS - I want that item")
---@field lootWon string hyperlink of the item
---@field responseID string


local ALLOWED_RESPONSES = {
    [1] = true,
    [2] = true,
    [3] = true,
}

function VotingFrame:GetAwardedItemsForPlayer(playerName, realmName)
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
        if getFormattedDateString(entry.date) and type(entry.responseID) == 'number' and ALLOWED_RESPONSES[entry.responseID] then
            table.insert(awardedItems, {
                lootWon = entry.lootWon,
                response = entry.response,
                note = entry.note,
                date = getFormattedDateString(entry.date)
            })
        end
    end
    return awardedItems
end

local iconNote = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/Note.png")
local iconUpgrade = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/ArrowUp.png")
local iconDowngrade = string.format("|T%s:12:12|t", "Interface/AddOns/RCReadyCheck/assets/ArrowDown.png")

---@param entry HistoryEntry
---@return string
local function GetAwardedItemString(entry)
    local difficultyName
    local difficultyID = Item:GetItemDifficultyID(entry.lootWon)
    if difficultyID then
        difficultyName = GetDifficultyInfo(difficultyID)
    end
    return string.format("- %s %s %s %s (%s)", difficultyName or "", entry.lootWon or "", entry.response or "",
        entry.note or "", entry.date)
end

---@param characterName string name of the character
local function AddAwardedItemsToTooltip(characterName)
    local awardedItems = VotingFrame:GetAwardedItemsForPlayer(characterName)
    if #awardedItems > 0 then
        local header = string.format("Awarded %d Item%s last 10 days:", #awardedItems,
            ((#awardedItems > 1) and "s" or ""))
        GameTooltip:AddLine(CreateAtlasMarkup("RecipeList-Divider", 272, 6))
        GameTooltip:AddLine(header)
        for _, entry in ipairs(awardedItems) do
            GameTooltip:AddLine(GetAwardedItemString(entry))
        end
    else
        GameTooltip:AddLine("No items awarded in the last 10 days.")
    end
end

function VotingFrame:UpdateVotingFrameEntry(frame, characterName, lootEntry)
    if not lootEntry then
        frame.text:SetText("-")
        frame:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
            AddAwardedItemsToTooltip(characterName)
            GameTooltip:Show()
        end)
        return
    end

    local upgradeIcon = (lootEntry.absoluteGain and
        (lootEntry.absoluteGain > 0 and iconUpgrade or iconDowngrade)) or ""
    local relativeGain = (lootEntry.relativeGain and string.format("(%.2f%%)", lootEntry.relativeGain * 100)) or ""
    local noteIcon = (lootEntry.note and string.format("[%s]", iconNote)) or ""
    local frameText = string.format("%s %s %s %s", upgradeIcon, lootEntry.selection, relativeGain, noteIcon)
    local color = RESPONSE_COLOR[lootEntry.selection] or RESPONSE_COLOR["Transmog"]
    frameText = Text:WrapTextInColor(frameText, color)
    frame.text:SetText(frameText)

    frame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
        GameTooltip:AddLine(lootEntry.selection)
        if lootEntry.note then
            GameTooltip:AddLine(string.format("%s Note: %s", iconNote, lootEntry.note))
        end
        if lootEntry.absoluteGain then
            GameTooltip:AddLine(string.format("%s Absolute Gain: %s", upgradeIcon,
                AbbreviateNumbers(lootEntry.absoluteGain)))
        end
        if lootEntry.relativeGain then
            GameTooltip:AddLine(string.format("%s Relative Gain: %.2f%%", upgradeIcon, lootEntry.relativeGain * 100))
        end
        AddAwardedItemsToTooltip(characterName)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
end

function VotingFrame:SetCellValue(frame, data, _, _, realrow, column)
    ---@type table <string, any>
    local lootTable = RCReadyCheck.RC:GetLootTable()
    if lootTable and lootTable[session] then
        local dataEntry = Database:GetEntry(data[realrow].name, lootTable[session].itemID)
        if not dataEntry then
            VotingFrame:UpdateVotingFrameEntry(frame, data[realrow].name)
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

    table.insert(RCVotingFrame.scrollCols, {
        name = "Readycheck.io",
        DoCellUpdate = VotingFrame.SetCellValue,
        colName = "readycheckio",
        width = 200,
    })

    self:UpdateSortNext()
    added = true
end

local Utils = RCReadyCheck:GetModule("Utils")
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
