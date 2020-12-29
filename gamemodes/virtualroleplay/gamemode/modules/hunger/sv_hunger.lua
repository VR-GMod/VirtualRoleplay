local PLAYER = FindMetaTable( "Player" )
    
timer.Create( "VRP:HungerThink", VRP.HungerStarvingTime, 0, function()
    if not VRP.HungerEnabled then return end

    for _, v in ipairs( player.GetAll() ) do
        if not v:Alive() then continue end

        if v:GetHunger() <= 0 then
            if v:Health() <= VRP.HungerStarvingAmount + 1 then continue end

            local d = DamageInfo()
            d:SetDamage( VRP.HungerStarvingAmount )
            d:SetDamageType( DMG_DIRECT ) 

            v:TakeDamageInfo( d )
        else
            v:SetHunger( v:GetHunger() - VRP.HungerStarvingAmount )
        end
    end
end )

-- commands
VRP.AddChatCommand( "sethunger", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local amount = tonumber( args[1] )
    if not amount or amount < 0 then return "You must specify the amount!", 1 end

    ply:SetHunger( amount )
    return ( "You set your hunger to %s!" ):format( amount )
end )


VRP.AddChatCommand( "resethunger", function( ply, args )
    if not ply:IsSuperAdmin() then return "You must be a SuperAdmin", 1 end

    local amount = tonumber( args[1] )

    ply:SetHunger( VRP.HungerStartAmount )
    return ( "You reset your hunger!" )
end )
