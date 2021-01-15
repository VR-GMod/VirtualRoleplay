CAMI.RegisterPrivilege( {
    Name = "vrp.bot",
    MinAccess = "admin"
} )

VRP.AddChatCommand( "bot", function( ply, args, str )
    if not CAMI.PlayerHasAccess( ply, "vrp.bot" ) then return VRP.GetPhrase( "no_access_command", ply:GetLanguage() ), 1 end

    local num = tonumber( args[1] ) or 1

    for i = 1, num do
        RunConsoleCommand( "bot" )
    end

    return "Added " .. num .. " bots."
end )