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
    if not amount or amount <= 0 then return "You must specify the amount!", 1 end
    if not ply:CanAfford( amount ) then return "You can't give more that you have!", 1 end

    local target = ply:GetEyeTrace().Entity
    if not IsValid( target ) or not target:IsPlayer() or target:GetPos():Distance( ply:GetPos() ) > 256 then
        return "You must look at someone or be closer!", 1
    end

    local format_money = VRP.FormatMoney( amount )
    target:AddMoney( amount )
    VRP.Notify( target, ( "You received %s from %s!" ):format( format_money, ply:GetRPName() ) )

    ply:AddMoney( -amount )
    return ( "You gave %s to %s!" ):format( format_money, target:GetRPName() )
end )

VRP.AddChatCommand( "setmoney", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return "You must specify the amount!", 1 end

    ply:SetMoney( amount )
    return ( "You set your money to %s!" ):format( VRP.FormatMoney( amount ) )
end )
