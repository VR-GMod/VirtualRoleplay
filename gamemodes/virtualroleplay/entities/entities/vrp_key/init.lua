AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/props_c17/TrapPropeller_Lever.mdl" )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    --  phys
    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
    end

    --  use
    self:SetUseType( SIMPLE_USE )
end

function ENT:Use( ply )
    if not IsValid( ply ) or not ply:IsPlayer() then return end
    if ply:HasPropertyKeysLimit() then
        return VRP.Notify( ply, VRP.GetPhrase( "reach_limit_of", ply:GetLanguage(), {
            x = VRP.GetPhrase( "key", ply:GetLanguage() ),
        } ) )
    end

    --  give money
    ply:AddPropertyKeysOf( self:GetPropertyID(), self:GetTitle() )
    self:Remove()

    --  notify
    VRP.Notify( ply, VRP.GetPhrase( "find_something", ply:GetLanguage(), {
        x = self:GetTitle(),
    } ) )
end
