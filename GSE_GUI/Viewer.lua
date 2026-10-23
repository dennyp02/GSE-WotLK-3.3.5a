local GNOME,_ = ...

local GSE = GSE
local Statics = GSE.Static

local AceGUI = LibStub("GSE-AceGUI-3.0")
local L = GSE.L
local libS = LibStub:GetLibrary("AceSerializer-3.0")
local libC = LibStub:GetLibrary("LibCompress")
local libCE = libC:GetAddonEncodeTable()
local editkey = ""


local viewframe = AceGUI:Create("Frame")
viewframe:SetTitle(L["Sequence Viewer"])


GSE.GUIViewFrame = viewframe

viewframe:Hide()
local sequenceboxtext = AceGUI:Create("MultiLineEditBox")
local remotesequenceboxtext = AceGUI:Create("MultiLineEditBox")

viewframe.panels = {}
viewframe.SequenceName = ""
viewframe.ClassID = 0
viewframe.SearchText = ""

-- Set maximum resize bounds based on screen size
local maxHeight = GetScreenHeight() - 40
local maxWidth = GetScreenWidth() - 40
viewframe.frame:SetMaxResize(maxWidth, maxHeight)
viewframe.frame:SetMinResize(700, 450)

-- Keep the viewer content sized via AceGUI's own size callbacks.
viewframe.frame:SetClampedToScreen(true)

local origViewerOnWidthSet = viewframe.OnWidthSet
viewframe.OnWidthSet = function(self, width)
  if origViewerOnWidthSet then origViewerOnWidthSet(self, width) end
  if GSE.RelayoutViewer then GSE.RelayoutViewer() end
end
local origViewerOnHeightSet = viewframe.OnHeightSet
viewframe.OnHeightSet = function(self, height)
  if origViewerOnHeightSet then origViewerOnHeightSet(self, height) end
  if GSE.RelayoutViewer then GSE.RelayoutViewer() end
end

function GSE.RelayoutViewer()
  local frame = GSE.GUIViewFrame
  if not frame or not frame.content or not frame.viewScrollContainer then return end
  frame:DoLayout()
  local contentHeight = frame.content:GetHeight() or 0
  if contentHeight <= 0 then return end
  local toolbarHeight = (frame.viewToolbar and frame.viewToolbar.frame and frame.viewToolbar.frame:GetHeight()) or 30
  local searchHeight = (frame.viewSearchGroup and frame.viewSearchGroup.frame and frame.viewSearchGroup.frame:GetHeight()) or 0
  local scrollHeight = math.max(120, contentHeight - toolbarHeight - searchHeight - 24)
  frame.viewScrollContainer:SetHeight(scrollHeight)
  frame:DoLayout()
end

function viewframe:clearpanels(widget, selected)
  GSE.PrintDebugMessage("widget = " .. widget:GetKey(), "GUI")
  for k,v in pairs(viewframe.panels) do
    GSE.PrintDebugMessage("k " .. k, "GUI")
    if k == widget:GetKey() then
      GSE.PrintDebugMessage ("matching key", "GUI")
      local elements = GSE.split(widget:GetKey(), ",")
      if selected then
        viewframe.ClassID = elements[1]
        viewframe.SequenceName = elements[2]
        viewframe.EditButton:SetDisabled(false)
        viewframe.ExportButton:SetDisabled(false)
        if viewframe.SendButton then viewframe.SendButton:SetDisabled(false) end
        editkey = k
      else
        viewframe.ClassID = 0
        viewframe.SequenceName = ""
        viewframe.EditButton:SetDisabled(true)
        viewframe.ExportButton:SetDisabled(true)
        if viewframe.SendButton then viewframe.SendButton:SetDisabled(true) end
        editkey = ""
      end

      viewframe.panels[k]:SetClicked(true)
    else
      GSE.PrintDebugMessage ("other widget key", "GUI")
      GSE.PrintDebugMessage("reprinting k " .. k, "GUI")
      local wid = viewframe.panels[k]
      wid:SetClicked(false)
    end
  end

  GSE.GUIConfigureMacroButton(viewframe.MacroIconButton)

end

