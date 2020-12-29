ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Money Bag"
ENT.Author = "Guthen"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar( "Int", 0, "Money" )
end
