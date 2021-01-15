local function change_playmode()
    local bar_h = draw.GetFontHeight( "VRP:Font24" ) * 1.5

    if IsValid( VRP.StartFrame ) then VRP.StartFrame:Remove() end

    local frame = vgui.Create( "DPanel" )
    VRP.StartFrame = frame
    frame:MakePopup()
    frame:SetSize( ScrW() * 0.6, ScrH() * 0.6 )
    frame:Center()
    frame:DockPadding( 5, bar_h + 5, 5, 5 )
    function frame:Paint( w, h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )
        surface.DrawRect( 0, 0, w, bar_h )

        draw.SimpleText( "Please choose your play mode", "VRP:Font24", w / 2, bar_h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    local mats = {
        vr = {
            headset = Material( "gui/vr_headset.png" ),
            headset_bw = Material( "gui/vr_headset_bw.png" ),
            controllers = Material( "gui/vr_controllers.png" ),
        },
        flat = {
            screen = Material( "gui/flat_screen.png" ),
            screen_bw = Material( "gui/flat_screen_bw.png" ),
            keyboard = Material( "gui/flat_keyboard.png" ),
        }
    }

    local computer = frame:Add( "DButton" )
    computer:Dock( LEFT )
    computer:SetWide( frame:GetWide() / 2 - 7.5 )
    function computer:Paint( w, h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( color_white )

        surface.SetMaterial( self:IsHovered() and mats.vr.headset or mats.vr.headset_bw )
        surface.DrawTexturedRect( 10, 10, w - 20, h - 20 )

        self.effect = Lerp( FrameTime() * ( self:IsHovered() and 6 or 2 ), self.effect or h, self:IsHovered() and 0 or h )
        surface.SetMaterial( mats.vr.controllers )
        surface.DrawTexturedRect( 10, 10 + self.effect, w - 20, h - 20 )

        surface.DrawOutlinedRect( 0, 0, w, h )

        return true
    end
    function computer:DoClick()
        frame:Remove()
    end

    local vr = frame:Add( "DButton" )
    vr:Dock( RIGHT )
    vr:SetWide( frame:GetWide() / 2 - 7.5 )
    function vr:Paint( w, h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )

        surface.SetDrawColor( color_white )

        surface.SetMaterial( self:IsHovered() and mats.flat.screen or mats.flat.screen_bw )
        surface.DrawTexturedRect( 10, 10, w - 20, h - 20 )

        self.effect = Lerp( FrameTime() * ( self:IsHovered() and 10 or 1 ), self.effect or h, self:IsHovered() and 0 or h )
        surface.SetMaterial( mats.flat.keyboard )
        surface.DrawTexturedRect( 10, 10 + self.effect, w - 20, h - 20 )

        surface.DrawOutlinedRect( 0, 0, w, h )

        return true
    end
    function vr:DoClick()
        frame:Remove()
    end
end

hook.Add( "InitPostEntity", "VRP:ChoosePlayMode", change_playmode )
concommand.Add( "vrp_playmode", change_playmode )