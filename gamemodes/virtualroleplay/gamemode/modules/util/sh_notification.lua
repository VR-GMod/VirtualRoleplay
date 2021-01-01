--  default: 3 (0-7); 8 (0-255)
local type_bytes, length_bytes = 3, 8

if SERVER then
    util.AddNetworkString( "VRP:Notify" )

    function VRP.Notify( ply, text, type, length )
        net.Start( "VRP:Notify" )
            net.WriteString( text )
            net.WriteUInt( type or 0, type_bytes )
            net.WriteUInt( length or 3, length_bytes )
        if not ply then
            net.Broadcast()
        else
            net.Send( ply )
        end
    end
else
    function VRP.Notify( text, type, length )
        assert( isstring( text ) and #text > 0, "#1 argument must be a non-empty string" )

        notification.AddLegacy( text, type or 0, length or 3 )
        surface.PlaySound( "buttons/lightswitch2.wav" )
    end

    net.Receive( "VRP:Notify", function()
        VRP.Notify( net.ReadString(), net.ReadUInt( type_bytes ), net.ReadUInt( length_bytes ) )
    end )
end
