local tabs = {
    {
        name = "Jobs",
        populate = function( canvas )
            local scroll = canvas:Add( "DScrollPanel" )
            scroll:Dock( FILL )

            for k, v in ipairs( VRP.Jobs ) do
                local line = scroll:Add( "DButton" )
                line:Dock( TOP )
                line:DockMargin( 0, 0, 0, 5 )
                line:SetTall( canvas:GetParent():GetTall() * 0.1 )
                
                function line:Paint( w, h )
                    surface.SetDrawColor( VRP.Colors.background )
                    surface.DrawRect( 0, 0, w, h )

                    surface.SetDrawColor( self:IsHovered() and VRP.Colors.blue or color_white )
                    surface.DrawOutlinedRect( 0, 0, w, h )

                    draw.SimpleText( v.name .. " (" .. VRP.FormatMoney( v.salary ) .. ")", "VRP:Font18", 5, 5, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
                    draw.SimpleText( v.description, "VRP:Font18", 5, h - 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

                    draw.SimpleText( team.NumPlayers( v.id ) .. "/" .. ( v.max == math.huge and "∞" or math.ceil( v.max * player.GetCount() ) ), "VRP:Font18", w - 5, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                    return true
                end

                function line:DoClick()
                    LocalPlayer():ConCommand( "vrp setjob " .. v.cmd )
                end
            end
        end
    },

    {
        name = "Market",
        populate = function( canvas )
            local cats = canvas:Add( "DHorizontalScroller" )
            cats:Dock( TOP )
            cats:SetTall( canvas:GetParent():GetTall() * 0.1 )

            local scroll = canvas:Add( "DScrollPanel" )
            scroll:Dock( FILL )

            local sorted = {}

            for k, v in ipairs( VRP.Market ) do
                sorted[ v.category ] = sorted[ v.category ] or {}

                sorted[ v.category ][ #sorted[ v.category ] + 1 ] = v
            end

            local tabs = {}
            local cats_count = table.Count( sorted )
            local current_cat = table.GetFirstKey( sorted )
            for category, content in pairs( sorted ) do
                local tab = cats:Add( "DButton" )
                tab:SetText( category )
                tab:Dock( LEFT )
                tab:DockMargin( 0, 0, 5, 0 )
                tab:SetWide( ( canvas:GetParent():GetWide() - 5 * ( cats_count + 3 ) ) * 0.8 / cats_count )
                tab:SetFont( "VRP:Font18" )
                tab:SetColor( current_cat == category and VRP.Colors.green or color_white )
                tab.Paint = VRP.ButtonPaint
                tabs[ #tabs + 1 ] = tab

                function tab:DoClick()
                    current_cat = self:GetText()

                    for k, v in ipairs( tabs ) do
                        v:SetColor( current_cat == v:GetText() and VRP.Colors.green or color_white )
                    end

                    scroll:Clear()

                    for k, v in ipairs( content ) do
                        local btn = scroll:Add( "DButton" )
                        btn:SetText( v.name )
                        btn:Dock( TOP )
                        btn:DockMargin( 0, 5, 0, 0 )
                        btn:SetTall( cats:GetTall() )

                        function btn:Paint( w, h )
                            surface.SetDrawColor( VRP.Colors.background )
                            surface.DrawRect( 0, 0, w, h )
        
                            surface.SetDrawColor( self:IsHovered() and VRP.Colors.blue or color_white )
                            surface.DrawOutlinedRect( 0, 0, w, h )
        
                            draw.SimpleText( v.name .. " (" .. VRP.FormatMoney( v.price ) .. ")", "VRP:Font18", 5, 5, v.color, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
                            draw.SimpleText( v.description, "VRP:Font18", 15, h - 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )
        
                            if self:IsHovered() then
                                draw.SimpleText( "Buy (" .. VRP.FormatMoney( v.price ) .. ")", "VRP:Font18", w - 5, h / 2, VRP.Colors.blue, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
                            end
        
                            return true
                        end

                        function btn:DoClick()
                            LocalPlayer():ConCommand( "vrp buy " .. v.id )
                        end
                    end
                end

                if category == current_cat then -- current_cat will always be the first one here
                    tab:DoClick()
                end
            end
        end
    },
}

local function open_f4()
    local ply = LocalPlayer()

    local frame = VRP.GUI_Frame( "f4_menu" )

    local left_part = frame:Add( "DScrollPanel" )
    left_part:Dock( LEFT )
    left_part:SetWide( frame:GetWide() * 0.2 )
    left_part:DockMargin( 0, 0, 5, 0 )

    local canvas = frame:Add( "DPanel" )
    canvas:Dock( FILL )
    function canvas:Paint() end

    local btns = {}
    local cur_tab = "Jobs"
    for k, v in ipairs( tabs ) do
        local btn = left_part:Add( "DButton" )
        btn:SetText( v.name )
        btn:SetFont( "VRP:Font18" )
        btn:Dock( TOP )
        btn:DockMargin( 0, 0, 0, 5 )
        btn:SetTall( frame:GetTall() * 0.1 )
        btn:SetColor( color_white )
        btn.Paint = VRP.ButtonPaint
        btns[ #btns + 1 ] = btn

        function btn:DoClick()
            cur_tab = self:GetText()
            
            for k, v in ipairs( btns ) do
                v:SetColor( cur_tab == v:GetText() and VRP.Colors.green or color_white )
            end

            canvas:Clear()

            v.populate( canvas )
        end
    end

    btns[1]:DoClick()
end

net.Receive( "VRP:F4", open_f4 )
concommand.Add( "vrp_f4", open_f4 )