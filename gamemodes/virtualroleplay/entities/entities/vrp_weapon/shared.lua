ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Weapon"
ENT.Author = "Nogitsu"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "WeaponClass" )
end
