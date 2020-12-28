--  chat commands

VRP.AddChatCommand( "givemoney", function( ply, args )
    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end
    if not ply:CanAfford( amount ) then return VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 end

    local target = ply:GetEyeTrace().Entity
    if not IsValid( target ) or not target:IsPlayer() or target:GetPos():Distance( ply:GetPos() ) > 256 then
        return VRP.GetPhrase( "look_someone_or_closer", ply:GetLanguage() ), 1
    end

    local format_money = VRP.FormatMoney( amount )
    target:AddMoney( amount )
    VRP.Notify( target, VRP.GetPhrase( "receive_money", ply:GetLanguage(), {
        amount = format_money,
        name = ply:GetRPName(),
    } ) )

    ply:AddMoney( -amount )
    return VRP.GetPhrase( "give_money", ply:GetLanguage(), {
        amount = format_money,
        name = target:GetRPName(),
    } )
end )

VRP.AddChatCommand( "setmoney", function( ply, args )
    if not ply:IsSuperAdmin() then return VRP.GetPhrase( "not_enough_privilege", ply:GetLanguage() ), 1 end

    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end

    ply:SetMoney( amount )
    return VRP.GetPhrase( "set_money", ply:GetLanguage(), {
        amount = VRP.FormatMoney( amount ),
    } )
end )
