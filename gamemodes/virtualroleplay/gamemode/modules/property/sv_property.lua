util.AddNetworkString( "VRP:Property" )

net.Receive( "VRP:Property", VRP.NetworkReceiveAsMethods( 3, {
    --  buy/sell
    [0] = function( ply )
        local door = ply:GetLookedDoor()
        if not door then return end

        local owner = door:GetPropertyOwner()
        --  sell
        if owner == ply then
            door:UnlockProperty()
            door:SetPropertyOwner( NULL )
            door:ClearPropertyCoOwners()
            ply:AddMoney( VRP.PropertySellAmount )

            VRP.Notify( ply, VRP.GetPhrase( "sell_something", ply:GetLanguage(), {
                name = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
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
        if not door then return end

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

        --  sync co-owners
        net.Start( "VRP:Property" )
            net.WriteUInt( 1, 3 )
            net.WriteEntity( door )
            net.WriteTable( door:GetPropertyCoOwners() )
        net.Broadcast()

        VRP.Notify( ply, VRP.GetPhrase( "share_something", ply:GetLanguage(), {
            x = VRP.GetPhrase( "a_door", ply:GetLanguage() ),
            name = co_owner:GetRPName(),
            amount = VRP.FormatMoney( VRP.PropertyCoOwnAmount ),
        } ) )
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
