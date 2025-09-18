local L = QuaziiUI.L

local page = {}
-- Add this new page to the sequence (will be ordered by pages.xml)
table.insert(QuaziiUI.pages, page) 

-- Removed currentCategory, GameTooltip is still needed
local GameTooltip = GameTooltip

---@param importString string
local function decodeWAPacket(importString)
    return QuaziiUI.decodeWAPacket(importString)
end

---@param waTable table
---@return string
local function getWAUpdateStatus(waTable)
    if WeakAuras then
        if waTable and waTable.d then
            local WAData = WeakAuras.GetData(waTable.d.id)
            if not WAData then return L["NA"] end
            local installedVersion = tonumber(string.match(WAData.desc or "Version 0", "Version (%d+)")) or 0
            local newVersion = tonumber(string.match(waTable.d.desc or "Version 0", "Version (%d+)")) or 0
            return newVersion > installedVersion and "|cFFbc1f00" .. L["Yes"] .. "|r" or "|cFF28bc00" .. L["No"] .. "|r"
        end
        return L["NA"]
    end
    return L["NA"]
end

-- Modified parseWAData to only handle index 1 (Class WAs)
---@return table
local function parseClassWAData()
    local data = {}
    -- Directly access category 1 WAs
    for _, importString in ipairs(QuaziiUI.imports.WAStrings[1].WAs) do 
        local waTable = decodeWAPacket(importString) or {}
        if waTable and waTable.d then
            table.insert( data, {
                icon = waTable.d.groupIcon or waTable.d.displayIcon or QuaziiUI.logoPath,
                name = waTable.d.id:gsub("%[READ%sINFORMATION%sTAB%]", ""):gsub("Healthstone/Potions", "Consumables"),
                version = string.match(waTable.d.desc or "", "Version (%d+)") or "0",
                update = getWAUpdateStatus(waTable)
            })
        end
    end
    return data
end

-- Renamed variable to be specific
local classWADataList = parseClassWAData() 

-- Removed fillWAFromCategoryIndex and onCategoryClick functions

-- Modified waScrollBoxUpdate to directly use category 1 data
local function waScrollBoxUpdate(self, data, offset, totalLines)
    for i = 1, totalLines do
        local index = i + offset
        local info = data[index]
        if info then
            local line = self:GetLine(i)
            line.icon:SetTexture(info.icon)
            line.nameLabel:SetText(info.name)
            line.versionLabel:SetText(info.version)
            line.updateLabel:SetText(info.update)

            if info.update == "N/A" then
                line.updateLabel:SetScript("OnEnter", function(self)
                    GameTooltip:SetOwner(self, "ANCHOR_CURSOR_RIGHT")
                    GameTooltip:AddLine(L["WeakAuraNotFound"])
                    GameTooltip:Show()
                end)
                line.updateLabel:SetScript("OnLeave", GameTooltip_Hide)
            else
                line.updateLabel:SetScript("OnEnter", nil)
                line.updateLabel:SetScript("OnLeave", nil)
            end

            if not WeakAuras then
                line.importButton:Disable()
                line.importButton:SetText(L["NA"])
            else
                line.importButton:SetClickFunction( function()
                    -- Directly use category 1 string for import
                    WeakAuras.Import(QuaziiUI.imports.WAStrings[1].WAs[index]) 
                    -- Update status based on category 1 data
                    line.updateLabel:SetText(getWAUpdateStatus(decodeWAPacket(QuaziiUI.imports.WAStrings[1].WAs[index]))) 
                end)
            end
        end
    end
end

---@return table
local function createWAButton(self, index)
    local line = CreateFrame("Button", nil, self, "BackdropTemplate")
    line:SetClipsChildren(true)
    line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index - 1) * (self.LineHeight + 1)) - 1)
    line:SetSize(555, self.LineHeight)
    line:SetBackdrop( { bgFile = "Interface\Tooltips\UI-Tooltip-Background", tileSize = 64, tile = true } )
    line:SetBackdropColor(0.8, 0.8, 0.8, 0.2)
    QuaziiUI.DF:Mixin(line, QuaziiUI.DF.HeaderFunctions)

    line.icon = line:CreateTexture(nil, "OVERLAY")
    line.nameLabel = QuaziiUI.DF:CreateLabel(line, "", 16)
    line.versionLabel = QuaziiUI.DF:CreateLabel(line, "", 16)
    line.updateLabel = QuaziiUI.DF:CreateLabel(line, "", 16)

    line.icon:SetSize(42, 42)
    line.nameLabel:SetSize(318, self.LineHeight / 2)
    line.nameLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    line.versionLabel:SetSize(68, self.LineHeight / 2)
    line.versionLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    line.updateLabel:SetSize(68, self.LineHeight / 2)
    line.updateLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    line.updateLabel:SetJustifyH("CENTER")

    line.importButton = QuaziiUI.DF:CreateButton(line, nil, 105, 30, L["Import"], nil, nil, nil, nil, nil, nil, QuaziiUI.ODT)
    line.importButton.text_overlay:SetFont(QuaziiUI.FontFace, 16)

    line:AddFrameToHeaderAlignment(line.icon)
    line:AddFrameToHeaderAlignment(line.nameLabel)
    line:AddFrameToHeaderAlignment(line.versionLabel)
    line:AddFrameToHeaderAlignment(line.updateLabel)
    line:AddFrameToHeaderAlignment(line.importButton)
    line:AlignWithHeader(self:GetParent().addonHeader, "LEFT")

    return line
