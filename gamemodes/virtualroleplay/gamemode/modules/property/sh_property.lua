--  globals
VRP.PropertyBuyAmount = 45
VRP.PropertyCoOwnAmount = 15
VRP.PropertySellAmount = 25

--  entity meta
local ENTITY = FindMetaTable( "Entity" )

--  class checks
local door_classes = {
    ["prop_door_rotating"] = true,
    ["func_door"] = true,
    ["func_door_rotating"] = true,
}
function ENTITY:IsDoor()
    return door_classes[self:GetClass()]
end

function ENTITY:IsClassOwnable()
    return self:IsDoor() or self:IsVehicle()
end

--  property ownable
function ENTITY:SetPropertyOwnable( toggle )
    self.vrp_ownable = toggle

    --  clear owners
    if not toggle then
        self:SetPropertyOwner( NULL )
        self:ClearCoOwners()
    end
end

function ENTITY:IsPropertyOwnable()
    return self.vrp_ownable == nil and true or self.vrp_ownable
end

--  property accessors
function ENTITY:SetPropertyOwner( ply )
    if not self:IsPropertyOwnable() then return false end

    self:SetNWEntity( "VRP:Owner", ply )
end

function ENTITY:GetPropertyOwner()
    return self:GetNWEntity( "VRP:Owner" )
end

--  co-owners
function ENTITY:GetPropertyCoOwners()
    return IsValid( self:GetPropertyOwner() ) and self.vrp_co_owners and table.Copy( self.vrp_co_owners )
end

function ENTITY:AddPropertyCoOwner( ply )
    if not self:IsPropertyOwnable() then return false end

    self.vrp_co_owners = self.vrp_co_owners or {}
    self.vrp_co_owners[ply] = true

    return true
end

function ENTITY:RemovePropertyCoOwner( ply )
    if self.vrp_co_owners[ply] then
        self.vrp_co_owners[ply] = nil
        return true
    end

    return false
end

function ENTITY:ClearPropertyCoOwners()
    self.vrp_co_owners = {}
end

function ENTITY:IsPropertyCoOwnedBy( ply )
    return self.vrp_co_owners and self.vrp_co_owners[ply] or false
end

function ENTITY:IsPropertyOwnedBy( ply )
    return self:GetPropertyOwner() == ply
end

--  player meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetLookedDoor()
    local ent = self:GetEyeTrace().Entity
    if not IsValid( ent ) or not ent:IsClassOwnable() then return end
    if ent:GetPos():Distance( self:GetPos() ) > 74 then return end

    return ent
end
