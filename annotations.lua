---@meta


---@type RCReadyCheckDB
RCReadyCheckDB = {}

---@type table<string, table>
StaticPopupDialogs = {}
---@param dialogName string
function StaticPopup_Show(dialogName) end

---@class BaseMenuDescriptionMixin
BaseMenuDescriptionMixin = {}

---@param initializer fun(frame: Frame, elementDescription: BaseMenuDescriptionMixin, menu: BaseMenuDescriptionMixin)
---@param index number?
function BaseMenuDescriptionMixin:AddInitializer(initializer, index) end

---@param isRadio boolean
function BaseMenuDescriptionMixin:SetRadio(isRadio) end

---@return boolean
function BaseMenuDescriptionMixin:IsSelected() end

---@return boolean
function BaseMenuDescriptionMixin:SetIsSelected() end

function BaseMenuDescriptionMixin:SetSelectionIgnored() end

---@param soundKit number
function BaseMenuDescriptionMixin:SetSoundKit(soundKit) end

---@param onEnter fun()
function BaseMenuDescriptionMixin:SetOnEnter(onEnter) end

---@param onLeave fun()
function BaseMenuDescriptionMixin:SetOnLeave(onLeave) end

---@param isEnabled boolean
function BaseMenuDescriptionMixin:SetEnabled(isEnabled) end

---@return boolean
function BaseMenuDescriptionMixin:IsEnabled() end

---@param data table
function BaseMenuDescriptionMixin:SetData(data) end

---@param callback fun(data:table,menuInputData:table, menu: BaseMenuDescriptionMixin):integer
function BaseMenuDescriptionMixin:SetResponder(callback) end

---@param response MenuResponse
function BaseMenuDescriptionMixin:SetResponse(response) end

---@param tooltip fun()
function BaseMenuDescriptionMixin:SetTooltip(tooltip) end

---@param inputContext integer
---@param buttonName string
function BaseMenuDescriptionMixin:Pick(inputContext, buttonName) end

MenuConstants =
{
    VerticalLinearDirection = 1,
    VerticalGridDirection = 2,
    HorizontalGridDirection = 3,
    AutoCalculateColumns = nil,
    ElementPollFrequencySeconds = .2,
    PrintSecure = false,
};

--[[
Response values are optional returns from description handlers to inform the menu
structure to remain open, reinitialize all the children, or only close the leafmost menu.
It is common for menus with checkboxes or radio options to return Refresh in order for
the children to visually update.
--]]
---@class MenuResponse
MenuResponse =
{
    Open = 1,     -- Menu remains open and unchanged
    Refresh = 2,  -- All frames in the menu are reinitialized
    Close = 3,    -- Parent menus remain open but this menu closes
    CloseAll = 4, -- All menus close
};


---@class MenuUtil
MenuUtil = {}

function MenuUtil.TraverseMenu(elementDescription, op, condition) end

function MenuUtil.GetSelections(elementDescription, condition) end

function MenuUtil.ShowTooltip(owner, func, ...) end

function MenuUtil.HideTooltip(owner) end

function MenuUtil.HookTooltipScripts(owner, func) end

function MenuUtil.CreateRootMenuDescription(menuMixin) end

function MenuUtil.CreateContextMenu(ownerRegion, generator, ...) end

function MenuUtil.SetElementText(elementDescription, text) end

function MenuUtil.GetElementText(elementDescription) end

function MenuUtil.CreateFrame() end

function MenuUtil.CreateTemplate(template) end

function MenuUtil.CreateTitle(text, color) end

function MenuUtil.CreateButton(text, callback, data) end

function MenuUtil.CreateCheckbox(text, isSelected, setSelected, data) end

function MenuUtil.CreateRadio(text, isSelected, setSelected, data) end

function MenuUtil.CreateColorSwatch(text, callback, colorInfo) end

function MenuUtil.CreateButtonMenu(dropdown, ...) end

function MenuUtil.CreateButtonContextMenu(ownerRegion, ...) end

function MenuUtil.CreateCheckboxMenu(dropdown, isSelected, setSelected, ...) end

function MenuUtil.CreateCheckboxContextMenu(ownerRegion, isSelected, setSelected, ...) end

function MenuUtil.CreateRadioMenu(dropdown, isSelected, setSelected, ...) end

function MenuUtil.CreateRadioContextMenu(ownerRegion, isSelected, setSelected, ...) end

function MenuUtil.CreateEnumRadioMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end

function MenuUtil.CreateEnumRadioContextMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end

function MenuUtil.CreateDivider() end

function MenuUtil.CreateSpacer() end

---@class SubMenuUtil
SubMenuUtil = {}

function SubMenuUtil:TraverseMenu(elementDescription, op, condition) end

function SubMenuUtil:GetSelections(elementDescription, condition) end

function SubMenuUtil:ShowTooltip(owner, func, ...) end

function SubMenuUtil:HideTooltip(owner) end

function SubMenuUtil:HookTooltipScripts(owner, func) end

function SubMenuUtil:CreateRootMenuDescription(menuMixin) end

function SubMenuUtil:CreateContextMenu(ownerRegion, generator, ...) end

function SubMenuUtil:SetElementText(elementDescription, text) end

function SubMenuUtil:GetElementText(elementDescription) end

function SubMenuUtil:CreateFrame() end

function SubMenuUtil:CreateTemplate(template) end

function SubMenuUtil:CreateTitle(text, color) end

function SubMenuUtil:CreateButton(text, callback, data) end

function SubMenuUtil:CreateCheckbox(text, isSelected, setSelected, data) end

function SubMenuUtil:CreateRadio(text, isSelected, setSelected, data) end

function SubMenuUtil:CreateColorSwatch(text, callback, colorInfo) end

function SubMenuUtil:CreateButtonMenu(dropdown, ...) end

function SubMenuUtil:CreateButtonContextMenu(ownerRegion, ...) end

function SubMenuUtil:CreateCheckboxMenu(dropdown, isSelected, setSelected, ...) end

function SubMenuUtil:CreateCheckboxContextMenu(ownerRegion, isSelected, setSelected, ...) end

function SubMenuUtil:CreateRadioMenu(dropdown, isSelected, setSelected, ...) end

function SubMenuUtil:CreateRadioContextMenu(ownerRegion, isSelected, setSelected, ...) end

function SubMenuUtil:CreateEnumRadioMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end

function SubMenuUtil:CreateEnumRadioContextMenu(dropdown, enum, enumTranslator, isSelected, setSelected, orderTbl) end

function SubMenuUtil:CreateDivider() end

function SubMenuUtil:CreateSpacer() end

---@param frameType string
---@param parent string?
---@param frameTemplate string?
---@param resetterFunc fun()?
---@param forbidden boolean?
---@return FramePool
function CreateFramePool(frameType, parent, frameTemplate, resetterFunc, forbidden) end

---@class FramePool
local FramePool = {}
---@return string
function FramePool:GetTemplate() end

---@return Frame
function FramePool:Acquire() end

---@param obj Frame
---@return boolean success
function FramePool:Release(obj) end

function FramePool:ReleaseAll() end

function FramePool:EnumerateActive() end
