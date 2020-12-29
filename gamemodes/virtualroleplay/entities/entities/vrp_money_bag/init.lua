AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

function ENT:Initialize()
    self:SetModel( "models/props/cs_assault/Money.mdl" )
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

    --  give money
    local amount = self:GetMoney()
    ply:AddMoney( amount )
    self:Remove()

    --  notify
    VRP.Notify( ply, VRP.GetPhrase( "find_money", ply:GetLanguage(), {
        amount = VRP.FormatMoney( amount ),
    } ) )
end
