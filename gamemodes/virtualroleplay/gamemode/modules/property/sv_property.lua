util.AddNetworkString( "VRP:Property" )

net.Receive( "VRP:Property", VRP.NetworkReceiveAsMethods( 3, {
    --  buy/sell
    [0] = function( ply )
        local door = ply:GetLookedDoor()
        if not door or not door:IsPropertyOwnable() then return end

        local owner = door:GetPropertyOwner()
        --  sell
        if owner == ply then
            door:ClearProperty()
            ply:AddMoney( VRP.PropertySellAmount )

            VRP.Notify( ply, VRP.GetPhrase( "sell_something", ply:GetLanguage(), {
                x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
                amount = VRP.FormatMoney( VRP.PropertySellAmount ),
            } ) )
        --  buy
        elseif not IsValid( owner ) then
            if not ply:CanAfford( VRP.PropertyBuyAmount ) then
                return VRP.Notify( ply, VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 )
            end

            door:SetPropertyOwner( ply )
            ply:AddMoney( -VRP.PropertyBuyAmount )

            VRP.Notify( ply, VRP.GetPhrase( "buy_something", ply:GetLanguage(), {
                x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
                amount = VRP.FormatMoney( VRP.PropertyBuyAmount ),
            } ) )
        end
    end,
    --  add co-owner
    [1] = function( ply )
        local door = ply:GetLookedDoor()
        if not door or not door:IsPropertyOwnable() then return end

        local owner = door:GetPropertyOwner()
        if not ( owner == ply ) then return end

        local co_owner = net.ReadEntity()
        if not IsValid( co_owner ) or not co_owner:IsPlayer() then return end
        if door:IsPropertyCoOwnedBy( co_owner ) then return end

        --  owner pay co owning
        if not ply:CanAfford( VRP.PropertyCoOwnAmount ) then
            return VRP.Notify( ply, VRP.GetPhrase( "not_enough_money", ply:GetLanguage() ), 1 )
        end

        door:AddPropertyCoOwner( co_owner )
        ply:AddMoney( -VRP.PropertyCoOwnAmount )

        VRP.Notify( ply, VRP.GetPhrase( "share_something", ply:GetLanguage(), {
            x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
            name = co_owner:GetRPName(),
            amount = VRP.FormatMoney( VRP.PropertyCoOwnAmount ),
        } ) )
    end,
    --  remove co-owner
    [2] = function( ply )
        local door = ply:GetLookedDoor()
        if not door or not door:IsPropertyOwnable() then return end

        local owner = door:GetPropertyOwner()
        if not ( owner == ply ) then return end

        local co_owner = net.ReadEntity()
        if not IsValid( co_owner ) or not co_owner:IsPlayer() then return end
        if not door:IsPropertyCoOwnedBy( co_owner ) then return end

        door:RemovePropertyCoOwner( co_owner )

        VRP.Notify( ply, VRP.GetPhrase( "remove_someone", ply:GetLanguage(), {
            x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
            name = co_owner:GetRPName(),
        } ) )
    end,
    --  toggle ownable
    [3] = function( ply )
        if not ply:IsSuperAdmin() then return end

        local door = ply:GetLookedDoor()
        if not door then return end

        door:SetPropertyOwnable( not door:IsPropertyOwnable() )
    end,
    --  ask all properties sync
    [5] = function( ply )
        VRP.SyncAllPropertiesData( ply )
    end,
} ) )

--  meta
local ENTITY = FindMetaTable( "Entity" )

function ENTITY:LockProperty()
    self:Fire( "Lock" )
end

function ENTITY:UnlockProperty()
    self:Fire( "UnLock" )
end

function ENTITY:SyncPropertyData( ply )
    --  sync co-owners & ownable
    net.Start( "VRP:Property" )
        net.WriteUInt( 1, 3 )
        net.WriteEntity( self )
        net.WriteTable( self:GetPropertyData() )
    if ply then
        net.Send( ply )
    else
        net.Broadcast()
    end
end

function VRP.SyncAllPropertiesData( ply )
    local data = {}
    for i, door in ipairs( VRP.GetDoors( true ) ) do
        data[door] = door:GetPropertyData()
    end

    --  send data
    net.Start( "VRP:Property" )
        net.WriteUInt( 2, 3 )
        net.WriteTable( data )
    net.Send( ply )
end

--  remove property to disconnected players
hook.Add( "PlayerDisconnected", "VRP:Property", function( ply )
    local owned_count, co_owned_count = 0, 0
    for i, door in ipairs( VRP.GetDoors( true ) ) do
        if door:IsPropertyOwnedBy( ply ) then
            door:ClearProperty()
            owned_count = owned_count + 1
        elseif door:IsPropertyCoOwnedBy( ply ) then
            door:RemovePropertyCoOwner( ply )
            co_owned_count = co_owned_count + 1
        end
    end

    if owned_count <= 0 and co_owned_count <= 0 then return end
    VRP.Print( "removed %d owned properties and %d co-owned properties of %s", owned_count, co_owned_count, ply:GetRPName() )
end )
