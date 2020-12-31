VRP.ChatCommands = {}
VRP.CommandIndexor = "/"

function VRP.AddChatCommand( cmd, callback )
    VRP.ChatCommands[cmd] = callback
end

function VRP.HandleChatCommand( ply, text )
    --  command
    local args = text:Split( " " )
    local cmd = table.remove( args, 1 )

    if cmd and cmd:StartWith( VRP.CommandIndexor ) then
        cmd = cmd:gsub( VRP.CommandIndexor, "" )
        if VRP.ChatCommands[cmd] then
            local msg, type, length = VRP.ChatCommands[cmd]( ply, args )

            if msg then
                if CLIENT then
                    notification.AddLegacy( msg, type or 0, length or 3 )
                else
                    VRP.Notify( ply, msg, type or 0, length or 3 )
                end
            end

            return false
        end
    end

    --  normal text
    return text
end

if CLIENT then
    function GM:OnPlayerChat( ply, text, is_team_chat, is_dead )
        if ply == LocalPlayer() then
            return not ( VRP.HandleChatCommand( ply, text ) == text )
        end

        return false
    end
end
