VRP.AddPlayerNetworkVar( "String", "RPName", true )

--  override name functions
local PLAYER = FindMetaTable( "Player" )
PLAYER.SteamName = PLAYER.SteamName or PLAYER.Name

function PLAYER:GetName()
    return self.GetRPName and self:GetRPName() or self:SteamName()
end
PLAYER.Name = PLAYER.GetName
PLAYER.Nick = PLAYER.GetName
