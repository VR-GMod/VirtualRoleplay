--  globals
VRP.PropertyBuyAmount = 45
VRP.PropertyCoOwnAmount = 15
VRP.PropertySellAmount = 25
VRP.PropertyClasses = {
    ["prop_door_rotating"] = true,
    ["func_door"] = true,
    ["func_door_rotating"] = true,
}

function VRP.GetDoors( only_owned )
    local doors = {}

    for class, v in pairs( VRP.PropertyClasses ) do
        for i, door in ipairs( ents.FindByClass( class ) ) do
            if not only_owned or IsValid( door:GetPropertyOwner() ) then
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
    if not toggle then
        self:SetPropertyOwner( NULL )
        self:ClearPropertyCoOwners() --  sync
    elseif SERVER then
        --  sync
        self:SyncPropertyData()
    end
end

function ENTITY:IsPropertyOwnable()
    return self.vrp_ownable == nil and true or self.vrp_ownable
end

--  property accessors
function ENTITY:SetPropertyOwner( ply )
    if IsValid( ply ) and not self:IsPropertyOwnable() then return false end

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

    --  sync data
    if SERVER then
        self:SyncPropertyData()
    end

    return true
end

function ENTITY:RemovePropertyCoOwner( ply )
    if self.vrp_co_owners[ply] then
        self.vrp_co_owners[ply] = nil

        --  sync data
        if SERVER then
            self:SyncPropertyData()
        end

        return true
    end

    return false
end

function ENTITY:ClearPropertyCoOwners()
    self.vrp_co_owners = {}

    --  sync data
    if SERVER then
        self:SyncPropertyData()
    end
end

function ENTITY:IsPropertyCoOwnedBy( ply )
    return self.vrp_co_owners and self.vrp_co_owners[ply] or false
end

function ENTITY:IsPropertyOwnedBy( ply )
    return self:GetPropertyOwner() == ply
end

function ENTITY:ClearProperty()
    if SERVER then
        self:UnlockProperty()
    end

    self:SetPropertyOwner( NULL )
    self:ClearPropertyCoOwners()
end

function ENTITY:GetPropertyData()
    return {
        --owner = self:GetPropertyOwner(),
        co_owners = self.vrp_co_owners,
        ownable = self:IsPropertyOwnable(),
    }
end

--  player meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetLookedDoor()
    local ent = self:GetEyeTrace().Entity
    if not IsValid( ent ) or not ent:IsClassOwnable() then return end
    if ent:GetPos():Distance( self:GetPos() ) > 74 then return end

    return ent
end
