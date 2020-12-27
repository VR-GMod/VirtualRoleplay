VRP.AddPlayerNetworkVar( "Int", "Money", true, function( ply )
    return VRP.MoneyStartAmount or 0
end )

--  global variables
VRP.MoneyStartAmount = 1000
VRP.MoneyAttachLeft = true
VRP.MoneyCurrency = "$"

function VRP.FormatMoney( money )
    return ( VRP.MoneyAttachLeft and VRP.MoneyCurrency or "" )
            .. string.Comma( money )
            .. ( VRP.MoneyAttachLeft and "" or VRP.MoneyCurrency )
end

--  meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:AddMoney( amount )
    self:SetMoney( self:GetMoney() + amount )
end

function PLAYER:CanAfford( amount )
    return self:GetMoney() >= amount
end
