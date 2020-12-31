
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

        if door:IsPropertyOwnable() then
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

                --  remove co-owner
                local remove_button = frame:Add( "DButton" )
                remove_button:SetText( VRP.GetPhrase( "remove_co_owner", ply:GetLanguage() ) )
                function remove_button:DoClick()
                    local menu = DermaMenu( frame )
                    for i, v in ipairs( player.GetAll() ) do
                        if not ( v == ply ) and door:IsPropertyCoOwnedBy( v ) then
                            menu:AddOption( v:GetRPName(), function()
                                net.Start( "VRP:Property" )
                                    net.WriteUInt( 2, 3 )
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
        end

        --  toggle ownable
        if ply:IsSuperAdmin() then
            local ownable_button = frame:Add( "DButton" )
            ownable_button:SetText( VRP.GetPhrase( "toggle_ownable", ply:GetLanguage() ) )
            function ownable_button:DoClick()
                net.Start( "VRP:Property" )
                    net.WriteUInt( 3, 3 )
                net.SendToServer()

                frame:Remove()
            end
        end

        --  auto-close
        if #buttons == 0 then frame:Remove() end
        function frame:Think()
            if ply:GetLookedDoor() == door then return end
            frame:Remove()
        end

        --  auto-tall
        local left, top, right, bottom = frame:GetDockPadding()
        local tall = frame:GetTall() - top - bottom - margin_bottom * ( #buttons - 1 )
        for i, v in ipairs( buttons ) do
            v:SetTall( tall / #buttons )
        end
    end,
    --  sync property data
    [1] = function( ply )
        local door = net.ReadEntity()
        if not IsValid( door ) then return end

        local data = net.ReadTable()
        --door:SetPropertyOwner( data.owner )  --  should not need of that (owner is NWEntity)
        door.vrp_co_owners = data.co_owners
        door.vrp_ownable = data.ownable
    end,
    --  sync all properties data
    [2] = function( ply )
        local data = net.ReadTable()
        for door, data in pairs( data ) do
            --door:SetPropertyOwner( data.owner )  --  should not need of that (owner is NWEntity)
            door.vrp_co_owners = data.co_owners
            door.vrp_ownable = data.ownable
        end

        VRP.Print( "received data for %d properties", table.Count( data ) )
    end,
} ) )

--  ask properties sync
hook.Add( "InitPostEntity", "VRP:Property", function()
    net.Start( "VRP:Property" )
        net.WriteUInt( 5, 3 )
    net.SendToServer()
end )

--  hud
local ENTITY = FindMetaTable( "Entity" )

local font = "Trebuchet20"
function ENTITY:DrawPropertyData()
    local ply = LocalPlayer()
    local x, y = ScrW() / 2, ScrH() / 2
    local height = draw.GetFontHeight( font )

    local function draw_text( text )
        draw.SimpleText( text, font, x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
        y = y + height
    end

    local owner = self:GetPropertyOwner()
    if IsValid( owner ) then
        local phrase = VRP.GetPhrase( "owner", ply:GetLanguage() )
        draw_text( phrase:sub( 1, 1 ):upper() .. phrase:sub( 2 ) .. ":" )
        draw_text( owner:GetRPName() )
        y = y + height / 4

        --  co-owners
        local co_owners = self:GetPropertyCoOwners()
        local count = co_owners and table.Count( co_owners )
        if co_owners and count > 0 then
            local phrase = VRP.GetPhrase( "co_owner", ply:GetLanguage() )
            draw_text( phrase:sub( 1, 1 ):upper() .. phrase:sub( 2 ) ..  ( count > 1 and "s" or "" ) .. ":" )

            for ply, v in pairs( co_owners ) do
                draw_text( ply:GetRPName() )
            end
        end
    elseif self:IsPropertyOwnable() then
        draw_text( VRP.GetPhrase( "open_property_menu", ply:GetLanguage() ) )
    end
end

hook.Add( "HUDPaint", "VRP:Property", function()
    local ply = LocalPlayer()
    local door = ply:GetLookedDoor()
    if not door then return end

    door:DrawPropertyData()
end )
