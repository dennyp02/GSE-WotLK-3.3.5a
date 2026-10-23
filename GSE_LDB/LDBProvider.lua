local GSE = GSE

local Statics = GSE.Static
local L = GSE.L

local ldb = LibStub:GetLibrary("LibDataBroker-1.1")
local dataobj = ldb:NewDataObject(L["GSE"] .." ".. L["GnomeSequencer-Enhanced"], {
  type = "data source",
  text = "GSE",
  icon = "Interface\\AddOns\\GSE\\Media\\GSE_Icon",
  OnLeave = dataObject_OnLeave
})

-- LibDBIcon minimap button (position/hide persisted in GSEOptions.minimap)
local LibDBIcon = LibStub("LibDBIcon-1.0", true)
if LibDBIcon then
  GSEOptions.minimap = GSEOptions.minimap or { hide = false }
  if GSEOptions.minimap.hide == nil then GSEOptions.minimap.hide = false end
  LibDBIcon:Register("GSE", dataobj, GSEOptions.minimap)
end
local LibQTip = LibStub('LibQTip-1.0')
local LibSharedMedia = LibStub('LibSharedMedia-3.0')

local baseFont = CreateFont("baseFont")

-- CHeck for ElvUI
if GSE.isEmpty(ElvUI) then
  baseFont:SetFont(GameTooltipText:GetFont(), 10)
elseif LibSharedMedia:IsValid('font', ElvUI[1].db.general.font) then
  baseFont:SetFont(LibSharedMedia:Fetch('font', ElvUI[1].db.general.font), 10)
else
  baseFont:SetFont(GameTooltipText:GetFont(), 10)
end

function dataobj:OnEnter()
  -- Acquire a tooltip with 3 columns, respectively aligned to left, center and right
  --local tooltip = LibQTip:Acquire("GSSE", 3, "LEFT", "CENTER", "RIGHT")
  local tooltip = LibQTip:Acquire("GSSE", 3, "LEFT", "CENTER", "RIGHT")
  self.tooltip = tooltip

  tooltip:Clear()
  tooltip:SetFont(baseFont)
  --tooltip:SetHeaderFont(red17font)
  local y,x = tooltip:AddLine()
  tooltip:SetCell(y, 1, L["GSE: Left Click to open the Sequence Editor"],"CENTER", 3)
  y,x = tooltip:AddLine()
  tooltip:SetCell(y, 1, L["GSE: Middle Click to open the Transmission Interface"],"CENTER", 3)
  y,x = tooltip:AddLine()
  tooltip:SetCell(y, 1, L["GSE: Right Click to open the GSE menu"],"CENTER", 3)

  -- If in party add other users and their versions
  if not GSE.isEmpty(GSE.UnsavedOptions["PartyUsers"]) and GSEOptions.showGSEUsers then
    tooltip:AddSeparator()
    y,x = tooltip:AddLine()
    tooltip:SetCell(y,1,L["GSE Users"],"CENTER", 3)
    for k,v in pairs(GSE.UnsavedOptions["PartyUsers"]) do
      tooltip:AddLine(k, nil, v)
    end
  end


  -- Show GSE OOCQueue Information
  if GSEOptions.showGSEoocqueue then
    tooltip:AddSeparator()
    y,x = tooltip:AddLine()
    tooltip:SetCell(y, 1, string.format(L["The GSE Out of Combat queue is %s"], GSE.CheckOOCQueueStatus()),"CENTER", 3)
    local OOCStatusline = y
    tooltip:SetLineScript(y, "OnMouseDown", function(obj, button)
      GSE.ToggleOOCQueue()
      tooltip:SetCell(OOCStatusline, 1, string.format(L["The GSE Out of Combat queue is %s"], GSE.CheckOOCQueueStatus()),"CENTER", 3)
    end)
    tooltip:AddSeparator()
    y,x = tooltip:AddLine()
    if table.getn(GSE.OOCQueue) > 0 then
      tooltip:SetCell(y, 1, string.format(L["There are %i events in out of combat queue"], table.getn(GSE.OOCQueue)),"CENTER", 3)
      for k,v in ipairs(GSE.OOCQueue) do
        y,x = tooltip:AddLine()
        GSE.prepareTooltipOOCLine(tooltip, v, y, k)
      end
    else
      -- No Items
      tooltip:SetCell(y, 1, string.format(L["There are no events in out of combat queue"]),"CENTER", 3)
    end
  end

  tooltip:AddSeparator()
  y,x = tooltip:AddLine()
  tooltip:SetCell(y, 1, string.format(L["GSE Version: %s"], GSE.formatModVersion(GSE.VersionString)),"CENTER", 3)
  -- Use smart anchoring code to anchor the tooltip to our frame
  tooltip:SmartAnchorTo(self)


  -- Show it, et voil� !
  tooltip:Show()
end

