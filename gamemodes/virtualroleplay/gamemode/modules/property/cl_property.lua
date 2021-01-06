
local keys_inventory_menu, next_key_title, next_key_title_id = nil, nil, 1
function VRP.OpenKeysInventory()
    local ply = LocalPlayer()
    if IsValid( keys_inventory_menu ) then keys_inventory_menu:Remove() end

    local w, h = ScrW() * .6, ScrH() * .6
    local bar_h = draw.GetFontHeight( "VRP:Font24" ) * 1.1

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( w, h )
    frame:Center()
    frame:MakePopup()
    keys_inventory_menu = frame
    function frame:Paint( w ,h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )
        surface.DrawRect( 0, 0, w, bar_h )

        draw.SimpleText( VRP.GetPhrase( "keys_inventory", ply:GetLanguage() ), "VRP:Font24", 5, bar_h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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

    local scroll = frame:Add( "DScrollPanel" )
    scroll:Dock( FILL )
    scroll:DockMargin( 5, bar_h + 5, 5, 5 )

    local keys_list = scroll:Add( "DIconLayout" )
    keys_list:Dock( FILL )
    keys_list:SetSpaceX( 5 )
    keys_list:SetSpaceY( 5 )

    --  > Adding the keys to the menu
    for i, v in ipairs( ply.vrp_keys or {} ) do
        local key = keys_list:Add( "DButton" )
        key:SetText( v.title )
        key:SetFont( "VRP:Font18" )
        key:SizeToContents()
        key:SetWide( key:GetWide() * 1.5 )
        key:SetTall( key:GetTall() * 1.5 )

        function key:Paint( w, h )
            surface.SetDrawColor( VRP.Colors.background )
            surface.DrawRect( 0, 0, w, h )

            surface.SetDrawColor( color_white )
            surface.DrawOutlinedRect( 0, 0, w, h )

            draw.SimpleText( self:GetText(), self:GetFont(), w / 2, h / 2, self:IsHovered() and VRP.Colors.blue or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            return true
        end

        function key:DoClick()
            local menu = DermaMenu( frame )
    
            menu:AddOption( VRP.GetPhrase( "copy_for", ply:GetLanguage(), {
                    amount = VRP.FormatMoney( VRP.PropertyCopyAmount )
                } ), function()
                net.Start( "VRP:PropertyCopy" )
                    net.WriteUInt( v.id, VRP.PropertyMaxKeysBytes )
                net.SendToServer()
    
                next_key_title = v.title .. " Copy"
            end ):SetMaterial( "icon16/key_add.png" )
    
            local rename = VRP.GetPhrase( "rename", ply:GetLanguage() )
            menu:AddOption( rename, function()
                Derma_StringRequest( rename, "", v.title, function( text )
                    VRP.Notify( VRP.GetPhrase( "rename_to", ply:GetLanguage(), {
                        old = v.title,
                        new = text,
                    } ) )
    
                    v.title = text
                    VRP.OpenKeysInventory()
                end )
            end ):SetMaterial( "icon16/pencil.png" )
    
            menu:AddOption( VRP.GetPhrase( "drop", ply:GetLanguage() ), function()
                net.Start( "VRP:PropertyDrop" )
                    net.WriteUInt( v.id, VRP.PropertyMaxKeysBytes )
                    net.WriteString( v.title )
                net.SendToServer()
            end ):SetMaterial( "icon16/key_go.png" )
    
            menu:AddOption( VRP.GetPhrase( "sell", ply:GetLanguage(), {
                    amount = VRP.FormatMoney( VRP.PropertySellAmount ),
                } ), function()
                net.Start( "VRP:PropertySell" )
                    net.WriteUInt( v.id, VRP.PropertyMaxKeysBytes )
                net.SendToServer()
            end ):SetMaterial( "icon16/key_delete.png" )
    
            function menu:Paint( w, h ) end -- No more default background

            for k, v in ipairs( menu:GetCanvas():GetChildren() ) do
                function v:Paint( w, h ) -- Changing buttons' style
                    surface.SetDrawColor( 0, 0, 0 )
                    surface.DrawRect( 0, 0, w, h )
                    
                    surface.SetDrawColor( color_white )
                    surface.DrawOutlinedRect( 0, 0, w, h )

                    draw.SimpleText( v:GetText(), "VRP:Font18", h + 5, h / 2, self:IsHovered() and VRP.Colors.blue or color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

                    return true
                end 
            end

            menu:Open()
        end
    end
end
concommand.Add( "vrp_keys_inventory", VRP.OpenKeysInventory )

--  sync data
net.Receive( "VRP:PropertyOwnable", function( len )
    local door = net.ReadEntity()
    if not IsValid( door ) then return end

    door.vrp_ownable = net.ReadBool()
end )

net.Receive( "VRP:PropertySyncKeys", function( len )
    local ply = LocalPlayer()
    ply.vrp_keys = ply.vrp_keys or {}

    local method = net.ReadString()
    if method == "add" then
        local data = {
            id = net.ReadUInt( 11 ),
            title = net.ReadString(),
        }
        if #data.title == 0 then
            if next_key_title then
                data.title = next_key_title
                next_key_title = nil
            else
                data.title = "Door #" .. next_key_title_id
                next_key_title_id = next_key_title_id + 1
            end
        end

        ply.vrp_keys[#ply.vrp_keys + 1] = data
    elseif method == "remove" then
        local i = net.ReadUInt( VRP.PropertyMaxKeysBytes ) --  max 31 keys
        table.remove( ply.vrp_keys, i )
    end

    if IsValid( keys_inventory_menu ) then
        VRP.OpenKeysInventory()
    end
end )

--  menu
net.Receive( "VRP:PropertyMenu", function( ply )
    local ply = LocalPlayer()

    local door = ply:GetLookedDoor()
    if not door then return end

    local is_owned = net.ReadBool()

    --  frame
    local margin_bottom, buttons = 5, {}
    local w, h = ScrW() * .2, ScrH() * .4
    local bar_h = draw.GetFontHeight( "VRP:Font24" ) * 1.1

    local frame = vgui.Create( "DPanel" )
    frame:SetSize( w, h )
    frame:DockPadding( 5, bar_h + 5, 5, 5 )
    frame:Center()
    frame:MakePopup()
    function frame:Paint( w ,h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )
        surface.DrawRect( 0, 0, w, bar_h )

        draw.SimpleText( VRP.GetPhrase( "property_menu", ply:GetLanguage() ), "VRP:Font24", 5, bar_h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
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

    --  bored to add them manually so..
    function frame:AddButton()
        local pnl = self:Add( "DButton" )
        pnl:Dock( TOP )
        pnl:DockMargin( 0, 0, 0, margin_bottom )

        buttons[#buttons + 1] = pnl

        --  > Custom buttons with a custom style
        function pnl:Paint( w, h )
            surface.SetDrawColor( VRP.Colors.background )
            surface.DrawRect( 0, 0, w, h )
            
            surface.SetDrawColor( color_white )
            surface.DrawOutlinedRect( 0, 0, w, h )

            draw.SimpleText( self:GetText(), "VRP:Font18", w / 2, h / 2, self:IsHovered() and VRP.Colors.blue or color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

            return true
        end
        
        return pnl
    end

    if door:IsPropertyOwnable() then
        if ply:HasPropertyKeysOf( door:GetPropertyID() ) then
            --  clear
            local clear_button = frame:AddButton()
            clear_button:SetText( VRP.GetPhrase( "clear_for", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertyClearKeysAmount )
            } ) )
            function clear_button:DoClick()
                net.Start( "VRP:PropertyClear" )
                net.SendToServer()

                frame:Remove()
            end
        elseif not is_owned then
            --  buy
            local buy_button = frame:AddButton()
            buy_button:SetText( VRP.GetPhrase( "buy", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertyBuyAmount )
            } ) )
            function buy_button:DoClick()
                net.Start( "VRP:PropertyBuy" )
                net.SendToServer()

                frame:Remove()
            end
        end
    end

    --  inventory
    local inventory_button = frame:AddButton()
    inventory_button:SetText( VRP.GetPhrase( "open_keys_inventory", ply:GetLanguage() ) )
    function inventory_button:DoClick()
        VRP.OpenKeysInventory()
        frame:Remove()
    end

    --  toggle ownable
    if ply:IsSuperAdmin() then
        local ownable_button = frame:AddButton()
        ownable_button:SetText( VRP.GetPhrase( "toggle_ownable", ply:GetLanguage() ) .. ( " (%s)" ):format( door:IsPropertyOwnable() and "ON" or "OFF" ) )
        function ownable_button:DoClick()
            net.Start( "VRP:PropertyOwnable" )
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
end )
