if SERVER then
    util.AddNetworkString( "VRP:PrintChat" )
    
    local PLAYER = FindMetaTable( "Player" )
    function PLAYER:PrintChat( ... )
        local compressed = util.Compress( util.TableToJSON( { ... } ) )

        net.Start( "VRP:PrintChat" )
            net.WriteData( compressed, #compressed )
        net.Send( self )
    end
else
    net.Receive( "VRP:PrintChat", function( len )
        local data = net.ReadData( len )
        local args = util.JSONToTable( util.Decompress( data ) )

        chat.AddText( unpack( args ) )
    end )
end