include( "shared.lua" )

local font = "Trebuchet18"
local color_background = Color( 31, 32, 31, 175 )
function ENT:Draw()
    self:DrawModel()

    --  pos & ang
    local pos = self:GetPos()
    local ang = self:GetAngles()
    if math.abs( ang.z ) > 90 then --  always look up
        ang.z = ang.z + 180
    else
        pos = pos + ang:Up() * .9
    end

    --  hud
    cam.Start3D2D( pos, ang, .1 )
        local format_money = VRP.FormatMoney( self:GetMoney() )

        surface.SetFont( font )
        local w, h = surface.GetTextSize( format_money )
        w, h = w * 1.25, h * 1.25

        draw.RoundedBox( 8, -w / 2, -h / 2, w, h, color_background )
        draw.SimpleText( format_money, font, 0, 0, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    cam.End3D2D()
end
