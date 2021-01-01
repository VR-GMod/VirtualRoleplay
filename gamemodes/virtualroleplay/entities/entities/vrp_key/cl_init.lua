include( "shared.lua" )

local font = "Trebuchet18"
local color_background = Color( 31, 32, 31, 175 )
function ENT:Draw()
    self:DrawModel()

    --  pos & ang
    local pos = self:GetPos()
    local ang = self:GetAngles()
    ang:RotateAroundAxis( ang:Up(), -90 )
    if math.abs( ang.z ) > 90 then --  always look up
        ang.z = ang.z + 180
    else
        pos = pos + ang:Up() * 1
    end

    --  hud
    cam.Start3D2D( pos, ang, .1 )
        local text = self:GetTitle()

        surface.SetFont( font )
        local w, h = surface.GetTextSize( text )
        w, h = w * 1.25, h * 1.25

        draw.RoundedBox( 8, -w / 2, -h / 2, w, h, color_background )
        draw.SimpleText( text, font, 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end
