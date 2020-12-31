util.AddNetworkString( "VRP:Property" )

net.Receive( "VRP:Property", VRP.NetworkReceiveAsMethods( 3, {
    --  buy
    [0] = function( ply )
        local door = ply:GetLookedDoor()
        if not door or not door:IsPropertyOwnable() then return end

        local owners = door:GetPropertyOwners()
        if #owners > 0 then return end

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
    end,
    --  create a copy of a key
    [1] = function( ply )
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
    end,
    --  drop key
    [2] = function( ply )
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
    end,
    --  toggle ownable
    [3] = function( ply )
        if not ply:IsSuperAdmin() then return end

        local door = ply:GetLookedDoor()
        if not door then return end

        door:SetPropertyOwnable( not door:IsPropertyOwnable() )
    end,
    --  sell key
    [4] = function( ply )
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
            door:UnlockProperty()
        end

        VRP.Notify( ply, VRP.GetPhrase( "sell_something", ply:GetLanguage(), {
            x = VRP.GetPhrase( "a_key", ply:GetLanguage() ),
            amount = VRP.FormatMoney( VRP.PropertySellAmount ),
        } ) )
    end,
    --  clear keys
    [5] = function( ply )
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
    end,
} ) )

function VRP.CreatePropertyKey( pos, id, title )
    local key = ents.Create( "vrp_key" )
    if not IsValid( key ) then return end
    key:SetPos( pos )
    key:Spawn()
    key:SetPropertyID( id )
    key:SetTitle( title )

    return key
end

--  meta
local ENTITY = FindMetaTable( "Entity" )

function ENTITY:LockProperty()
    self:Fire( "Lock" )
end

function ENTITY:UnlockProperty()
    self:Fire( "UnLock" )
end

function ENTITY:GetPropertyOwners()
    local owners = {}

    local door_id = self:GetPropertyID()
    for i, v in ipairs( player.GetAll() ) do
        if v:HasPropertyKeysOf( door_id ) then
            owners[#owners + 1] = v
        end
    end

    return owners
end

function ENTITY:SyncPropertyData( ply )
    --  sync if owning & ownable
    net.Start( "VRP:Property" )
        net.WriteUInt( 1, 3 )
        net.WriteEntity( self )
        net.WriteTable( {
            ownable = self:IsPropertyOwnable(),
        } )
        --net.WriteTable( self:GetPropertyData() )
    if ply then
        net.Send( ply )
    else
        net.Broadcast()
    end
end

--  property id
local property_id = 1
function ENTITY:GeneratePropertyID()
    self:SetPropertyID( property_id )
    property_id = property_id + 1
end

function ENTITY:SetPropertyID( id )
    assert( isnumber( id ), "#1 argument must be a number" )

    self:SetNWInt( "VRP:PropertyID", id )
end

--  player meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:AddPropertyKeysOf( id, title )
    self.vrp_keys = self.vrp_keys or {}
    self.vrp_keys[#self.vrp_keys + 1] = {
        id = id,
        title = title,
        --  other infos
    }

    --  sync
    net.Start( "VRP:Property" )
        net.WriteUInt( 2, 3 )
        net.WriteString( "add" )
        net.WriteTable( self.vrp_keys[#self.vrp_keys] )
    net.Send( self )
end

function PLAYER:RemovePropertyKeysOf( id, is_table_index )
    self.vrp_keys = self.vrp_keys or {}

    local index = is_table_index and id
    if not is_table_index then
        for i, v in ipairs( self.vrp_keys ) do
            if v.id == id then
                index = i
                break
            end
        end
    end

    if index then
        table.remove( self.vrp_keys, index )

        --  sync
        net.Start( "VRP:Property" )
            net.WriteUInt( 2, 3 )
            net.WriteString( "remove" )
            net.WriteUInt( index, 5 )
        net.Send( self )
    end
end