end

function page:Create(parent)
    local frame = CreateFrame("Frame", nil, parent.frameContent)
    frame:SetAllPoints()

    self:CreateHeader(frame)
    self:CreateDescription(frame)
    self:CreateWAList(frame)
    -- Removed call to CreateSelectionDropdown (tab buttons)

    self.rootFrame = frame
    return frame
end

function page:CreateHeader(frame)
    local header = QuaziiUI.DF:CreateLabel( frame,
        "|c" .. QuaziiUI.highlightColorHex .. L["Class WAs"] .. " " .. L["Imports"] .. "|r", -- Updated Title
        QuaziiUI.PageHeaderSize
    )
    header:SetFont(QuaziiUI.FontFace, QuaziiUI.PageHeaderSize)
    header:SetPoint("TOP", frame, "TOP", 0, -10)
end

function page:CreateDescription(frame)
    -- Create the red warning text first
    local warningText = QuaziiUI.DF:CreateLabel(frame, "|cFFFF0000IMPORTANT: Import Anchor WeakAuras from 'Home' tab FIRST! These invisible anchors let you position where all current and future QUI WAs appear. New and updated WAs will always retain the positions you set.|r", QuaziiUI.PageTextSize) 
    warningText:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    warningText:SetWordWrap(true)
    warningText:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -45) 
    warningText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -45)
    warningText:SetJustifyH("LEFT")
    warningText:SetJustifyV("TOP")
    
    -- Create the original description text below the warning
    local text = QuaziiUI.DF:CreateLabel(frame, L["WeakAuraText"], QuaziiUI.PageTextSize) 
    text:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    text:SetWordWrap(true)
    -- Position below the warning text with some spacing
    text:SetPoint("TOPLEFT", warningText.widget, "BOTTOMLEFT", 0, -10) 
    text:SetPoint("TOPRIGHT", warningText.widget, "BOTTOMRIGHT", 0, -10)
    text:SetJustifyH("LEFT")
    text:SetJustifyV("TOP")
    self.descriptionText = text
end

-- Removed CreateSelectionDropdown function

function page:CreateWAList(frame)
    local headerTable = {
        {text = L["Icon"], width = 50, canSort = false},
        {text = L["Name"], width = 209, canSort = false}, 
        {text = L["Version"], width = 75, canSort = false},
        {text = L["Update"], width = 107, canSort = false},
        {text = L["Import"], width = 110, canSort = false}
    }
    local options = {text_size = QuaziiUI.TableHeaderSize}
    frame.addonHeader = QuaziiUI.DF:CreateHeader(frame, headerTable, options, "QuaziiUIInstallWAHeader")
    frame.addonHeader:SetPoint("TOPLEFT", self.descriptionText.widget, "BOTTOMLEFT", -2, -10)

    local waScrollBox = QuaziiUI.DF:CreateScrollBox(frame, nil, waScrollBoxUpdate, {}, 557, 488, 0, 40, createWAButton, true)
    waScrollBox:SetPoint("TOPLEFT", frame.addonHeader, "BOTTOMLEFT", 0, 0)
    waScrollBox.ScrollBar.scrollStep = 40
    QuaziiUI.DF:ReskinSlider(waScrollBox)
    self.waScrollBox = waScrollBox
end

function page:ShouldShow()
    return true
end

function page:Show()
    -- Directly set data for Class WAs
    self.waScrollBox:SetData(classWADataList) 
    self.waScrollBox:Refresh()
    -- Removed logic checking for initialWACategory
    self.rootFrame:Show()
end

function page:Hide()
    self.rootFrame:Hide()
end 