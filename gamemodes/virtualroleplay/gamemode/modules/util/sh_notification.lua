--  default: 3 (0-7); 8 (0-255)
local type_bytes, length_bytes = 3, 8

if SERVER then
    util.AddNetworkString( "VRP:Notify" )

    function VRP.Notify( ply, text, type, length )
        net.Start( "VRP:Notify" )
            net.WriteString( text )
            net.WriteUInt( type or 0, type_bytes )
            net.WriteUInt( length or 3, length_bytes )
        net.Send( ply )
    end
else
    net.Receive( "VRP:Notify", function()
        notification.AddLegacy( net.ReadString(), net.ReadUInt( type_bytes ), net.ReadUInt( length_bytes ) )
        surface.PlaySound( "buttons/lightswitch2.wav" )
    end )
end
