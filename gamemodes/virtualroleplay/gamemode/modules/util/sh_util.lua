
function VRP.NetworkReceiveAsMethods( uint_bytes, methods )
    return function( len, ply )
        local method = net.ReadUInt( uint_bytes )
        if not methods[method] then return end

        methods[method]( ply or LocalPlayer(), len )
    end
end

function VRP.Format( text, params )
    return text:gsub( "%${([%w_%d]+)}", function( str )
        return params[str:Trim()] or "?"
    end )
end

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
