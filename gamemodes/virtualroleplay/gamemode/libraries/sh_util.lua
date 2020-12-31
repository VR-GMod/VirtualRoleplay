
local good_diff_time = 1 --  seconds
function VRP.NetworkReceiveAsMethods( uint_bytes, methods )
    local last_net_time = {}
    return function( len, ply )
        local method = net.ReadUInt( uint_bytes )
        if not methods[method] then return end
        if SERVER and last_net_time[ply] and CurTime() - last_net_time[ply] < good_diff_time then return end

        methods[method]( ply or LocalPlayer(), len )
        if SERVER then
            last_net_time[ply] = CurTime()
        end
    end
end

function VRP.Format( text, params )
    return text:gsub( "%${([%w_%d]+)}", function( str )
        return params[str:Trim()] or "?"
    end )
end
