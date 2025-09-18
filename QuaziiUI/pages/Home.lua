local L = QuaziiUI.L

local page = {}
table.insert(QuaziiUI.pages, page)

-- Define the import function locally for Tank/DPS profile
local function importTankDPSProfileFromHome()
    if not (C_AddOns and C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI and ElvUI[1]) then
        print("QuaziiUI Error: ElvUI addon is not loaded or ElvUI[1] is not available.")
        return
    end

    QuaziiUI.DF:ShowPromptPanel(
        "Are you sure you want to import Quazii's Tank/DPS ElvUI profile?\nThis is the recommended profile for most users.",
        function()
            if C_AddOns and C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI and ElvUI[1] then
                QuaziiUI.db.global.imports.tankdps = {
                    date = GetServerTime(),
                    version = QuaziiUI.versionNumber
                }
                local Profile = ElvUI[1].Distributor
                if Profile and Profile.ImportProfile then
                    Profile:ImportProfile(QuaziiUI.imports.ElvUI.tankdps.data)
                    print("QuaziiUI: ElvUI Tank/DPS profile imported successfully.")
                    QuaziiUI.db.char.openPage = 1
                else
                    print("QuaziiUI Error: ElvUI Distributor or ImportProfile method not found.")
                end
            else
                print("QuaziiUI Error: ElvUI addon is not loaded or ElvUI[1] is not available during import confirmation.")
            end
        end,
        function()
            print("QuaziiUI: ElvUI Tank/DPS profile import cancelled.")
        end,
        true
    )
end

-- Define the import function locally for Healer profile
local function importHealerProfileFromHome()
    if not (C_AddOns and C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI and ElvUI[1]) then
        print("QuaziiUI Error: ElvUI addon is not loaded or ElvUI[1] is not available.")
        return
    end

    QuaziiUI.DF:ShowPromptPanel(
        "Are you sure you want to import Quazii's Healer ElvUI profile?",
        function()
            if C_AddOns and C_AddOns.IsAddOnLoaded("ElvUI") and ElvUI and ElvUI[1] then
                QuaziiUI.db.global.imports.healer = { -- Use 'healer' key for db
                    date = GetServerTime(),
                    version = QuaziiUI.versionNumber
                }
                local Profile = ElvUI[1].Distributor
                if Profile and Profile.ImportProfile then
                    Profile:ImportProfile(QuaziiUI.imports.ElvUI.healer.data) -- Use healer data
                    print("QuaziiUI: ElvUI Healer profile imported successfully.")
                    QuaziiUI.db.char.openPage = 1
                else
                    print("QuaziiUI Error: ElvUI Distributor or ImportProfile method not found.")
                end
            else
                print("QuaziiUI Error: ElvUI addon is not loaded or ElvUI[1] is not available during import confirmation.")
            end
        end,
        function()
            print("QuaziiUI: ElvUI Healer profile import cancelled.")
        end,
        true
    )
end

