--  > Removing ugly default icon
hook.Add( "PostGamemodeLoaded", "VRP:DisableTalkIcon", function()
    game.ConsoleCommand( "mp_show_voice_icons 0\n" )
end )

--  > Global voice and ears
VRP.AddChatCommand( "global_voice", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local global_voice = not ply:GetGlobalVoice()
    ply:SetGlobalVoice( global_voice )

    return ( "You %s global voice mode." ):format( global_voice and "enabled" or "disabled" )
end )

VRP.AddChatCommand( "global_ears", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local global_ears = not ply:GetGlobalEars()
    ply:SetGlobalEars( global_ears )

    return ( "You %s global ears mode." ):format( global_ears and "enabled" or "disabled" )
end )

--  > Radio
VRP.AddChatCommand( "radiofreq", function( ply, args )
    local freq = math.max( 1, tonumber( args[1] or 1 ) )
    ply:SetRadioFrequency( freq )

    return ( "Switched radio channel to %sHz." ):format( freq )
end )

VRP.AddChatCommand( "radio", function( ply, args )
    local enabled = not ply:GetRadioEnabled()
    ply:SetRadioEnabled( enabled )

    return ( "Turned %s the radio." ):format( enabled and "on" or "off" )
end )

--  > I wanna scream, and shout, and let it all out
local voice_modes = {
    { name = "whisper", radius = 20000 },
    { name = "talk", radius = 100000 },
    { name = "shout", radius = 200000 },
}

VRP.AddChatCommand( "voice_mode", function( ply, args )
    local voice_mode = math.Clamp( tonumber( args[1] or 1 ), 1, 3 )
    ply:SetVoiceMode( voice_mode )

    return ( "Switched to %s mode." ):format( voice_modes[voice_mode].name )
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