CAMI.RegisterPrivilege( {
    Name = "vrp.kick",
    MinAccess = "admin"
} )

VRP.AddChatCommand( "kick", function( ply, args, str )
    if not CAMI.PlayerHasAccess( ply, "vrp.kick" ) then return VRP.GetPhrase( "no_access_command", ply:GetLanguage() ), 1 end

    local target, reason = string.match( str, "\"(.+)\"%s(.+)" )

    if not target then
        if not args[1] then return "Invalid target.", 1 end

        target = args[1]
        reason = string.sub( str, #target + 1 ):Trim()
    end

    reason = ( reason == "" ) and "Kicked from the server." or reason

    
    local targets = {}

    for k, v in ipairs( player.GetAll() ) do
        if not string.match( v:GetName():lower(), target:lower() ) then continue end

        v:Kick( reason )
    end
end )