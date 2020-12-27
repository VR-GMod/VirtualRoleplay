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

--  chat commands
if not SERVER then return end

VRP.AddChatCommand( "givemoney", function( ply, args )
    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return "Money: you must specify the amount!" end
    if not ply:CanAfford( amount ) then return "Money: you can't give more that you have!" end

    local target = ply:GetEyeTrace().Entity
    if not IsValid( target ) or not target:IsPlayer() or target:GetPos():Distance( ply:GetPos() ) > 256 then
        return "Money: you must look at someone or be closer!"
    end

    target:AddMoney( amount )
    ply:AddMoney( -amount )
end )
