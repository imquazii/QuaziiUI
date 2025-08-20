local L = QuaziiUI.L

-- Page Functions
---@param parentFrame table|Frame
local function createPages(parentFrame)
    local pageCount = 0
    for _, page in ipairs(QuaziiUI.pages) do
        pageCount = pageCount + 1
        page:Create(parentFrame)
    end
    QuaziiUI:DebugPrint("Pages Created:", pageCount)
end

---@param pageIndex integer
function QuaziiUI:selectPage(pageIndex)
    self.db.char.selectedPage = pageIndex
    self.db.char.shownPages = 0

    QuaziiUI:DebugPrint("Selected Page:", pageIndex)
    for _, page in ipairs(self.pages) do
        if not page:ShouldShow() then
            page:Hide()
        else
            self.db.char.shownPages = self.db.char.shownPages + 1
            if self.db.char.shownPages == pageIndex then
                self.db.char.openPage = pageIndex
                page:Show()
            else
                page:Hide()
            end
        end
    end
end

local function selectNextPage()
    if ((QuaziiUI.db.char.selectedPage or 0) < QuaziiUI.db.char.shownPages) then -- If selectedPage is less than total pages
        QuaziiUI.db.char.openPage = QuaziiUI.db.char.selectedPage + 1
        QuaziiUI:selectPage(QuaziiUI.db.char.openPage) -- Show next page
    else -- If last page or higher
        QuaziiUI.panel:Hide() -- Hide installer UI
        QuaziiUI.db.global.isDone = true -- Set done as true
        ReloadUI() -- reload UI
    end
    QuaziiUI.db.char.openPage = nil
end

local function selectIndexPage()
    QuaziiUI.db.char.openPage = 2
    QuaziiUI:selectPage(2)
end

local function selectPreviousPage()
    if QuaziiUI.db.char.selectedPage > 1 then
        QuaziiUI.db.char.openPage = QuaziiUI.db.char.selectedPage - 1
        QuaziiUI:selectPage(QuaziiUI.db.char.openPage)
    end
end

-- Frame Template Functions
---@param parentPanel table|Frame
---@param addonName string
---@param importLabel string
---@param importFunction function
---@return table|Frame
function QuaziiUI:CreateImportFrame(parentPanel, addonName, importLabel, importFunction)
    local frame = CreateFrame("Frame", nil, parentPanel)
    frame:SetHeight(60)
    
    local profileText = self.DF:CreateLabel(frame, "", self.TableHeaderSize)
    profileText:SetFont(QuaziiUI.FontFace, QuaziiUI.TableHeaderSize)
    profileText:SetPoint("TOPLEFT", frame, "TOPLEFT")

    -- Button Template
    local importProfileButton =
        self.DF:CreateButton(frame, importFunction, 90, 25, L["Import"], nil, nil, nil, nil, nil, nil, self.ODT)
    importProfileButton:SetPoint("LEFT", profileText, "RIGHT", 10) -- Attach Button to profileText Label
    importProfileButton.text_overlay:SetFont(QuaziiUI.FontFace, self.TableTextSize) -- Set Button Font Size

    local lastImportLabel = self.DF:CreateLabel(frame, L["ImportLastImportText"], self.TableTextSize)
    lastImportLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    lastImportLabel:SetPoint("TOPRIGHT", profileText, "BOTTOMRIGHT", 0, -3)
    local versionLabel = self.DF:CreateLabel(frame, L["Version"] .. ": ", self.TableTextSize)
    versionLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    versionLabel:SetPoint("TOPRIGHT", lastImportLabel, "BOTTOMRIGHT", 4, -3)

    local lastImportText = self.DF:CreateLabel(frame, "", self.TableTextSize)
    lastImportText:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    lastImportText:SetPoint("LEFT", lastImportLabel, "RIGHT", 10, 0)
    local versionText = self.DF:CreateLabel(frame, "", self.TableTextSize)
    versionText:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    versionText:SetPoint("LEFT", versionLabel, "RIGHT", 6, 0)

    local function update()
        local addonLoaded = C_AddOns and C_AddOns.IsAddOnLoaded(addonName)
        local addonRealName = addonLoaded and select(2, C_AddOns and C_AddOns.GetAddOnInfo(addonName)) or addonName

        local updateLabel = addonRealName

        if not importLabel ~= nil then
            updateLabel = importLabel
        end

        profileText:SetText("|c" .. self.highlightColorHex .. updateLabel .. L["ImportProfileText"] .. "|r")
        frame:SetWidth(profileText:GetStringWidth() + 100)

        if (not addonLoaded) then
            importProfileButton:Disable()
            importProfileButton:SetText(L["NA"])
        else
            importProfileButton:Enable()
            importProfileButton:SetText(L["Import"])
        end
        importProfileButton:SetWidth(importProfileButton.button.text:GetStringWidth() + 10)
    end

    frame:SetScript("OnShow", update)

    frame.lastImportText = lastImportText
    frame.versionText = versionText

    return frame
end

