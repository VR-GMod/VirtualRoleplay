VRP.AddPlayerNetworkVar( "Int", "Money", true )

--  money wrapper
local PLAYER = FindMetaTable( "Player" )

function PLAYER:AddMoney( amount )
    self:SetMoney( self:GetMoney() + amount )
end

function PLAYER:CanAfford( amount )
    return self:GetMoney() >= amount
end
