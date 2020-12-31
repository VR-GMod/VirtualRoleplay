ENT.Type = "anim"
ENT.Base = "base_gmodentity"

ENT.PrintName = "Key"
ENT.Author = "Guthen"
ENT.Spawnable = false

function ENT:SetupDataTables()
    self:NetworkVar( "String", 0, "Title" )
end
