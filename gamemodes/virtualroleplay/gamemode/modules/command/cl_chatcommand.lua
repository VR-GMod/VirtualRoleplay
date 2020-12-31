function GM:OnPlayerChat( ply, text, is_team_chat, is_dead )
    if ply == LocalPlayer() then
        return not ( VRP.HandleChatCommand( ply, text ) == text )
    end

    return false
end