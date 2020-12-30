
net.Receive( "VRP:Property", VRP.NetworkReceiveAsMethods( 3, {
    --  menu
    [0] = function( ply )
        local door = ply:GetLookedDoor()
        if not door then return end

        --  frame
        local margin_bottom, buttons = 5, {}
        local w, h = ScrW() * .2, ScrH() * .4
        local frame = vgui.Create( "DFrame" )
        frame:SetTitle( "Property Menu" )
        frame:SetSize( w, h )
        frame:Center()
        frame:MakePopup()

        --  bored to add them manually so..
        local frame_add = frame.Add
        function frame:Add( class )
            local pnl = frame_add( self, class )
            pnl:Dock( TOP )
            pnl:DockMargin( 0, 0, 0, margin_bottom )

            buttons[#buttons + 1] = pnl
            return pnl
        end

        if door:IsPropertyOwnedBy( ply ) then
            --  sell
            local sell_button = frame:Add( "DButton" )
            sell_button:SetText( VRP.GetPhrase( "sell", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertySellAmount )
            } ) )
            function sell_button:DoClick()
                net.Start( "VRP:Property" )
                    net.WriteUInt( 0, 3 )
                net.SendToServer()

                frame:Remove()
            end

            --  add co-owner
            local add_button = frame:Add( "DButton" )
            add_button:SetText( VRP.GetPhrase( "add_co_owner", ply:GetLanguage() ) )
            function add_button:DoClick()
                local menu = DermaMenu( frame )
                for i, v in ipairs( player.GetAll() ) do
                    if not ( v == ply ) and not door:IsPropertyCoOwnedBy( v ) then
                        menu:AddOption( v:GetRPName(), function()
                            net.Start( "VRP:Property" )
                                net.WriteUInt( 1, 3 )
                                net.WriteEntity( v )
                            net.SendToServer()

                            frame:Remove()
                        end )
                    end
                end

                menu:Open()
            end
        elseif not IsValid( door:GetPropertyOwner() ) then
            --  buy
            local buy_button = frame:Add( "DButton" )
            buy_button:SetText( VRP.GetPhrase( "buy", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertyBuyAmount )
            } ) )
            function buy_button:DoClick()
                net.Start( "VRP:Property" )
                    net.WriteUInt( 0, 3 )
                net.SendToServer()

                frame:Remove()
            end
        end

        --  auto-tall
        local left, top, right, bottom = frame:GetDockPadding()
        local tall = frame:GetTall() - top - bottom - margin_bottom * ( #buttons - 1 )
        for i, v in ipairs( buttons ) do
            v:SetTall( tall / #buttons )
        end
    end,
    --  todo: ask sync on connection
    --  sync co-owners
    [1] = function( ply )
        local door = net.ReadEntity()
        if not IsValid( door ) then return end

        local co_owners = net.ReadTable()
        door.vrp_co_owners = co_owners
    end,
} ) )
