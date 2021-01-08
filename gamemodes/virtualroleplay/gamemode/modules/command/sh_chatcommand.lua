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

concommand.Add( "vrp", function( ply, _, _, str )
    VRP.HandleChatCommand( ply, VRP.CommandIndexor .. str )
end, function( _, args )
    local result = {}

    for k, v in pairs( VRP.ChatCommands ) do
        if k:lower():match( args:Trim():lower() ) then
            result[ #result + 1 ] = "vrp " .. k
        end
    end

    return result
end )