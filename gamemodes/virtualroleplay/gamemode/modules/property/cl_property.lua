
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
            net.Start( "VRP:Property" )
                net.WriteUInt( 1, 3 )
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
            net.Start( "VRP:Property" )
                net.WriteUInt( 2, 3 )
                net.WriteUInt( line_id, VRP.PropertyMaxKeysBytes )
                net.WriteString( ply.vrp_keys[line_id].title )
            net.SendToServer()
        end ):SetMaterial( "icon16/key_go.png" )

        menu:AddOption( VRP.GetPhrase( "sell", ply:GetLanguage(), {
                amount = VRP.FormatMoney( VRP.PropertySellAmount ),
            } ), function()
            net.Start( "VRP:Property" )
                net.WriteUInt( 4, 3 )
                net.WriteUInt( line_id, VRP.PropertyMaxKeysBytes )
            net.SendToServer()
        end ):SetMaterial( "icon16/key_delete.png" )

        menu:Open()
    end
end
concommand.Add( "vrp_keys_inventory", VRP.OpenKeysInventory )

net.Receive( "VRP:Property", VRP.NetworkReceiveAsMethods( 3, {
    --  menu
    [0] = function( ply )
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
                --  sell
                local sell_button = frame:Add( "DButton" )
                sell_button:SetText( VRP.GetPhrase( "clear_for", ply:GetLanguage(), {
                    amount = VRP.FormatMoney( VRP.PropertyClearKeysAmount )
                } ) )
                function sell_button:DoClick()
                    net.Start( "VRP:Property" )
                        net.WriteUInt( 5, 3 )
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
                    net.Start( "VRP:Property" )
                        net.WriteUInt( 0, 3 )
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
        door.vrp_ownable = data.ownable
    end,
    --  sync keys data
    [2] = function( ply )
        ply.vrp_keys = ply.vrp_keys or {}

        local method = net.ReadString()
        if method == "add" then
            local data = net.ReadTable()
            if not data.title then
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
            local i = net.ReadUInt( 5 ) --  max 31 keys
            table.remove( ply.vrp_keys, i )
        end

        if IsValid( keys_inventory_menu ) then
            VRP.OpenKeysInventory()
        end
    end,
    --  sync all properties data
    -- [2] = function( ply )
    --     local data = net.ReadTable()
    --     for door, data in pairs( data ) do
    --         --door:SetPropertyOwner( data.owner )  --  should not need of that (owner is NWEntity)
    --         door.vrp_co_owners = data.co_owners
    --         door.vrp_ownable = data.ownable
    --     end
    --
    --     VRP.Print( "received data for %d properties", table.Count( data ) )
    -- end,
} ) )

--  ask properties sync
-- hook.Add( "InitPostEntity", "VRP:Property", function()
--     net.Start( "VRP:Property" )
--         net.WriteUInt( 5, 3 )
--     net.SendToServer()
-- end )

--  hud
-- local ENTITY = FindMetaTable( "Entity" )
--
-- local font = "Trebuchet20"
-- function ENTITY:DrawPropertyData()
--     local ply = LocalPlayer()
--     local x, y = ScrW() / 2, ScrH() / 2
--     local height = draw.GetFontHeight( font )
--
--     local function draw_text( text )
--         draw.SimpleText( text, font, x, y, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
--         y = y + height
--     end
--
--     local owner = self:GetPropertyOwner()
--     if IsValid( owner ) then
--         local phrase = VRP.GetPhrase( "owner", ply:GetLanguage() )
--         draw_text( phrase:sub( 1, 1 ):upper() .. phrase:sub( 2 ) .. ":" )
--         draw_text( owner:GetRPName() )
--         y = y + height / 4
--
--         --  co-owners
--         local co_owners = self:GetPropertyCoOwners()
--         local count = co_owners and table.Count( co_owners )
--         if co_owners and count > 0 then
--             local phrase = VRP.GetPhrase( "co_owner", ply:GetLanguage() )
--             draw_text( phrase:sub( 1, 1 ):upper() .. phrase:sub( 2 ) ..  ( count > 1 and "s" or "" ) .. ":" )
--
--             for ply, v in pairs( co_owners ) do
--                 draw_text( ply:GetRPName() )
--             end
--         end
--     elseif self:IsPropertyOwnable() then
--         draw_text( VRP.GetPhrase( "open_property_menu", ply:GetLanguage() ) )
--     end
-- end
--
-- hook.Add( "HUDPaint", "VRP:Property", function()
--     local ply = LocalPlayer()
--     local door = ply:GetLookedDoor()
--     if not door then return end
--
--     door:DrawPropertyData()
-- end )