-- Define the import function locally for Cell Tank/DPS profile
local function importCellTankDPSProfileFromHome()
    local F = Cell and Cell.funcs -- Ensure Cell and funcs exist
    local Serializer = LibStub and LibStub:GetLibrary("LibSerialize", true)
    local LibDeflate = LibStub and LibStub:GetLibrary("LibDeflate", true)

    if not (Cell and F and Serializer and LibDeflate) then
        print("QuaziiUI Error: Cell addon or required libraries (LibSerialize, LibDeflate) not loaded.")
        return
    end

    local importString = QuaziiUI.imports.Cell.tankdps.data
    if not importString or importString == "" then
         print("QuaziiUI Error: Cell Tank/DPS import string is missing or empty.")
         return
    end

    QuaziiUI.DF:ShowPromptPanel(
        L["CellPrompt"]:gsub("ADDONNAME", "Cell (Tank/DPS/Heals)"), -- Modify prompt slightly
        function()
            local version, data = string.match(importString, "^!CELL:(%d+):ALL!(.+)$")
            if not version or not data then
                print("QuaziiUI Error: Invalid Cell import string format (Tank/DPS).")
                return
            end
            version = tonumber(version)

            if version >= Cell.MIN_VERSION and version <= Cell.versionNum then
                local success_decode, decoded_data = pcall(LibDeflate.DecodeForPrint, LibDeflate, data)
                if not success_decode then print("QuaziiUI Cell Import Error: DecodeForPrint failed.", decoded_data) return end

                local success_decompress, decompressed_data = pcall(LibDeflate.DecompressDeflate, LibDeflate, decoded_data)
                if not success_decompress then print("QuaziiUI Cell Import Error: DecompressDeflate failed.", decompressed_data) return end
                
                local success_deserialize, imported = Serializer:Deserialize(decompressed_data)
                if not success_deserialize or not imported then print("QuaziiUI Cell Import Error: Deserialize failed.", imported) return end

                -- Apply necessary filtering/defaults (adapted from original CellImport)
                imported["raidDebuffs"] = nil -- Simplify: Assume raid debuffs are not kept from import
                if Cell.isRetail then imported["appearance"]["useLibHealComm"] = false end
                for _, layout in pairs(imported["layouts"] or {}) do
                    for i = #layout["indicators"], 1, -1 do
                        if layout["indicators"][i]["type"] == "built-in" then
                            if not Cell.defaults.indicatorIndices[layout["indicators"][i]["indicatorName"]] then tremove(layout["indicators"], i) end
                        else F:FilterInvalidSpells(layout["indicators"][i]["auras"]) end
                    end
                    if Cell.flavor ~= imported.flavor then layout.powerFilters = F:Copy(Cell.defaults.layout.powerFilters) end
                end
                -- Simplified: Assume missing indicators are not added back
                if Cell.isRetail then CellDB["clickCastings"] = imported["clickCastings"] end -- Only copy if retail
                if Cell.isRetail and imported["layoutAutoSwitch"] then CellDB["layoutAutoSwitch"] = imported["layoutAutoSwitch"] end
                imported["clickCastings"] = nil
                imported["layoutAutoSwitch"] = nil
                imported["characterDB"] = nil
                F:FilterInvalidSpells(imported["debuffBlacklist"])
                F:FilterInvalidSpells(imported["bigDebuffs"])
                F:FilterInvalidSpells(imported["actions"])
                F:FilterInvalidSpells(imported["customDefensives"])
                F:FilterInvalidSpells(imported["customExternals"])
                F:FilterInvalidSpells(imported["targetedSpellsList"])

                -- Overwrite CellDB with imported data
                for k, v in pairs(imported) do CellDB[k] = v end
                
                print("QuaziiUI: Cell Tank/DPS Profile imported successfully. Reloading UI.")
                QuaziiUI.db.global.imports.CellTankDPS = { date = GetServerTime(), version = QuaziiUI.versionNumber } -- Update DB
                ReloadUI()
            else
                 print("QuaziiUI Error: Cell import string version mismatch.", "Imported:", version, "Current:", Cell.versionNum)
            end
        end,
        function() print("QuaziiUI: Cell Tank/DPS profile import cancelled.") end,
        true
    )
end

-- Navigation function for Class WAs
local function goToClassWAs()
    -- QuaziiUI.initialWACategory = 1 -- No longer needed
    QuaziiUI:selectPage(3)      -- Navigate to ClassWeakAuras page (index 3)
end

-- Navigation function for Utility WAs
local function goToUtilityWAs()
    -- QuaziiUI.initialWACategory = 2 -- No longer needed
    QuaziiUI:selectPage(4)      -- Navigate to UtilityWeakAuras page (index 4)
end

-- Import function for Anchor WeakAuras
local function importAnchorWeakAuras()
    if not WeakAuras then
        print("QuaziiUI Error: WeakAuras addon not found.")
        return
    end
    
    -- Import the Anchor WeakAuras from category 0
    if QuaziiUI.imports.WAStrings[0] and QuaziiUI.imports.WAStrings[0].WAs and QuaziiUI.imports.WAStrings[0].WAs[1] then
        WeakAuras.Import(QuaziiUI.imports.WAStrings[0].WAs[1])
        print("QuaziiUI: Anchor WeakAuras imported successfully.")
        -- Update database to track the import
        QuaziiUI.db.global.imports.AnchorWeakAuras = { date = GetServerTime(), version = QuaziiUI.versionNumber }
    else
        print("QuaziiUI Error: Anchor WeakAuras import string not found.")
    end