local function GetSequenceClassColor(classid)
  local classname = Statics.wotlkClassIDList[classid]
  local colors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
  local color = classname and colors and colors[string.upper(classname)]
  if color then
    return color.r, color.g, color.b
  end
  return 1, 0.82, 0
end

function GSE.GUICreateSequencePanels(frame, container, key)
  local elements = GSE.split(key, ",")
  local classid = tonumber(elements[1])
  local sequencename = elements[2]
  local seq = GSELibrary[classid] and GSELibrary[classid][sequencename]
  local classname = Statics.wotlkClassIDList[classid] or L["Global"]
  local r, g, b = GetSequenceClassColor(classid)
  local fontName, fontHeight, fontFlags = GameFontNormal:GetFont()

  local selpanel = AceGUI:Create("SelectablePanel")
  selpanel:SetKey(key)
  selpanel:SetFullWidth(true)
  selpanel:SetLayout("List")
  selpanel:SetSelectedColor(r, g, b)
  viewframe.panels[key] = selpanel
  selpanel:SetCallback("OnClick", function(widget, _, selected, button)
    viewframe:clearpanels(widget, true)
    if button == "RightButton" then
      GSE.GUILoadEditor(widget:GetKey(), viewframe)
    end
  end)

  local header = AceGUI:Create("SimpleGroup")
  header:SetFullWidth(true)
  header:SetLayout("Flow")

  local icon = AceGUI:Create("Icon")
  icon.frame:RegisterForDrag("LeftButton")
  icon.frame:SetScript("OnDragStart", function()
    PickupMacro(sequencename)
  end)
  icon:SetImage(GSE.GetMacroIcon(classid, sequencename))
  icon:SetImageSize(36, 36)
  icon:SetWidth(40)
  selpanel.Icon = icon
  header:AddChild(icon)

  local textGroup = AceGUI:Create("SimpleGroup")
  textGroup:SetLayout("List")
  textGroup:SetRelativeWidth(0.84)
  header:AddChild(textGroup)

  local nameLabel = AceGUI:Create("Label")
  nameLabel:SetText(sequencename)
  nameLabel:SetFont(fontName, fontHeight + 3, fontFlags)
  nameLabel.label:SetTextColor(r, g, b)
  nameLabel:SetFullWidth(true)
  textGroup:AddChild(nameLabel)

  local metaText = classname
  if seq and not GSE.isEmpty(seq.Talents) then
    metaText = metaText .. "  -  " .. L["Talents"] .. ": " .. seq.Talents
  end
  local metaLabel = AceGUI:Create("Label")
  metaLabel:SetText(metaText)
  metaLabel:SetFontObject(GameFontNormalSmall)
  metaLabel.label:SetTextColor(0.72, 0.72, 0.72)
  metaLabel:SetFullWidth(true)
  textGroup:AddChild(metaLabel)

  selpanel:AddChild(header)

  local helpText = tostring(seq and seq.Help or "")
  helpText = string.gsub(helpText, "\r", "")
  helpText = string.gsub(helpText, "\n.*", "")
  if GSE.isEmpty(helpText) then
    helpText = L["No Help Information Available"]
  end
  if string.len(helpText) > 170 then
    helpText = string.sub(helpText, 1, 167) .. "..."
  end
  local helpLabel = AceGUI:Create("Label")
  helpLabel:SetFullWidth(true)
  helpLabel:SetFontObject(GameFontNormalSmall)
  helpLabel.label:SetTextColor(0.78, 0.78, 0.78)
  helpLabel:SetText(helpText)
  selpanel:AddChild(helpLabel)

  container:AddChild(selpanel)
end

