---@class RDReadyCheckLootFrame : Frame
---@field voteText FontString
---@field noteText FontString
RDReadyCheckLootFrameMixin = {}


function RDReadyCheckLootFrameMixin:Update()
    self:ClearAllPoints()
    self:SetPoint("LEFT", self.entry.frame, "RIGHT", 5, 0)
    self.voteText:SetText("BiS")
    self.noteText:SetText(
        "Lorem ipsum dolor sit amet")
    self:Show()
end

function RDReadyCheckLootFrameMixin:SetEntry(entry)
    self.entry = entry
    self:Update()
end
