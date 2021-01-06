local color_background = Color( 0, 0, 0, 175 )
local color_health = Color( 255, 71, 87 )
local color_armor = Color( 30, 144, 255 )
local color_hunger = Color( 46, 213, 115 )

surface.CreateFont( "VRP:HUD24", {
    font = "Bahnschrift",
    size = 24
} )

surface.CreateFont( "VRP:HUD18", {
    font = "Bahnschrift",
    size = 18
} )

local armor, health, hunger = 0, 0, 0
function GM:HUDPaint()
    local ply = LocalPlayer()

    local name = ply:GetRPName()
    surface.SetFont( "VRP:HUD24" )
    local name_w = surface.GetTextSize( name )

    local money = VRP.FormatMoney( ply:GetMoney() )
    surface.SetFont( "VRP:HUD18" )
    local money_w = surface.GetTextSize( money )

    --  > Calculating sizes and pos
    local w = math.max( 300, name_w + money_w + 150 )
    local total_w = w - 23
    local h = 80
    local x = 10
    local y = ScrH() - h - 10

    --  > Background
    surface.SetDrawColor( color_background )
    surface.DrawRect( x, y, w, h )

    x = x + 10
    y = y + 10

    -- > Name & Money
    draw.SimpleText( name, "VRP:HUD24", x, y, color_white )
    draw.SimpleText( money, "VRP:HUD18", x + total_w, y + 4, color_white, TEXT_ALIGN_RIGHT )

    --  > Separators
    y = y + 30

    surface.SetDrawColor( color_white )
    for i = 0, w - 22, ( w - 22 ) / 5 do
        surface.DrawRect( x + math.floor( i ), y, 2, 30 )
    end

    x = x + 2
    y = y + ( VRP.HungerEnabled and 3 or 5 )

    --  > Animations
    health = Lerp( FrameTime() * 5, health, ply:Health() )
    armor = Lerp( FrameTime() * 5, armor, ply:Armor() )
    hunger = Lerp( FrameTime() * 5, hunger, ply:GetHunger() )

    local armor_w = armor <= 0.9 and 0 or math.min( armor, total_w / 2 )
    local health_w = ( total_w - armor_w ) * math.min( 100, health ) / 100

    --  > Health
    surface.SetDrawColor( color_health )
    surface.DrawRect( x, y, health_w, 20 )

    local health_text = math.ceil( health ) .. "%"
    surface.SetFont( "VRP:HUD18" )
    if health_w > surface.GetTextSize( health_text ) + 10 then
        draw.SimpleText( health_text, "VRP:HUD18", x + health_w - 5, y + 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end

    --  > Armor
    if armor_w > 0 then
        surface.SetDrawColor( color_armor )
        surface.DrawRect( x + health_w, y, armor_w, 20 )

        local armor_text = math.ceil( armor ) .. "%"
        surface.SetFont( "VRP:HUD18" )
        if armor_w > surface.GetTextSize( armor_text ) + 10 then
            draw.SimpleText( armor_text, "VRP:HUD18", x + health_w + armor_w - 5, y + 10, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
        end
    end

    --  > Hunger
    surface.SetDrawColor( color_hunger )
    surface.DrawRect( x, y + 20, total_w * hunger / 100, 4 )
end

local hide = {
    ["CHudHealth"] = true,
    ["CHudBattery"] = true,
}
function GM:HUDShouldDraw( name )
    if hide[name] then return false end

    return true
end