function GSE.GUIViewerToolbar(container)
  local buttonGroup = AceGUI:Create("SimpleGroup")
  buttonGroup:SetFullWidth(true)
  buttonGroup:SetLayout("Flow")

  local function addButton(text, callback, disabled)
    local button = AceGUI:Create("Button")
    button:SetText(text)
    button:SetAutoWidth(true)
    if callback then
      button:SetCallback("OnClick", callback)
    end
    if disabled then
      button:SetDisabled(true)
    end
    buttonGroup:AddChild(button)
    return button
  end

  local newbutton = addButton(L["New"], function()
    GSE.isNewFirstTimeCreated = true
    GSE.GUILoadEditor(nil, viewframe)
  end)

  local updbutton = addButton(L["Edit"], function()
    GSE.GUIEditFrame:SetStatusText("")
    GSE.GUILoadEditor(editkey, viewframe)
  end, true)
  viewframe.EditButton = updbutton

  local impbutton = addButton(L["Import"], function()
    GSE.GUIViewFrame:Hide()
    GSE.GUIImportFrame:Show()
  end)

  local expbutton = addButton(L["Export"], function()
    GSE.GUIExportSequence(viewframe.ClassID, viewframe.SequenceName)
  end, true)
  viewframe.ExportButton = expbutton

  local tranbutton = addButton(L["Send"], function()
    GSE.GUIShowTransmissionGui(viewframe.ClassID .. "," .. viewframe.SequenceName)
  end, true)
  viewframe.SendButton = tranbutton

  local spacer = AceGUI:Create("Label")
  spacer:SetText("")
  spacer:SetWidth(16)
  spacer:SetHeight(1)
  buttonGroup:AddChild(spacer)

  local disableSeqbutton = addButton(L["Create Icon"], nil, true)
  viewframe.MacroIconButton = disableSeqbutton

  addButton(L["Record Macro"], function()
    GSE.GUIViewFrame:Hide()
    GSE.GUIRecordFrame:Show()
  end)

  addButton(L["Options"], function()
    GSE.OpenOptionsPanel()
  end)

  container:AddChild(buttonGroup)
  viewframe.viewToolbar = buttonGroup
end



function GSE.GUIViewerLayout(mcontainer)
  mcontainer:SetStatusText(L["Gnome Sequencer: Sequence Viewer"])
  mcontainer:SetCallback("OnClose", function(widget) viewframe:Hide() end)
  mcontainer:SetLayout("List")

  local searchGroup = AceGUI:Create("SimpleGroup")
  searchGroup:SetFullWidth(true)
  searchGroup:SetLayout("Flow")

  local searchbox = AceGUI:Create("EditBox")
  searchbox:SetLabel(L["Search"])
  searchbox:SetWidth(260)
  searchbox:SetCallback("OnTextChanged", function(widget, event, text)
    if viewframe.SearchText == text then return end
    viewframe.SearchText = text or ""
    if GSE.RefreshSequenceViewer then GSE.RefreshSequenceViewer() end
  end)
  searchGroup:AddChild(searchbox)
  viewframe.viewSearchGroup = searchGroup
  mcontainer:AddChild(searchGroup)

  local scrollcontainer = AceGUI:Create("SimpleGroup")
  scrollcontainer:SetFullWidth(true)
  scrollcontainer:SetLayout("Fill")
  viewframe.viewScrollContainer = scrollcontainer
  mcontainer:AddChild(scrollcontainer)

  local contentcontainer = AceGUI:Create("ScrollFrame")
  contentcontainer:SetLayout("List")
  scrollcontainer:AddChild(contentcontainer)
  viewframe.ScrollContainer = contentcontainer

  GSE.GUIViewerToolbar(mcontainer)
  GSE.RelayoutViewer()
end

