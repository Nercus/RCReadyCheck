---@class RCReadyCheck
local RCReadyCheck = select(2, ...)
local VotingFrame = RCReadyCheck:CreateModule("VotingFrame")
--- Holds all the constants for the addon

---@class RCVotingFrame : AceModule
local RCVotingFrame = RCReadyCheck.RC:GetModule("RCVotingFrame")


function RCVotingFrame:SetCellValue(frame, data, cols, row, realrow, column, fShow, table, ...)
    -- TODO: create a frame template that shows the readycheck selection and an optional button to show the note
    frame.text:SetText("BiS - I want that item")
    data[realrow].cols[column].value = "BiS - I want that item"
end

function RCVotingFrame:UpdateSortNext()
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
function RCVotingFrame:AddReadyCheckColumn()
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
        DoCellUpdate = RCVotingFrame.SetCellValue,
        colName = "readycheckio",
        width = 120,
    })

    RCVotingFrame:UpdateSortNext()
end

RCReadyCheck:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    RCVotingFrame:AddReadyCheckColumn()
end)