-- Create Main UI Frame (function definition)
local function createPanel()
    -- Init panel

    -- Set initial title to just "Quazii UI" temporarily, we'll override it below
    local panel = QuaziiUI.DF:CreateSimplePanel(UIParent, 600, 700, "Quazii UI", "QuaziiUIMainPanel") 
    QuaziiUI.DF:ApplyStandardBackdrop(panel)

    -- Comment out the version label creation
    -- local versionLabel = QuaziiUI.DF:CreateLabel(panel.TitleBar, QuaziiUI.versionString, 14)
    -- versionLabel:SetTextColor(unpack({0.439216, 0.501961, 0.564706, 1}))
    -- versionLabel:SetPoint("LEFT", panel.TitleBar, "LEFT", 2, 1)

    -- Panel Border
    QuaziiUI.DF:CreateBorder(panel)
    panel:SetBorderColor(unpack(QuaziiUI.highlightColorRGBA))

    -- Panel Title Bar
    panel.Title:SetFont(QuaziiUI.FontFace, 18)
    panel.Title:SetTextColor(unpack(QuaziiUI.textColorRGBA))
    panel.Title:SetPoint("CENTER", panel.TitleBar, "CENTER", 0, 1)
    -- Explicitly set the desired title text
    panel.Title:SetText("Quazii UI Installer (2025.08.20)")

    -- Panel Options
    panel:ClearAllPoints()
    panel:SetPoint("CENTER", UIParent, "CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(100)
    panel:SetLayerVisibility(true, false, false)

    -- Previous Button
    local previousButton =
        QuaziiUI.DF:CreateButton( panel, selectPreviousPage, 90, 40, "<- " .. L["Back"], nil, nil, nil, nil, nil, nil, QuaziiUI.ODT )
    previousButton:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 5)
    previousButton.text_overlay:SetFont(QuaziiUI.FontFace, 18)
    previousButton:SetTextColor(unpack(QuaziiUI.textColorRGBA))

    -- Index Button
    local indexButton =
        QuaziiUI.DF:CreateButton( panel, selectIndexPage, 90, 40, "- " .. L["Index"] .. " -", nil, nil, nil, nil, nil, nil, QuaziiUI.ODT )
    indexButton:SetPoint("BOTTOM", panel, "BOTTOM", 0, 5)
    indexButton.text_overlay:SetFont(QuaziiUI.FontFace, 18)
    indexButton:SetTextColor(unpack(QuaziiUI.textColorRGBA))

    -- Next Button
    local nextButton =
        QuaziiUI.DF:CreateButton( panel, selectNextPage, 90, 40, L["Next"] .. " ->", nil, nil, nil, nil, nil, nil, QuaziiUI.ODT )
    nextButton:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 5)
    nextButton.text_overlay:SetFont(QuaziiUI.FontFace, 18)
    nextButton:SetTextColor(unpack(QuaziiUI.textColorRGBA))

    -- Panel Content Frame
    local panelContentFrame = CreateFrame("Frame", nil, panel)
    panelContentFrame:SetPoint("TOPLEFT", panel.TitleBar, "BOTTOMLEFT", 0, -5)
    panelContentFrame:SetPoint("TOPRIGHT", panel.TitleBar, "BOTTOMRIGHT", 0, -5)
    panelContentFrame:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 0, 48)
    panelContentFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 0, 48)

    panel:HookScript("OnHide", function()
        QuaziiUI:Hide()
        QuaziiUI:DebugPrint("Set isDone to " .. tostring(QuaziiUI.db.global.isDone))
    end)

    panel.frameContent = panelContentFrame
    QuaziiUI.panel = panel

    -- Create a hidden EditBox for copying text
    local copyBox = CreateFrame("EditBox", "QuaziiUICopyBox", panel, "InputBoxTemplate")
    copyBox:SetSize(400, 30)
    copyBox:SetPoint("TOP", panel, "BOTTOM", 0, -10) -- Position below the panel
    copyBox:SetFrameStrata("DIALOG") -- Keep strata same as panel
    copyBox:SetFrameLevel(panel:GetFrameLevel()) -- No longer needs higher level
    copyBox:SetAutoFocus(false)
    copyBox:SetMultiLine(false)
    copyBox:SetFontObject(ChatFontNormal)
    copyBox:SetTextInsets(8, 8, 0, 0)
    copyBox:SetScript("OnEscapePressed", function(self) self:Hide(); if self.label then self.label:Hide() end; self:ClearFocus() end) -- Also hide label
    copyBox:SetScript("OnEnterPressed", function(self) self:Hide(); if self.label then self.label:Hide() end; self:ClearFocus() end) -- Also hide label
    copyBox:Hide()
    panel.copyBox = copyBox -- Attach to the main panel for access

    -- Create a label for the copy box
    local copyLabel = copyBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    copyLabel:SetPoint("BOTTOM", copyBox, "TOP", 0, 5)
    copyLabel:SetText(L["PressCtrlCToCopy"] or "Press Ctrl+C to copy") -- Use localization if available
    copyLabel:Hide()
    copyBox.label = copyLabel

    -- Create a close button for the copy box
    local closeButton = CreateFrame("Button", "QuaziiUICopyBoxCloseButton", copyBox, "UIPanelCloseButton")
    closeButton:SetSize(24, 24)
    closeButton:SetPoint("TOPRIGHT", copyBox, "TOPRIGHT", 2, 2)
    closeButton:SetScript("OnClick", function(self)
        local parentBox = self:GetParent()
        parentBox:Hide()
        if parentBox.label then parentBox.label:Hide() end
        parentBox:ClearFocus()
    end)
    copyBox.closeButton = closeButton -- Attach for potential future use

    createPages(panel) -- Keep page creation linked to panel creation
end

-- New function to handle panel initialization
function QuaziiUI:InitializePanel()
    if self.panelInitialized then return end -- Only run once
    self:DebugPrint("Initializing Panel UI...")
    createPanel() -- Call the actual creation function
    if self.panel then
        self.panelInitialized = true
        self:DebugPrint("Panel UI Initialized.")
    else
        self:DebugPrint("Panel UI Initialization failed - panel object not created.")
    end
end

-- createPanel() -- Removed direct call from here
