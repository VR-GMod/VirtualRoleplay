--  globals
VRP.PropertyMaxKeysBytes = 5 --  how many bits stocking the keys (default: 5 (31 keys))
VRP.PropertyBuyAmount = 45 --  how much for buying a key
VRP.PropertyCopyAmount = 30 --  how much for copying a key
VRP.PropertySellAmount = 25 --  how much for selling a key
VRP.PropertyClearKeysAmount = 150 --  how much for changing the keylock
VRP.PropertyClearGiveKeys = 1 --  how many keys we give on changing the keylock
VRP.PropertyClasses = {
    ["prop_door_rotating"] = true,
    ["func_door"] = true,
    ["func_door_rotating"] = true,
}

function VRP.GetDoors( callback )
    local doors = {}

    for class, v in pairs( VRP.PropertyClasses ) do
        for i, door in ipairs( ents.FindByClass( class ) ) do
            if not callback or callback( door ) then
                doors[#doors + 1] = door
            end
        end
    end

    return doors
end

--  entity meta
local ENTITY = FindMetaTable( "Entity" )

--  class checks
function ENTITY:IsDoor()
    return VRP.PropertyClasses[self:GetClass()]
end

function ENTITY:IsClassOwnable()
    return self:IsDoor() or self:IsVehicle()
end

--  property ownable
function ENTITY:SetPropertyOwnable( toggle )
    self.vrp_ownable = toggle

    --  clear owners
    if SERVER then
        if not toggle then
            -- self:SetPropertyOwner( NULL )
            -- self:ClearPropertyCoOwners() --  sync
            for i, v in ipairs( self:GetPropertyOwners() ) do
                v:RemovePropertyKeysOf( self )
            end
        end

        --  sync
        self:SyncPropertyData()
    end
end

function ENTITY:IsPropertyOwnable()
    return self.vrp_ownable == nil and true or self.vrp_ownable
end

--  property accessors
function ENTITY:GetPropertyID()
    return self:GetNWInt( "VRP:PropertyID", -1 )
end

--  player meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:HasPropertyKeysOf( id )
    if id < 0 then return false end --  -1 should not be a valid key ID

    for i, v in ipairs( self.vrp_keys or {} ) do
        if v.id == id then
            return true
        end
    end

    return false
end

function PLAYER:HasPropertyKeysLimit()
    return self.vrp_keys and #self.vrp_keys >= 2 ^ VRP.PropertyMaxKeysBytes - 1 or false
end

function PLAYER:GetLookedDoor()
    local ent = self:GetEyeTrace().Entity
    if not IsValid( ent ) or not ent:IsClassOwnable() then return end
    if ent:GetPos():Distance( self:GetPos() ) > 74 then return end

    return ent
end
