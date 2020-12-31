function GM:PlayerStartVoice( talker )
    if not talker:Alive() then return end

    local listener = LocalPlayer()

    if listener:GetRadioEnabled() and talker:GetRadioEnabled() and listener:GetRadioFrequency() == talker:GetRadioFrequency() then
        surface.PlaySound( "npc/overwatch/radiovoice/on1.wav" )
    end
end

function GM:PlayerEndVoice( talker )
    if not talker:Alive() then return end

    local listener = LocalPlayer()

    if listener:GetRadioEnabled() and talker:GetRadioEnabled() and listener:GetRadioFrequency() == talker:GetRadioFrequency() then
        surface.PlaySound( "npc/overwatch/radiovoice/off4.wav" )
    end
end

local mat = Material( "voice/icntlk_sv" )
local size = 64
local voice_modes = {
    "whispering",
    "talking",
    "yelling"
}
hook.Add( "HUDPaint", "VRP:ShowTalking", function()
    local ply = LocalPlayer()
    if not ply:IsSpeaking() then return end
    local w, h = ScrW(), ScrH()

    surface.SetDrawColor( 255, 255, 255 )
    surface.SetMaterial( mat )
    surface.DrawTexturedRect( w - size * 1.5, h / 2 - size / 2, size, size )

    draw.SimpleText( VRP.GetPhrase( voice_modes[ply:GetVoiceMode()], ply:GetLanguage() ), "Trebuchet24", w - size * 1.5 - 4, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end )

hook.Add( "HUDShouldDraw", "VRP:HideTalkIcon", function( name )
    if name == "CHudMessage" then return false end
end )