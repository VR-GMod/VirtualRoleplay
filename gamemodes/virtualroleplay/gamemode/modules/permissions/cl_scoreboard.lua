if IsValid( VRP.Scoreboard ) then
    VRP.Scoreboard:Remove()
end

local canvases, active_canvas = {}
local function goto_canvas( goto_i )
    local gone_to

    for i, canvas in ipairs( canvases ) do
        if i == goto_i then
            canvas:Show()
            
            if canvas.OnGo then
                canvas:OnGo()
            end

            gone_to = canvas
            active_canvas = canvas
        else
            canvas:Hide()
        end
    end

    return gone_to
end

local panels = {
    function( canvas )
        local scroll = canvas:Add( "DScrollPanel" )
        scroll:Dock( FILL )
        scroll:GetVBar():SetWide( 0 )

        local line_h = canvas:GetTall() / 10

        function canvas:OnGo()
            scroll:Clear()

            for k, v in ipairs( player.GetAll() ) do
                local line = scroll:Add( "DButton" )
                line:Dock( TOP )
                line:DockMargin( 0, 0, 0, 5 )
                line:SetTall( line_h )
                function line:Paint( w, h )
                    surface.SetDrawColor( VRP.Colors.background )
                    surface.DrawRect( 0, 0, w, h )
                
                    surface.SetDrawColor( color_white )
                    surface.DrawOutlinedRect( 0, 0, w, h )

                    draw.SimpleText( v:Name(), "VRP:Font24", h, h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
                    draw.SimpleText( v:Ping() .. "ms", "VRP:Font18", w - 10, h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

                    return true
                end
                function line:DoClick()
                    goto_canvas( 2 ):SetPlayer( v )
                end

                local avatar = line:Add( "AvatarImage" )
                avatar:SetPlayer( v, 256 )
                avatar:Dock( LEFT )
                avatar:DockMargin( 5, 5, 5, 5 )
                avatar:SetWide( line:GetTall() - 10 )
            end
        end
    end,

    function( canvas )
        local go_back = canvas:Add( "DButton" )
        go_back:SetText( "Go back" )
        go_back:SetFont( "VRP:Font24" )
        go_back:SetColor( color_white )
        go_back:Dock( BOTTOM )
        go_back:SetTall( go_back:GetTall() * 1.5 )
        go_back.Paint = VRP.ButtonPaint
        function go_back:DoClick()
            goto_canvas( 1 )
        end

        --  > Everything about the player
        local player_panel = canvas:Add( "DPanel" )
        player_panel:Dock( LEFT )
        player_panel:DockMargin( 0, 0, 2.5, 5 )
        player_panel:SetWide( canvas:GetWide() / 2 )

        local avatar = player_panel:Add( "AvatarImage" )
        avatar:SetPlayer( nil, 256 )
        avatar:Dock( NODOCK )
        avatar:DockMargin( 5, 5, 5, 5 )
        avatar:SetSize( player_panel:GetWide() /3, player_panel:GetWide() /3 )
        
        function player_panel:Paint( w, h )
            local ply = canvas.ply
            if not IsValid( ply ) then return end

            --  > Roleplay infos
            local rp_infos = {
                { name = "Name", value = ply:GetName() },
                { name = "Health", value = ply:Health() .. "%" },
                { name = "Money", value = VRP.FormatMoney( ply:GetMoney() ) },
                { name = "Job", value = ply:GetJob().name },
            }

            draw.SimpleText( "Roleplay infos:", "VRP:Font24", avatar:GetWide() + 5, 5, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

            for i, v in ipairs( rp_infos ) do
                draw.SimpleText(
                    v.name .. ": " .. v.value,
                    "VRP:Font18",
                    avatar:GetWide() + 15,
                    5 + draw.GetFontHeight( "VRP:Font24" ) + draw.GetFontHeight( "VRP:Font18" ) * ( i - 1 ),
                    color_white,
                    TEXT_ALIGN_LEFT,
                    TEXT_ALIGN_TOP
                )
            end


            --  > Metagame infos
            local meta_infos = {
                { name = "Steam Name", value = ply:SteamName() },
                { name = "Rank", value = ply:GetUserGroup() },
                { name = "Ping", value = ply:Ping() .. "ms" },
                { name = "SteamID", value = ply:SteamID() },
                { name = "SteamID64", value = ply:SteamID64() },
            }

            draw.SimpleText( "Metagame infos:", "VRP:Font24", 5, 5 + avatar:GetTall(), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

            for i, v in ipairs( meta_infos ) do
                draw.SimpleText(
                    ( v.name or "NoName" ) .. ": " .. ( v.value or "N/A" ),
                    "VRP:Font18",
                    15,
                    5 + avatar:GetTall() + draw.GetFontHeight( "VRP:Font24" ) + draw.GetFontHeight( "VRP:Font18" ) * ( i - 1 ),
                    color_white,
                    TEXT_ALIGN_LEFT,
                    TEXT_ALIGN_TOP
                )
            end
        end
        
        --  > Commands to do on him
        local commands_panel = canvas:Add( "DScrollPanel" )
        commands_panel:Dock( FILL )
        commands_panel:GetVBar():SetWide( 0 )
        commands_panel:DockMargin( 2.5, 0, 0, 5 )

        local commands

        if ULib then
            commands = {
                --  > Utility
                { txt = "Kick", callback = "ulx kick \"%s\"" },
                { txt = "Spectate", callback = "ulx spectate \"%s\"" },
                { txt = "Noclip", callback = "ulx noclip \"%s\"" },

                --  > Teleport
                { txt = "Bring", callback = "ulx bring \"%s\"" },
                { txt = "Goto", callback = "ulx goto \"%s\"" },
                { txt = "Return", callback = "ulx return \"%s\"" },
                { txt = "Teleport", callback = "ulx teleport \"%s\"" },

                --  > Fun
                { txt = "Slay", callback = "ulx slay \"%s\"" },
                { txt = "Strip weapons", callback = "ulx strip \"%s\"" },
            }
        else
            commands = {
                { txt = "Kick", callback = "vrp kick \"%s\"" },
            }
        end

        local cmds = commands_panel:Add( "DIconLayout" )
        cmds:Dock( FILL )
        cmds:SetSpaceX( 5 )
        cmds:SetSpaceY( 5 )

        for k, v in ipairs( commands ) do
            local btn = cmds:Add( "DButton" )
            btn:SetText( v.txt )
            btn:SetFont( "VRP:Font18" )
            btn:SetColor( color_white )
            btn.Paint = VRP.ButtonPaint
            btn:SizeToContents()
            btn:SetWide( btn:GetWide() + 20 )

            function btn:DoClick()
                if isfunction( v.callback ) then
                    v.callback( canvas.ply )

                elseif isstring( v.callback ) then
                    if IsValid( canvas.ply ) and canvas.ply:IsPlayer() then
                        LocalPlayer():ConCommand( v.callback:format( canvas.ply:GetName() ) )
                    end
                end
            end
        end

        function canvas:SetPlayer( ply )
            canvas.ply = ply

            avatar:SetPlayer( ply, 256 )
        end
    end,
}

function GM:ScoreboardShow()
    gui.EnableScreenClicker( true )

    if IsValid( VRP.Scoreboard ) then
        if IsValid( active_canvas ) then
            if active_canvas.OnGo then
                active_canvas:OnGo()
            end
        end

        VRP.Scoreboard:Show()

        return
    end

    local bar_h = draw.GetFontHeight( "VRP:Font24" ) * 1.5

    local main = vgui.Create( "DPanel" )
    VRP.Scoreboard = main
    main:SetSize( ScrW() * 0.8, ScrH() * 0.8 )
    main:Center()
    function main:Paint( w, h )
        surface.SetDrawColor( VRP.Colors.background )
        surface.DrawRect( 0, 0, w, h )
    
        surface.SetDrawColor( color_white )
        surface.DrawOutlinedRect( 0, 0, w, h )

        surface.DrawOutlinedRect( 0, 0, w, bar_h )

        draw.SimpleText( self.title or GetHostName(), "VRP:Font24", w / 2, bar_h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    for i, populate in ipairs( panels ) do
        local canvas = main:Add( "DPanel" )
        canvas:SetSize( main:GetWide() - 10, main:GetTall() - bar_h - 10 )
        canvas:SetPos( 5, bar_h + 5 )
        function canvas:Paint( w, h )
        end

        canvases[i] = canvas
        
        populate( canvas )
    end

    goto_canvas( 1 )
end

function GM:ScoreboardHide()
    gui.EnableScreenClicker( false )

    if IsValid( VRP.Scoreboard ) then
        VRP.Scoreboard:Hide()

        return
    end
end