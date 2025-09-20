local L = QuaziiUI.L

function QuaziiUI:importOmniCDProfile()
    self.DF:ShowPromptPanel(
        L["OmniCDPrompt"],
        function()
            self.db.global.imports.OmniCD = {}
            self.db.global.imports.OmniCD.date = GetServerTime()
            self.db.global.imports.OmniCD.versionNumber = self.versionNumber
            local OmniCD = OmniCD[1]
            local Profile = OmniCD.ProfileSharing
            local profileType, profileKey, profileData = Profile:Decode(self.imports.OmniCD.data)
            Profile:CopyProfile(profileType, profileKey, profileData)
            self.db.char.openPage = 2
        end,
        function()
        end,
        true
    )
end

function QuaziiUI:importOmniCDHealerProfile()
    self.DF:ShowPromptPanel(
        L["OmniCDPrompt"],
        function()
            self.db.global.imports.OmniCDHealer = {}
            self.db.global.imports.OmniCDHealer.date = GetServerTime()
            self.db.global.imports.OmniCDHealer.versionNumber = self.versionNumber
            local OmniCD = OmniCD[1]
            local Profile = OmniCD.ProfileSharing
            local profileType, profileKey, profileData = Profile:Decode(self.imports.OmniCDHealer.data)
            Profile:CopyProfile(profileType, profileKey, profileData)
            self.db.char.openPage = 2
        end,
        function()
        end,
        true
    )
end