end

-- Create a modified list for the Home page display, with Cell first and ElvUI last
local homePageDisplayList = {}
do
    local elvuiEntries = {}
    local cellEntries = {}
    local weakAuraEntries = {}
    local otherEntries = {}
    for _, addonName in ipairs(QuaziiUI.supportedAddons) do
        if addonName == "Cell" then
            table.insert(cellEntries, { addonName = addonName, profileType = "TankDPS" })
        elseif addonName == "ElvUI" then
            table.insert(elvuiEntries, { addonName = addonName, profileType = "TankDPS" })
            table.insert(elvuiEntries, { addonName = addonName, profileType = "Healer" })
        elseif addonName == "WeakAuras" then
             -- Store WeakAura entries separately
             table.insert(weakAuraEntries, { addonName = addonName, profileType = "Anchor" })
             table.insert(weakAuraEntries, { addonName = addonName, profileType = "Class" })
             table.insert(weakAuraEntries, { addonName = addonName, profileType = "Utility" })
        else
            table.insert(otherEntries, { addonName = addonName })
        end
    end
    -- Construct the final list order: Cell -> WeakAuras -> Others -> ElvUI
    for _, entry in ipairs(cellEntries) do
        table.insert(homePageDisplayList, entry)
    end
    for _, entry in ipairs(weakAuraEntries) do
        table.insert(homePageDisplayList, entry)
    end
    for _, entry in ipairs(otherEntries) do
        table.insert(homePageDisplayList, entry)
    end
    for _, entry in ipairs(elvuiEntries) do
        table.insert(homePageDisplayList, entry)
    end
end

