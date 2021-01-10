--  > Colors
VRP.Colors = {
    background = Color( 0, 0, 0, 175 ),
    red = Color( 255, 71, 87 ),
    blue = Color( 30, 144, 255 ),
    green = Color( 46, 213, 115 )
}

--  > Fonts
surface.CreateFont( "VRP:Font24", {
    font = "Bahnschrift",
    size = 24
} )

surface.CreateFont( "VRP:Font18", {
    font = "Bahnschrift",
    size = 18
} )

--  > Derma functions (like Garry's Mod "Derma_" functions )
function VRP.GUI_Frame( title, w, h )
    w = w or ( ScrW() * 0.6 )
    h = h or ( ScrH() * 0.6 )

    local bar_h = draw.GetFontHeight( "VRP:Font24" ) * 1.1

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( w, h )
    frame:Center()
    frame:MakePopup()
    frame:DockPadding( 5, bar_h + 5, 5, 5 )
    function frame:Paint( w ,h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )
        surface.DrawRect( 0, 0, w, bar_h )

        draw.SimpleText( title, "VRP:Font24", 5, bar_h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end

    local close = frame:Add( "DButton" )
    close:SetSize( bar_h, bar_h )
    close:SetPos( w - bar_h, 0 )
    function close:Paint( w, h )
        draw.SimpleText( "X", "VRP:Font24", w / 2, h / 2, self:IsHovered() and VRP.Colors.red or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        return true
    end
    function close:DoClick()
        frame:Remove()
    end

    return frame, close
end

--  > Theme painting
function VRP.ButtonPaint( button, w, h )
    surface.SetDrawColor( VRP.Colors.background )
    surface.DrawRect( 0, 0, w, h )

    surface.SetDrawColor( color_white )
    surface.DrawOutlinedRect( 0, 0, w, h )

    draw.SimpleText( button:GetText(), button:GetFont(), w / 2, h / 2, button:IsHovered() and VRP.Colors.blue or button:GetColor(), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    return true
end