
local keys_inventory_menu, next_key_title, next_key_title_id = nil, nil, 1
function VRP.OpenKeysInventory()
    local ply = LocalPlayer()
    if IsValid( keys_inventory_menu ) then keys_inventory_menu:Remove() end

    local w, h = ScrW() * .3, ScrH() * .4
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( VRP.GetPhrase( "keys_inventory", ply:GetLanguage() ) )
    frame:SetSize( w, h )
    frame:Center()
    frame:MakePopup()
    keys_inventory_menu = frame

    local keys_list = frame:Add( "DListView" )
    keys_list:Dock( FILL )
    keys_list:AddColumn( VRP.GetPhrase( "title", ply:GetLanguage() ) )
    for i, v in ipairs( ply.vrp_keys or {} ) do
        keys_list:AddLine( v.title )
    end
    function keys_list:OnRowRightClick( line_id, line )
        local menu = DermaMenu( frame )

        menu:AddOption( VRP.GetPhrase( "copy_for", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertyCopyAmount )
            } ), function()
            net.Start( "VRP:PropertyCopy" )
                net.WriteUInt( line_id, VRP.PropertyMaxKeysBytes )
            net.SendToServer()

            next_key_title = ply.vrp_keys[line_id].title .. " Copy"
        end ):SetMaterial( "icon16/key_add.png" )

        local rename = VRP.GetPhrase( "rename", ply:GetLanguage() )
        menu:AddOption( rename, function()
            Derma_StringRequest( rename, "", ply.vrp_keys[line_id].title, function( text )
                VRP.Notify( VRP.GetPhrase( "rename_to", ply:GetLanguage(), {
                    old = ply.vrp_keys[line_id].title,
                    new = text,
                } ) )

                ply.vrp_keys[line_id].title = text
                VRP.OpenKeysInventory()
            end )
        end ):SetMaterial( "icon16/pencil.png" )

        menu:AddOption( VRP.GetPhrase( "drop", ply:GetLanguage() ), function()
            net.Start( "VRP:PropertyDrop" )
                net.WriteUInt( line_id, VRP.PropertyMaxKeysBytes )
                net.WriteString( ply.vrp_keys[line_id].title )
            net.SendToServer()
        end ):SetMaterial( "icon16/key_go.png" )

        menu:AddOption( VRP.GetPhrase( "sell", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertySellAmount ),
            } ), function()
            net.Start( "VRP:PropertySell" )
                net.WriteUInt( line_id, VRP.PropertyMaxKeysBytes )
            net.SendToServer()
        end ):SetMaterial( "icon16/key_delete.png" )

        menu:Open()
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
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( VRP.GetPhrase( "property_menu", ply:GetLanguage() ) )
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
        if ply:HasPropertyKeysOf( door:GetPropertyID() ) then
            --  clear
            local clear_button = frame:Add( "DButton" )
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
            local buy_button = frame:Add( "DButton" )
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
    local inventory_button = frame:Add( "DButton" )
    inventory_button:SetText( VRP.GetPhrase( "open_keys_inventory", ply:GetLanguage() ) )
    function inventory_button:DoClick()
        VRP.OpenKeysInventory()
        frame:Remove()
    end

    --  toggle ownable
    if ply:IsSuperAdmin() then
        local ownable_button = frame:Add( "DButton" )
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
