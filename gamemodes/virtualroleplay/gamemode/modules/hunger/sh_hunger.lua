VRP.AddPlayerNetworkVar( "Int", "Hunger", true, function( ply )
    return VRP.HungerStartAmount or 0
end )

--  global variables
VRP.HungerEnabled = true
VRP.HungerStartAmount = 100
VRP.HungerStarvingAmount = 1 -- how many per HungerStarvingTime
VRP.HungerStarvingTime = 10 -- in seconds

local PLAYER = FindMetaTable( "Player" )

function PLAYER:AddHunger( amount )
    self:SetHunger( self:GetHunger() + amount )
end