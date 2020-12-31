--  > Removing ugly default icon
hook.Add( "PostGamemodeLoaded", "VRP:DisableTalkIcon", function()
    game.ConsoleCommand( "mp_show_voice_icons 0\n" )
end )

--  > Global voice and ears
VRP.AddChatCommand( "global_voice", function( ply, args )
    if not ply:IsSuperAdmin() then return VRP.GetPhrase( "no_access_command", ply:GetLanguage() ), 1 end

    local global_voice = not ply:GetGlobalVoice()
    ply:SetGlobalVoice( global_voice )

    return VRP.GetPhrase( "global_voice_toggle", ply:GetLanguage(), {
        toggled = VRP.GetPhrase( enabled and "enabled" or "disabled", ply:GetLanguage() )
    } )
end )

VRP.AddChatCommand( "global_ears", function( ply, args )
    if not ply:IsSuperAdmin() then return VRP.GetPhrase( "no_access_command", ply:GetLanguage() ), 1 end

    local global_ears = not ply:GetGlobalEars()
    ply:SetGlobalEars( global_ears )

    return VRP.GetPhrase( "global_ears_toggle", ply:GetLanguage(), {
        toggled = VRP.GetPhrase( enabled and "enabled" or "disabled", ply:GetLanguage() )
    } )
end )

--  > Radio
VRP.AddChatCommand( "radiofreq", function( ply, args )
    local freq = math.max( 1, tonumber( args[1] or 1 ) )
    ply:SetRadioFrequency( freq )

    return VRP.GetPhrase( "radio_channel_switch", ply:GetLanguage(), { frequency = freq } )
end )

VRP.AddChatCommand( "radio", function( ply, args )
    local enabled = not ply:GetRadioEnabled()
    ply:SetRadioEnabled( enabled )

    return VRP.GetPhrase( "radio_toggle", ply:GetLanguage(), {
        toggled = VRP.GetPhrase( enabled and "on" or "off", ply:GetLanguage() )
    } )
end )

--  > I wanna scream, and shout, and let it all out
local voice_modes = {
    { name = "whispering", radius = 20000 },
    { name = "talking", radius = 100000 },
    { name = "yelling", radius = 200000 },
}

VRP.AddChatCommand( "voice_mode", function( ply, args )
    local voice_mode = math.Clamp( tonumber( args[1] or 1 ), 1, 3 )
    ply:SetVoiceMode( voice_mode )

    return VRP.GetPhrase( "voice_mode_switch", ply:GetLanguage(), {
        name = VRP.GetPhrase( voice_modes[ply:GetVoiceMode()].name, ply:GetLanguage(), { name = voice_modes[voice_mode].name } )
    } )
end )

function VRP.InHearableRadius( listener, talker )
    return listener:GetPos():DistToSqr( talker:GetPos() ) < voice_modes[talker:GetVoiceMode()].radius
end

function VRP.CanHear( listener, talker )
    if not talker:Alive() then return false end

    if talker:GetGlobalVoice() or listener:GetGlobalEars() then
        return true, false, 1
    end

    if listener:GetRadioEnabled() and talker:GetRadioEnabled() and listener:GetRadioFrequency() == talker:GetRadioFrequency() then
        return true, false, 2
    end

    if VRP.InHearableRadius( listener, talker ) then
        return true, true, 3
    end

    return false, false, 0
end

function GM:PlayerCanHearPlayersVoice( listener, talker )
    if listener == talker then return false end
    
    return VRP.CanHear( listener, talker )
end