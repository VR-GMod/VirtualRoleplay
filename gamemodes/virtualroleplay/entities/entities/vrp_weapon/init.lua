AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )

    local phys = self:GetPhysicsObject()
    if IsValid( phys ) then
        phys:Wake()
    end

    self:SetUseType( SIMPLE_USE )
end

function ENT:Use( ply )
    if not IsValid( ply ) or not ply:IsPlayer() then return end
    
    if not ply:HasWeapon( self:GetWeaponClass() ) then
        ply:Give( self:GetWeaponClass(), true )
    end
end
