VRP.AddChatCommand( "buy", function( ply, args )
    if not args[1] then return VRP.GetPhrase( "no_input", ply:GetLanguage() ), 1 end

    local item = VRP.Market[ tonumber( args[1] ) ]

    if not item then return "N/A" end

    if not ply:CanAfford( item.price ) then return VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 end

    ply:AddMoney( -item.price )

    if item.type == "weapon" then
        if ply:HasWeapon( item.class ) then
            local ent = ents.Create( "vrp_weapon" )
            ent:SetModel( item.model )
            ent:SetWeaponClass( item.class )
            ent:SetPos( ply:GetDroppableLookPos() )
            ent:Spawn()
        else
            ply:Give( item.class, true )
        end
    elseif item.type == "entity" then
        local ent = ents.Create( item.class )
        ent:SetPos( ply:GetDroppableLookPos() )
        ent:Spawn()
    end
    
    return VRP.GetPhrase( "buy_something", ply:GetLanguage(), {
        amount = VRP.FormatMoney( item.price ),
        x = item.name
    } )
end )