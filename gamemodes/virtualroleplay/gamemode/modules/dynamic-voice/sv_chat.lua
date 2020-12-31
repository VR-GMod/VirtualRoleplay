local tchats = {
    { color = Color( 255, 0, 0 ), txt = "{Global} " },
    { txt = "[Radio] " }
}

function GM:PlayerSay( ply, txt, bTeam )
    --  > Chat commands
    if VRP.HandleChatCommand( ply, txt ) == false then return false end

    --  > OOC
    if txt:StartWith( "//" ) then
        for k, v in ipairs( player.GetHumans() ) do
            v:PrintChat( team.GetColor( ply:Team() ), "(OOC) ", ply:GetName(), ": ", color_white, txt:sub( 3 ):Trim() )
        end

        return false
    end

    --  > Other talking modes
    for k, v in ipairs( player.GetHumans() ) do
        local can_hear, _, tchat = VRP.CanHear( v, ply )

        if not can_hear then continue end
        local team_col = team.GetColor( ply:Team() )

        if VRP.InHearableRadius( v, ply ) and ( ( tchat == 1 and ply:GetGlobalEars() ) or ( tchat == 2 and v ~= ply ) ) then
            v:PrintChat( team_col, ply:GetName(), ": ", color_white, txt )

            continue
        end      

        v:PrintChat(
            tchats[tchat] and tchats[tchat].color or team_col,
            tchats[tchat] and tchats[tchat].txt or "",
            team_col, ply:GetName(), ": ", color_white, txt
        )
    end

    return false
end