local function dataObject_OnLeave(self)
  -- Dont close the tooltip if mouseover
  if not MouseIsOver(self.tooltip) then
    -- Release the tooltip
    LibQTip:Release(self.tooltip)
    self.tooltip = nil
  end
end


function dataobj:OnLeave()
  dataObject_OnLeave(self)
end

local minimapMenuFrame = CreateFrame("Frame", "GSE_MinimapMenu", UIParent, "UIDropDownMenuTemplate")

local minimapMenuDivider = {
  hasArrow = false,
  dist = 0,
  isTitle = true,
  isUninteractable = true,
  notCheckable = true,
  iconOnly = true,
  isSeparator = true,
  icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
  tCoordLeft = 0,
  tCoordRight = 1,
  tCoordTop = 0,
  tCoordBottom = 1,
  tSizeX = 0,
  tSizeY = 8,
  tFitDropDownSizeX = true,
  text = "",
  iconInfo = {
    tCoordLeft = 0,
    tCoordRight = 1,
    tCoordTop = 0,
    tCoordBottom = 1,
    tSizeX = 0,
    tSizeY = 8,
    tFitDropDownSizeX = true
  },
}

local function ShowGSEMinimapMenu()
  local classid = GSE.GetCurrentClassID()
  local exportEntries = {}
  local classSequences = GSELibrary and GSELibrary[classid]
  if classSequences then
    for name, sequence in pairs(classSequences) do
      if type(sequence) == "table" and sequence.SequenceName then
        local sequenceName = name
        table.insert(exportEntries, {
          text = sequenceName,
          notCheckable = true,
          func = function() GSE.GUIExportSequence(classid, sequenceName) end
        })
      end
    end
    table.sort(exportEntries, function(a, b) return a.text < b.text end)
  end
  if #exportEntries == 0 then
    exportEntries = { { text = L["No sequences available"], disabled = true, notCheckable = true } }
  end

  local menu = {
    { text = L["Open Sequence Viewer"], notCheckable = true, func = function() GSE.GUIShowViewer() end },
    { text = L["Current Specialisation"], notCheckable = true, func = function() GSE:GSSlash("showspec") end },
    minimapMenuDivider,
    { text = L["Maintenance"], notCheckable = true, hasArrow = true, menuList = {
      { text = L["Repair Saved Data"], notCheckable = true, func = function() GSE:GSSlash("repair") end },
      { text = L["Clean Orphaned Macros"], notCheckable = true, func = function() GSE:GSSlash("cleanorphans") end },
      { text = L["Force Clean"], notCheckable = true, func = function() GSE:GSSlash("forceclean") end },
      { text = L["Check Macros For Errors"], notCheckable = true, func = function() GSE:GSSlash("checkmacrosforerrors") end },
      { text = L["Move Lost Macros"], notCheckable = true, func = function() GSE:GSSlash("movelostmacros") end },
      { text = L["Compile Missing Spells"], notCheckable = true, func = function() GSE:GSSlash("compilemissingspells") end },
    } },
    { text = L["Tools"], notCheckable = true, hasArrow = true, menuList = {
      { text = L["Sequence Debugger"], notCheckable = true, func = function() GSE:GSSlash("debug") end },
      { text = L["Show Debug Output"], notCheckable = true, func = function() GSE:GSSlash("showdebugoutput") end },
      { text = L["Record Macro"], notCheckable = true, func = function() GSE:GSSlash("record") end },
      { text = L["Compress Sequence String"], notCheckable = true, func = function() GSE:GSSlash("compressstring") end },
      { text = L["Update Macro Strings"], notCheckable = true, func = function() GSE:GSSlash("updatemacrostrings") end },
      { text = L["Reset Options"], notCheckable = true, func = function() GSE:GSSlash("resetoptions") end },
    } },
    { text = L["Export Sequence"], notCheckable = true, hasArrow = true, menuList = exportEntries },
    { text = L["Load Sample Macros"], notCheckable = true, func = function() GSE:GSSlash("loadsamples") end },
    minimapMenuDivider,
    { text = L["Options"], notCheckable = true, func = function()
      if GSE.OptionsPanel then
        InterfaceOptionsFrame_OpenToCategory(GSE.OptionsPanel)
        InterfaceOptionsFrame_OpenToCategory(GSE.OptionsPanel)
      end
    end },
    { text = L["Help"], notCheckable = true, func = function() GSE:GSSlash("help") end },
    { text = L["Hide Minimap Button"], notCheckable = true, func = function()
      GSEOptions.minimap.hide = true
      LibDBIcon:Hide("GSE")
    end },
  }

  EasyMenu(menu, minimapMenuFrame, "cursor", 0, 0, "MENU", 2)
end

function dataobj:OnClick(button)
  if button == "LeftButton" then
    GSE.GUIShowViewer()
  elseif button == "MiddleButton" then
    GSE.GUIShowTransmissionGui()
  elseif button == "RightButton" then
    ShowGSEMinimapMenu()
  end
end