local function addonScrollBoxUpdate(self, data, offset, totalLines)
    for i = 1, totalLines do
        local index = i + offset
        local entry = data[index]
        if entry then
            local line = self:GetLine(i)
            local addonName = entry.addonName
            local profileType = entry.profileType

            local addonTitle = C_AddOns and C_AddOns.GetAddOnInfo(addonName)
            local addonEnabled = C_AddOns and C_AddOns.IsAddOnLoaded(addonName)

            local addonLabelBaseText = addonTitle or addonName
            local versionLabelText = addonTitle and C_AddOns and C_AddOns.GetAddOnMetadata(addonName, "Version") or L["NA"]
            local enabledStatusText = addonEnabled and L["True"] or L["False"]

            line.addonLabel:SetTextColor(1, 1, 1, 1)
            line.versionLabel:SetTextColor(1, 1, 1, 1)
            line.enabledLabel:SetTextColor(1, 1, 1, 1)

            if addonName == "Cell" then
                line.addonLabel:SetTextColor(1, 0.647, 0, 1)
                line.versionLabel:SetTextColor(1, 0.647, 0, 1)
                line.enabledLabel:SetTextColor(1, 0.647, 0, 1)
                if profileType == "TankDPS" then
                    addonLabelBaseText = addonTitle .. " (" .. L["Tank"] .. "/" .. L["DPS"] .. "/" .. L["Heals"] .. ")"
                end
            elseif addonName == "ElvUI" then
                line.addonLabel:SetTextColor(1, 0, 1, 1)
                line.versionLabel:SetTextColor(1, 0, 1, 1)
                line.enabledLabel:SetTextColor(1, 0, 1, 1)
                if profileType == "TankDPS" then
                    addonLabelBaseText = addonTitle .. " (" .. L["Tank"] .. "/" .. L["DPS"] .. ")"
                elseif profileType == "Healer" then
                    addonLabelBaseText = addonTitle .. " (" .. L["Healer"] .. ")"
                end
            elseif addonName == "WeakAuras" then
                 -- Keep default white color
                 if profileType == "Anchor" then
                    addonLabelBaseText = "Anchor WeakAuras |cFFFF0000(MUST INSTALL)|r"
                 elseif profileType == "Class" then
                    addonLabelBaseText = addonTitle .. " (" .. L["Class WAs"] .. ")" 
                 elseif profileType == "Utility" then
                    addonLabelBaseText = addonTitle .. " (" .. L["Utility WAs"] .. ")"
                 end
            else -- Default white for other addons
                addonLabelBaseText = addonLabelBaseText
            end
            
            line.addonLabel:SetText(addonLabelBaseText)
            line.versionLabel:SetText(versionLabelText)
            line.enabledLabel:SetText(enabledStatusText)

            -- Configure buttons
            if addonName == "Cell" then
                 if addonEnabled then
                     line.importButton:SetText(L["Import"])
                     if profileType == "TankDPS" then
                         line.importButton:SetClickFunction(importCellTankDPSProfileFromHome)
                     else
                        line.importButton:Disable()
                        line.importButton:SetText(L["NA"])
                     end
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
            elseif addonName == "ElvUI" then
                 if addonEnabled then
                     if profileType == "TankDPS" then
                         line.importButton:SetText(L["Tank"] .. "/" .. L["DPS"] .. " " .. L["Import"])
                         line.importButton:SetClickFunction(importTankDPSProfileFromHome)
                     elseif profileType == "Healer" then
                         line.importButton:SetText(L["Healer"] .. " " .. L["Import"])
                         line.importButton:SetClickFunction(importHealerProfileFromHome)
                     else
                         line.importButton:Disable()
                         line.importButton:SetText(L["NA"])
                     end
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
             elseif addonName == "WeakAuras" then
                  if addonEnabled then
                     if profileType == "Anchor" then
                        line.importButton:SetText(L["Import"])
                        line.importButton:SetClickFunction(importAnchorWeakAuras)
                     elseif profileType == "Class" then
                        line.importButton:SetText(L["GoToPage"]) -- Keep text as Go To Page
                        line.importButton:SetClickFunction(goToClassWAs)
                     elseif profileType == "Utility" then
                        line.importButton:SetText(L["GoToPage"]) -- Keep text as Go To Page
                        line.importButton:SetClickFunction(goToUtilityWAs)
                     else
                        line.importButton:Disable()
                        line.importButton:SetText(L["NA"])
                     end
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
             elseif addonName == "Plater" then
                 if addonEnabled then
                     line.importButton:SetClickFunction(function() QuaziiUI:importPlaterProfile() end)
                     line.importButton:SetText(L["Import"])
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
             elseif addonName == "BigWigs" then
                 if addonEnabled then
                     -- Change to show EditBox for manual copy
                     line.importButton:SetClickFunction(function() 
                         local copyBox = QuaziiUI.panel and QuaziiUI.panel.copyBox
                         if copyBox then
                             copyBox:SetText(QuaziiUI.imports.BigWigs.data)
                             copyBox:HighlightText()
                             copyBox:Show()
                             if copyBox.label then copyBox.label:Show() end
                             copyBox:SetFocus()
                         else
                             print("QuaziiUI Error: CopyBox not found on panel.")
                         end
                     end)
                     line.importButton:SetText("Show String") -- Updated text
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
             elseif addonName == "Details" then
                 if addonEnabled then
                     line.importButton:SetClickFunction(function() QuaziiUI:importDetailsProfile() end)
                     line.importButton:SetText(L["Import"])
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
             elseif addonName == "OmniCD" then
                 if addonEnabled then
                     line.importButton:SetClickFunction(function() QuaziiUI:importOmniCDProfile() end)
                     line.importButton:SetText(L["Import"])
                 else
                     line.importButton:Disable()
                     line.importButton:SetText(L["NA"])
                 end
            else
                -- Fallback
                line.importButton:Disable()
                line.importButton:SetText(L["NA"]) 
            end
        end
    end
end

