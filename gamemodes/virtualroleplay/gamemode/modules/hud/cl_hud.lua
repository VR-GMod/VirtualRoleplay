local color_black = Color( 0, 0, 0 )
local color_background = Color( 31, 32, 31 )
local color_health = Color( 210, 32, 31 )
local color_armor = Color( 31, 32, 210 )

local bar_w, bar_h, gap, space

local function draw_bar( x, y, color, ratio, lerp_ratio )
    draw.RoundedBox( 8, x, y - bar_h - space / 2, bar_w, bar_h, color_background )
    draw.RoundedBox( 8, x + gap, y - bar_h - space / 2 + gap, bar_w - gap * 2, bar_h - gap * 2, color_black )
    draw.RoundedBox( 8, x + gap, y - bar_h - space / 2 + gap, lerp_ratio * bar_w - gap * 2, bar_h - gap * 2, ColorAlpha( color, 150 ) )
    draw.RoundedBox( 8, x + gap, y - bar_h - space / 2 + gap, ratio * bar_w - gap * 2, bar_h - gap * 2, color )
end

local infos = {
     {
         left = "name",
         right = function( ply )
             return ply:GetRPName()
         end,
     },
     {
         left = "money",
         right = function( ply )
             return VRP.FormatMoney( ply:GetMoney() ), color_white
         end,
     },
     {
         left = "job",
         right = function( ply )
             return ply:GetJob().name, team.GetColor( ply:Team() )
         end,
     }
}

local lerp_health_ratio, lerp_armor_ratio = 1, 0
function GM:HUDPaint()
    local ply = LocalPlayer()
    local text_height = draw.GetFontHeight( "Trebuchet24" )
    local text_space = text_height * 1.2
    space = ScrH() * .02

    --  get size
    local box_w, box_h = 0, 0
    for i, v in ipairs( infos ) do
        local text = v.right( ply )
        local text_w, text_h = surface.GetTextSize( text )
        box_w = math.max( box_w, text_w + surface.GetTextSize( VRP.GetPhrase( v.left, ply:GetLanguage() ) ) * 2 )
        box_h = math.max( box_h, text_h )
    end
    box_h = box_h + text_space * #infos - text_height + space / 2

    local x, y = space, ScrH() - space - box_h

    --  background
    draw.RoundedBox( 8, x, y, box_w, box_h, color_background )

    --  infos
    local info_y = y
    for i, v in ipairs( infos ) do
        local text, color = v.right( ply )

        draw.SimpleText( VRP.GetPhrase( v.left, ply:GetLanguage() ) .. ":", "Trebuchet24", x + space / 2, info_y + space / 3, color_white )
        draw.SimpleText( text, "Trebuchet24", x + box_w - space / 2, info_y + space / 3, color, TEXT_ALIGN_RIGHT )
        info_y = info_y + text_space
    end

    --  bars
    bar_w, bar_h = box_w, ScrH() * .02
    gap = ScrH() * .005

    --  health
    local ratio = math.Clamp( LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1 )
    lerp_health_ratio = Lerp( FrameTime() * 2, lerp_health_ratio, ratio )
    draw_bar( x, y, color_health, ratio, lerp_health_ratio )
    y = y - bar_h - space / 5

    --  armor
    local ratio = math.Clamp( LocalPlayer():Armor() / 100, 0, 1 )
    if ratio == 0 then return end
    lerp_armor_ratio = Lerp( FrameTime() * 2, lerp_armor_ratio, ratio )
    draw_bar( x, y, color_armor, ratio, lerp_armor_ratio )
end

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
}
function GM:HUDShouldDraw( name )
    if hide[name] then return false end

    return true
end
