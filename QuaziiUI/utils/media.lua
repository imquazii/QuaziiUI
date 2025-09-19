-- QuaziiUI Media Registration
-- This file handles the registration of fonts and textures with LibSharedMedia

local LSM = LibStub("LibSharedMedia-3.0")

-- Media types from LibSharedMedia
local MediaType = LSM.MediaType
local FONT = MediaType.FONT
local STATUSBAR = MediaType.STATUSBAR
local BACKGROUND = MediaType.BACKGROUND
local BORDER = MediaType.BORDER
local SOUND = MediaType.SOUND

-- Register the Quazii font (used as the main UI font)
LSM:Register(FONT, "Quazii", QuaziiUI.FontFace)

-- Register the Quazii Logo texture
-- You can use this for backgrounds, statusbars, etc.
local logoTexturePath = QuaziiUI.logoPath
LSM:Register(BACKGROUND, "QuaziiLogo", logoTexturePath)

-- Register the Quazii texture
local quaziiTexturePath = "Interface\\AddOns\\QuaziiUI\\assets\\Quazii.tga"
LSM:Register(BACKGROUND, "Quazii", quaziiTexturePath)
LSM:Register(STATUSBAR, "Quazii", quaziiTexturePath)
LSM:Register(BORDER, "Quazii", quaziiTexturePath)

-- Register Quazii Voice Pack (sounds)
do
    local voicepackBasePath = "Interface\\AddOns\\QuaziiUI\\voicepack\\"
    local voiceFiles = {
        "QUI2_Absorb.ogg",
        "QUI2_Adds.ogg",
        "QUI2_AOE.ogg",
        "QUI2_Avoid.ogg",
        "QUI2_Bait.ogg",
        "QUI2_Beam.ogg",
        "QUI2_Binding.ogg",
        "QUI2_Bombs.ogg",
        "QUI2_Breath.ogg",
        "QUI2_Buffed.ogg",
        "QUI2_Burn.ogg",
        "QUI2_Buster Soon.ogg",
        "QUI2_Buster.ogg",
        "QUI2_Cap.ogg",
        "QUI2_Charge.ogg",
        "QUI2_Clear.ogg",
        "QUI2_Dance.ogg",
        "QUI2_Debuff.ogg",
        "QUI2_Defensive.ogg",
        "QUI2_Dodge.ogg",
        "QUI2_DOT.ogg",
        "QUI2_DPS.ogg",
        "QUI2_Drop.ogg",
        "QUI2_EldenRingDeath.ogg",
        "QUI2_EmotionalDamage.ogg",
        "QUI2_Enraged.ogg",
        "QUI2_Feet.ogg",
        "QUI2_Fixate.ogg",
        "QUI2_Fly Away.ogg",
        "QUI2_Front.ogg",
        "QUI2_Hide.ogg",
        "QUI2_Intermission.ogg",
        "QUI2_Interrupt.ogg",
        "QUI2_Kick.ogg",
        "QUI2_Link.ogg",
        "QUI2_Lust.ogg",
        "QUI2_Mount.ogg",
        "QUI2_Move In.ogg",
        "QUI2_Move Out.ogg",
        "QUI2_Move.ogg",
        "QUI2_MoveSoon.ogg",
        "QUI2_Nova.ogg",
        "QUI2_Orbs.ogg",
        "QUI2_Out.ogg",
        "QUI2_Pass.ogg",
        "QUI2_Phase Soon.ogg",
        "QUI2_Phase.ogg",
        "QUI2_Pick Up.ogg",
        "QUI2_Power Infusion.ogg",
        "QUI2_QUI2_AOE.ogg",
        "QUI2_Reflect.ogg",
        "QUI2_Ring.ogg",
        "QUI2_Roar.ogg",
        "QUI2_Rooted.ogg",
        "QUI2_Shadowfury.ogg",
        "QUI2_Shield.ogg",
        "QUI2_Silence.ogg",
        "QUI2_Soak.ogg",
        "QUI2_Spread.ogg",
        "QUI2_Stack.ogg",
        "QUI2_Stop Cast.ogg",
        "QUI2_Stop.ogg",
        "QUI2_Swap.ogg",
        "QUI2_Sweep.ogg",
        "QUI2_Targeted.ogg",
        "QUI2_Taunt.ogg",
        "QUI2_Teleport.ogg",
        "QUI2_Totem.ogg",
        "QUI2_Traps.ogg",
        "QUI2_Turn Away.ogg",
        "QUI2_Vortex.ogg",
        "QUI2_Wake.ogg",
        "QUI2_Wall.ogg",
        "QUI2_Weapon.ogg",
    }

    for _, fileName in ipairs(voiceFiles) do
        local soundName = fileName:gsub("%.ogg$", "")
        LSM:Register(SOUND, soundName, voicepackBasePath .. fileName)
    end
end

-- Function to check if our media is registered
function QuaziiUI:CheckMediaRegistration()
    local quaziiFontRegistered = LSM:IsValid(FONT, "Quazii")
    local logoTextureRegistered = LSM:IsValid(BACKGROUND, "QuaziiLogo")
    local quaziiTextureRegistered = LSM:IsValid(BACKGROUND, "Quazii")
    
    if quaziiFontRegistered and logoTextureRegistered and quaziiTextureRegistered then
        QuaziiUI:Print("Media registration successful!")
    else
        QuaziiUI:Print("Media registration failed:")
        if not quaziiFontRegistered then QuaziiUI:Print("- Quazii font not registered") end
        if not logoTextureRegistered then QuaziiUI:Print("- QuaziiLogo texture not registered") end
        if not quaziiTextureRegistered then QuaziiUI:Print("- Quazii texture not registered") end
    end
end

-- Register any additional fonts or textures here
-- Example:
-- LSM:Register(FONT, "MyCustomFont", "Interface\\AddOns\\QuaziiUI\\assets\\mycustomfont.ttf")
-- LSM:Register(STATUSBAR, "MyCustomTexture", "Interface\\AddOns\\QuaziiUI\\assets\\mycustomtexture.tga") 