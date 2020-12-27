--  chat commands

local function callback( ply, args )
    if #args == 0 then
        return "You must specify a valid name!", 1
    end

    ply:SetRPName( table.concat( args, " " ) )
    return ( "You changed your name to %s" ):format( ply:GetRPName() )
end

VRP.AddChatCommand( "rpname", callback )
VRP.AddChatCommand( "name", callback )
