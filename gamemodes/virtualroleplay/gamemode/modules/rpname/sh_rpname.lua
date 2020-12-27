VRP.AddPlayerNetworkVar( "String", "RPName", true, function( ply )
    return ply:SteamName()
end )

--  override name functions
local PLAYER = FindMetaTable( "Player" )
PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:GetName()
    return self.GetRPName and self:GetRPName() or self:SteamName()
end
PLAYER.Name = PLAYER.GetName
PLAYER.Nick = PLAYER.GetName

--  chat commands
if not SERVER then return end

local function callback( ply, args )
    if #args == 0 then
        return "You must specify a valid name!", 1
    end

    ply:SetRPName( table.concat( args, " " ) )
    return ( "You changed your name to %s" ):format( ply:GetRPName() )
end

VRP.AddChatCommand( "rpname", callback )
VRP.AddChatCommand( "name", callback )