function GSE.RefreshSequenceViewer()
  local container = viewframe.ScrollContainer
  if not container then return end

  container:ReleaseChildren()
  viewframe.panels = {}
  viewframe.ClassID = 0
  viewframe.SequenceName = ""
  editkey = ""
  if viewframe.EditButton then viewframe.EditButton:SetDisabled(true) end
  if viewframe.ExportButton then viewframe.ExportButton:SetDisabled(true) end
  if viewframe.SendButton then viewframe.SendButton:SetDisabled(true) end
  if viewframe.MacroIconButton then
    viewframe.MacroIconButton:SetText(L["Create Icon"])
    viewframe.MacroIconButton:SetDisabled(true)
  end

  local names = GSE.GetSequenceNames()
  local needle = string.lower(viewframe.SearchText or "")
  local visible = {}
  local counts = {}

  for k in GSE.pairsByKeys(names) do
    local elements = GSE.split(k, ",")
    local classid = tonumber(elements[1])
    local sequencename = elements[2]
    local classname = Statics.wotlkClassIDList[classid] or L["Global"]
    local seq = GSELibrary[classid] and GSELibrary[classid][sequencename]
    local matched = needle == ""

    if not matched then
      matched = string.find(string.lower(sequencename), needle, 1, true) ~= nil
        or string.find(string.lower(classname), needle, 1, true) ~= nil
      if not matched and seq then
        if not GSE.isEmpty(seq.Help) then
          matched = string.find(string.lower(tostring(seq.Help)), needle, 1, true) ~= nil
        end
        if not matched and not GSE.isEmpty(seq.Talents) then
          matched = string.find(string.lower(tostring(seq.Talents)), needle, 1, true) ~= nil
        end
      end
    end

    if matched then
      visible[#visible + 1] = k
      counts[classid] = (counts[classid] or 0) + 1
    end
  end

  if #visible == 0 then
    local empty = AceGUI:Create("Label")
    empty:SetText(needle == "" and L["No sequences available."] or L["No sequences match your search."])
    empty:SetFontObject(GameFontNormalSmall)
    empty.label:SetTextColor(0.7, 0.7, 0.7)
    empty:SetFullWidth(true)
    container:AddChild(empty)
  else
    local lastClassid
    for _, k in ipairs(visible) do
      local classid = tonumber(GSE.split(k, ",")[1])
      if classid ~= lastClassid then
        if lastClassid ~= nil then
          local groupSpacer = AceGUI:Create("Label")
          groupSpacer:SetText(" ")
          groupSpacer:SetFontObject(GameFontNormalSmall)
          groupSpacer:SetFullWidth(true)
          container:AddChild(groupSpacer)
        end
        local classname = Statics.wotlkClassIDList[classid] or L["Global"]
        local r, g, b = GetSequenceClassColor(classid)
        local heading = AceGUI:Create("Heading")
        heading:SetText(classname .. "  (" .. counts[classid] .. ")")
        heading.label:SetTextColor(r, g, b)
        heading:SetFullWidth(true)
        container:AddChild(heading)
        lastClassid = classid
      end
      GSE.GUICreateSequencePanels(viewframe, container, k)
    end
  end

  container:DoLayout()
  GSE.RelayoutViewer()
end

function GSE.GUIShowViewer()
  viewframe.SearchText = ""
  viewframe:ReleaseChildren()
  GSE.GUIViewerLayout(viewframe)
  GSE.RefreshSequenceViewer()
  viewframe:Show()
  GSE.RelayoutViewer()
end

function GSE.GUIConfigureMacroButton(button)
  if GSE.OOCCheckMacroCreated(GSE.GUIViewFrame.SequenceName) then
    button:SetText(L["Delete Icon"])
    button:SetCallback("OnClick", function()
      GSE.DeleteMacroStub(GSE.GUIViewFrame.SequenceName)
      GSE.GUIConfigureMacroButton(button)
      GSE.GUIViewFrame.panels[viewframe.ClassID .."," .. GSE.GUIViewFrame.SequenceName].Icon:SetImage(GSE.GetMacroIcon(tonumber(viewframe.ClassID), GSE.GUIViewFrame.SequenceName))
    end)
  else
    button:SetText(L["Create Icon"])
    button:SetCallback("OnClick", function()
      GSE.OOCCheckMacroCreated(GSE.GUIViewFrame.SequenceName, true)
      GSE.GUIConfigureMacroButton(button)
      GSE.GUIViewFrame.panels[viewframe.ClassID .."," .. GSE.GUIViewFrame.SequenceName].Icon:SetImage(GSE.GetMacroIcon(tonumber(viewframe.ClassID), GSE.GUIViewFrame.SequenceName))
    end)
  end
  if GSE.isEmpty(GSE.GUIViewFrame.SequenceName) then
    button:SetDisabled(true)
  else
    button:SetDisabled(false)
  end
  if GSE.GUIViewFrame.ClassID == 0 or GSE.GUIViewFrame.ClassID == GSE.GetCurrentClassID() then
    button:SetDisabled(true)
  end

end
