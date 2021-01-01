function VRP.CreateMoneyBag( pos, amount )
    local money = ents.Create( "vrp_money_bag" )
    if not IsValid( money ) then return end
    money:SetPos( pos )
    money:Spawn()
    money:SetMoney( amount )

    return money
end

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
    VRP.Notify( target, VRP.GetPhrase( "receive_something", ply:GetLanguage(), {
        x = format_money,
        name = ply:GetRPName(),
    } ) )

    ply:AddMoney( -amount )
    
    return VRP.GetPhrase( "give_something", ply:GetLanguage(), {
        x = format_money,
        name = target:GetRPName(),
    } )
end )

VRP.AddChatCommand( "dropmoney", function( ply, args )
    local amount = tonumber( args[1] )
    if not amount or amount <= 0 then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end
    if not ply:CanAfford( amount ) then return VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 end

    VRP.CreateMoneyBag( ply:GetDroppableLookPos(), amount )

    ply:AddMoney( -amount )

    return VRP.GetPhrase( "drop_something", ply:GetLanguage(), {
        x = VRP.FormatMoney( amount ),
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
