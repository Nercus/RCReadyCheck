---@class RCReadyCheck
local RCReadyCheck = select(2, ...)



---@class PopupOption
---@field text string
---@field onAccept function
---@field onCancel function?



---@class RCReadyCheckDialogFrame : Frame
---@field text FontString
---@field accept Button
---@field cancel? Button

local L = RCReadyCheck.L

---@type RCReadyCheckDialogFrame?
local dialogFrame = nil

---@return RCReadyCheckDialogFrame
local function GetPopupDialogFrame()
    if not dialogFrame then
        dialogFrame = CreateFrame("Frame", "RCReadyCheckPopupDialog", UIParent, "RCReadyCheckPopupDialogTemplate") --[[@as RCReadyCheckDialogFrame]]
    end
    return dialogFrame
end


local function GetFrameWidthByTextLength(textLength)
    if textLength < 50 then
        return 300
    elseif textLength < 100 then
        return 370
    elseif textLength < 150 then
        return 440
    elseif textLength < 200 then
        return 510
    end
end

---@type string
local acceptButtonText = L["Accept"]
---@type string
local cancelButtonText = L["Cancel"]

---@param options PopupOption
function RCReadyCheck:ShowPopup(options)
    assert(options.text, "The popup must have text")
    assert(options.onAccept, "The popup must have an onAccept function")
    local dialog = GetPopupDialogFrame()

    local function OnAccept()
        options.onAccept()
        dialog:Hide()
    end

    local function OnCancel()
        if options.onCancel then
            options.onCancel()
        end
        dialog:Hide()
    end

    local textLength = string.len(options.text)
    dialog:SetWidth(GetFrameWidthByTextLength(textLength))

    dialog:Show()
    dialog.text:SetText(options.text)
    dialog.accept:SetScript("OnClick", OnAccept)
    dialog.cancel:SetScript("OnClick", OnCancel)
    dialog.accept:SetText(acceptButtonText)
    dialog.cancel:SetText(cancelButtonText)

    local function OnInteract(_, key)
        if key == "ESCAPE" then
            OnCancel()
            dialog:SetPropagateKeyboardInput(false)
        elseif key == "ENTER" then
            OnAccept()
            dialog:SetPropagateKeyboardInput(false)
        else
            dialog:SetPropagateKeyboardInput(true)
        end
    end

    dialog:SetScript("OnKeyDown", OnInteract)
end