---@param index integer
local function createAddonButton(self, index)
    local line = CreateFrame("Button", nil, self, "BackdropTemplate")
    line:SetClipsChildren(true)
    line:SetPoint("TOPLEFT", self, "TOPLEFT", 1, -((index - 1) * (self.LineHeight + 1)) - 1)
    line:SetSize(555, self.LineHeight)
    line:SetBackdrop(
        {
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            tileSize = 64,
            tile = true
        }
    )
    line:SetBackdropColor(0.8, 0.8, 0.8, 0.2)
    QuaziiUI.DF:Mixin(line, QuaziiUI.DF.HeaderFunctions)

    line.addonLabel = QuaziiUI.DF:CreateLabel(line, nil, QuaziiUI.TableTextSize)
    line.addonLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    line.versionLabel = QuaziiUI.DF:CreateLabel(line, nil, QuaziiUI.TableTextSize)
    line.versionLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    line.enabledLabel = QuaziiUI.DF:CreateLabel(line, nil, QuaziiUI.TableTextSize)
    line.enabledLabel:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)
    line.importButton = QuaziiUI.DF:CreateButton(line, nil, 105, 30, L["Import"], nil, nil, nil, nil, nil, nil, QuaziiUI.ODT)
    line.importButton.text_overlay:SetFont(QuaziiUI.FontFace, QuaziiUI.TableTextSize)

    line:AddFrameToHeaderAlignment(line.addonLabel)
    line:AddFrameToHeaderAlignment(line.enabledLabel)
    line:AddFrameToHeaderAlignment(line.versionLabel)
    line:AddFrameToHeaderAlignment(line.importButton)
    line:AlignWithHeader(self:GetParent().addonHeader, "LEFT")

    return line
end

function page:Create(parent)
    local frame = CreateFrame("Frame", nil, parent.frameContent)
    frame:SetAllPoints()

    self:CreateHeader(frame)
    self:CreateDescription(frame)
    self:CreateAddonList(frame)

    self.rootFrame = frame
    return frame
end

function page:CreateHeader(frame)
    local header =
        QuaziiUI.DF:CreateLabel(frame, "|c" .. QuaziiUI.highlightColorHex .. L["SupportedAddonsHeader"] .. "|r", QuaziiUI.PageHeaderSize)
    header:SetFont(QuaziiUI.FontFace, QuaziiUI.PageHeaderSize)
    header:SetPoint("TOP", frame, "TOP", 0, -10)
end

function page:CreateDescription(frame)
    local description = QuaziiUI.DF:CreateLabel(frame, L["SupportedAddonsText"], QuaziiUI.PageTextSize)
    description:SetFont(QuaziiUI.FontFace, QuaziiUI.PageTextSize)
    description:SetWordWrap(true)
    description:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
    description:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -40)
    description:SetJustifyH("LEFT")
    description:SetJustifyV("TOP")
    self.description = description
end

function page:CreateAddonList(frame)
    local headerTable = {
        {text = "|c" .. QuaziiUI.highlightColorHex .. L["SupportedAddonsTable1stHeader"], width = 221, offset = 2},
        {text = L["SupportedAddonsTable2ndHeader"], width = 70},
        {text = L["SupportedAddonsTable3rdHeader"], width = 150},
        {text = L["Import"], width = 110}
    }
    local options = {text_size = QuaziiUI.TableHeaderSize}
    frame.addonHeader = QuaziiUI.DF:CreateHeader(frame, headerTable, options, "QuaziiUIInstallAddonHeader")
    frame.addonHeader:SetPoint("TOPLEFT", self.description.widget, "BOTTOMLEFT", -2, -10)

    local addonScrollBox =
        QuaziiUI.DF:CreateScrollBox(frame, nil, addonScrollBoxUpdate, {}, 557, 481, 0, 34, createAddonButton, true)
    addonScrollBox:SetPoint("TOPLEFT", frame.addonHeader, "BOTTOMLEFT", 0, 0)
    addonScrollBox.ScrollBar.scrollStep = 34
    QuaziiUI.DF:ReskinSlider(addonScrollBox)
    -- Use the new display list
    addonScrollBox:SetData(homePageDisplayList)
    addonScrollBox:Refresh()
end

function page:ShouldShow()
    return true
end

function page:Show()
    self.rootFrame:Show()
end

function page:Hide()
    self.rootFrame:Hide()
end
