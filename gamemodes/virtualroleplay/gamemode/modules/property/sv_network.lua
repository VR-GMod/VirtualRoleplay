util.AddNetworkString( "VRP:PropertyMenu" )
util.AddNetworkString( "VRP:PropertySyncKeys" )

util.AddNetworkString( "VRP:PropertyBuy" )
util.AddNetworkString( "VRP:PropertyCopy" )
util.AddNetworkString( "VRP:PropertyClear" )
util.AddNetworkString( "VRP:PropertyDrop" )
util.AddNetworkString( "VRP:PropertyOwnable" )
util.AddNetworkString( "VRP:PropertyDestroy" )
util.AddNetworkString( "VRP:PropertySell" )

--  buy
net.Receive( "VRP:PropertyBuy", function( len, ply )
    local door = ply:GetLookedDoor()
    if not door or not door:IsPropertyOwnable() then return end

    local owners = door:GetPropertyOwners()
    if door:IsPropertyOwned() then return end

    if ply:HasPropertyKeysLimit() then
        return VRP.Notify( ply, VRP.GetPhrase( "reach_limit_of", ply:GetLanguage(), {
            x = VRP.GetPhrase( "key", ply:GetLanguage() ),
        } ) )
    end

    if not ply:CanAfford( VRP.PropertyBuyAmount ) then
        return VRP.Notify( ply, VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 )
    end

    --  generate property id if not already exists
    if door:GetPropertyID() == -1 then --  get an ID
        door:GeneratePropertyID()
    end

    --  add key
    ply:AddPropertyKeysOf( door:GetPropertyID() )
    ply:AddMoney( -VRP.PropertyBuyAmount )

    --  notify
    VRP.Notify( ply, VRP.GetPhrase( "buy_something", ply:GetLanguage(), {
        x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
        amount = VRP.FormatMoney( VRP.PropertyBuyAmount ),
    } ) )
end )

--  create a copy of a key
net.Receive( "VRP:PropertyCopy", function( len, ply )
    local i = net.ReadUInt( VRP.PropertyMaxKeysBytes )
    if not ply.vrp_keys[i] then return end
    if ply:HasPropertyKeysLimit() then
        return VRP.Notify( ply, VRP.GetPhrase( "reach_limit_of", ply:GetLanguage(), {
            x = VRP.GetPhrase( "key", ply:GetLanguage() ),
        } ) )
    end

    if not ply:CanAfford( VRP.PropertyCopyAmount ) then
        return VRP.Notify( ply, VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 )
    end

    --  add key
    ply:AddPropertyKeysOf( ply.vrp_keys[i].id )
    ply:AddMoney( -VRP.PropertyCopyAmount )

    --  notify
    VRP.Notify( ply, VRP.GetPhrase( "buy_something", ply:GetLanguage(), {
        x = VRP.GetPhrase( "a_copy_key", ply:GetLanguage() ),
        amount = VRP.FormatMoney( VRP.PropertyCopyAmount ),
    } ) )
end )

--  drop key
net.Receive( "VRP:PropertyDrop", function( len, ply )
    local i = net.ReadUInt( VRP.PropertyMaxKeysBytes )
    if not ply.vrp_keys[i] then return end

    local title = net.ReadString()

    --  create key
    VRP.CreatePropertyKey( ply:GetDroppableLookPos(), ply.vrp_keys[i].id, title or "Door Unknown" )
    ply:RemovePropertyKeysOf( i, true )

    --  notify
    VRP.Notify( ply, VRP.GetPhrase( "delete_something", ply:GetLanguage(), {
        x = VRP.GetPhrase( "a_key", ply:GetLanguage() ),
    } ) )
end )

--  toggle ownable
net.Receive( "VRP:PropertyOwnable", function( len, ply )
    if not ply:IsSuperAdmin() then return end

    local door = ply:GetLookedDoor()
    if not door then return end

    door:SetPropertyOwnable( not door:IsPropertyOwnable() )
end )

--  sell key
net.Receive( "VRP:PropertySell", function( len, ply )
    local i = net.ReadUInt( VRP.PropertyMaxKeysBytes )
    if not ply.vrp_keys[i] then return end

    local id = ply.vrp_keys[i].id
    ply:RemovePropertyKeysOf( i, true )
    ply:AddMoney( VRP.PropertySellAmount )

    --  unlock doors
    local doors = VRP.GetDoors( function( door )
        return door:GetPropertyID() == id
    end )
    for i, door in ipairs( doors ) do
        if #door:GetPropertyOwners() > 0 then break end
        door:UnlockProperty()
    end

    VRP.Notify( ply, VRP.GetPhrase( "sell_something", ply:GetLanguage(), {
        x = VRP.GetPhrase( "a_key", ply:GetLanguage() ),
        amount = VRP.FormatMoney( VRP.PropertySellAmount ),
    } ) )
end )

--  clear keys
net.Receive( "VRP:PropertyClear", function( len, ply )
    local door = ply:GetLookedDoor()
    if not door or not door:IsPropertyOwnable() then return end
    if not ply:HasPropertyKeysOf( door:GetPropertyID() ) then return end

    if not ply:CanAfford( VRP.PropertyClearKeysAmount ) then
        return VRP.Notify( ply, VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 )
    end

    --  re-generate ID
    door:GeneratePropertyID()
    local id = door:GetPropertyID()
    local doors = VRP.GetDoors( function( _door )
        return not ( _door == door ) and _door:GetPropertyID() == id
    end )
    for i, door in ipairs( doors ) do
        door:SetPropertyID( id )
    end

    --  new key
    for i = 1, VRP.PropertyClearGiveKeys do
        ply:AddPropertyKeysOf( id )
    end
    ply:AddMoney( -VRP.PropertyClearKeysAmount )

    VRP.Notify( ply, VRP.GetPhrase( "clear_keys", ply:GetLanguage(), {
        amount = VRP.FormatMoney( VRP.PropertyClearKeysAmount ),
        n = VRP.PropertyClearGiveKeys,
    } ) )
end )
