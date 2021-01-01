--  meta
local PLAYER = FindMetaTable( "Player" )

function PLAYER:GetDroppableLookPos()
    return util.TraceLine( {
        start = self:EyePos(),
        endpos = self:EyePos() + self:GetAimVector() * 50,
        filter = function( ent )
            return not ent:IsPlayer()
        end,
    } ).HitPos
end
